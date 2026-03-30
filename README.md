# 🏰 ÙSD - Treasury Manager

**Operated by AMI (Artificial Monetary Intelligence)**

## Overview

TreasuryManagerV2 is an onchain treasury management contract for ÙSD (TurboUSD) on Base. It enforces strict one-directional token flows: tokens are accumulated into the treasury, ÙSD can only be bought, staked, or burned — never sold. A permissionless fallback mechanism guarantees ÙSD buybacks will continue even if the operator goes offline.

## Architecture

Single contract: `TreasuryManagerV2.sol` — no upgradeable proxy, no additional contracts needed.

### Key Roles

| Role | Description |
|------|-------------|
| **Owner** | Sets operator, configures caps, rescues dead pool tokens |
| **Operator** | AMI agent — executes buybacks, burns, stakes, token purchases, rebalances |
| **Permissionless** | Anyone — rebalances tokens that hit 1000%+ ROI after 14 days of operator inactivity |

### Contract Addresses (Base Mainnet)

| Contract | Address |
|----------|---------|
| WETH | `0x4200000000000000000000000000000000000006` |
| USDC | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` |
| ÙSD (TurboUSD) | `0x583866fb22a3d67d7c45e1D0F34BcB20Bf9c6353` |
| Official ÙSD/WETH V3 Pool | `0xAD501A478bF0F81C42C8C80ea08968f5Aa4c2f9A` |
| Staking | `0x2a70a42BC0524aBCA9Bff59a51E7aAdB575DC89A` |
| V3 SwapRouter02 | `0x2626664c2603336E57B271c5C0b26F421741e481` |
| Universal Router | `0x6fF5693b99212Da76ad316178A184AB56D299b43` |

## Immutable Constants

All safety parameters are hardcoded and cannot be changed:

| Parameter | Value |
|-----------|-------|
| Slippage (permissionless) | 3% |
| Permissionless cooldown | 4 hours per token |
| Max per swap (permissionless) | 5% of unlocked |
| Circuit breaker vs 24h TWAP | 15% |
| Operator inactivity period | 14 days |
| Dead pool threshold | 90 days |
| Operator cooldown | 60 minutes |
| Per-action cap (permissionless) | 0.5 ETH |
| Per-day cap (permissionless) | 2 ETH |

## Operator Caps (Owner-Configurable)

| Action | Per Action | Per Day |
|--------|-----------|---------|
| BuybackWETH | 0.5 ETH | 2 ETH |
| BuybackUSDC | 2,000 USDC | 5,000 USDC |
| Burn | 100M ÙSD | 500M ÙSD |
| Stake | 100M ÙSD | 500M ÙSD |
| Rebalance | 0.5 ETH (equiv) | 2 ETH (equiv) |

## Functions

### Owner-Only
- `setOperator(address)` — Set AMI operator
- `updateCaps(ActionType, perAction, perDay)` — Change operator caps
- `setSlippage(uint256 bps)` — Operator slippage only
- `rescueDeadPoolToken(address token, bytes path)` — After 90+ days dead pool

### Operator-Only
- `buybackWithWETH(uint256 amountIn)` — WETH → ÙSD
- `buybackWithUSDC(uint256 amountIn)` — USDC → WETH → ÙSD
- `burn(uint256 amount)` — Partial burn of ÙSD
- `stake(uint256 amount, uint256 poolId)` — Deposit to staking
- `unstake(uint256 poolId)` — Withdraw + rewards (no caps, no cooldown)
- `buyTokenWithETH(address token, uint256 amountETH, bytes path)` — Buy ERC20 with ETH
- `rebalance(address token, uint256 amount, bytes pathToWETH, bytes pathToUSDC)` — 75/25 split rebalance

### Permissionless
- `permissionlessRebalance(address token, uint256 amount, bytes pathToWETH, bytes pathToUSDC)` — Anyone can call if conditions met

## Permissionless Unlock Schedule

**Unlock Conditions (both required):**
1. ROI ≥ 1000% vs weighted average cost
2. No operator rebalance for 14 days since current ROI tier was first reached

**Ratcheted unlock (never decreases):**
- 1000% ROI → 25% unlocked
- Each additional 10% above → 5% of remaining locked unlocks

## Security

- **ReentrancyGuard** on all external-calling functions
- **Checks-Effects-Interactions** pattern throughout
- **SafeERC20** for all token operations
- **balanceOf deltas** for all accounting (handles fee-on-transfer/rebasing)
- **No withdrawals** — tokens can never leave except through defined paths
- **No selling ÙSD** — one-directional flow enforced
- **Circuit breaker** — blocks permissionless if spot >15% above 24h TWAP

## Build & Test

```bash
# Install dependencies
forge install

# Build
forge build

# Test
forge test -vv
```

## Deploy

```bash
# Set environment variables
export PRIVATE_KEY=<deployer_private_key>
export OWNER_ADDRESS=<owner_address>
export OPERATOR_ADDRESS=<operator_address>
export USDC_RECIPIENT_ADDRESS=<usdc_recipient_address>

# Deploy to Base
forge script script/DeployTreasuryManagerV2.s.sol \
    --rpc-url https://mainnet.base.org \
    --broadcast \
    --verify

# Verify on Basescan
forge verify-contract <contract_address> TreasuryManagerV2 \
    --chain-id 8453 \
    --constructor-args $(cast abi-encode "constructor(address,address,address)" $OWNER_ADDRESS $OPERATOR_ADDRESS $USDC_RECIPIENT_ADDRESS) \
    --etherscan-api-key <basescan_api_key>
```

## Contract Prohibitions

- ❌ No withdrawals
- ❌ No selling ÙSD
- ❌ WETH only swaps to ÙSD
- ❌ USDC only swaps to ÙSD via WETH
- ❌ No LP management
- ❌ No changing permissionless parameters
- ❌ ETH only for buying ERC20s
- ❌ ERC20s only to WETH/USDC via rebalance
- ✅ All ÙSD purchases through official pool only

## License

MIT
