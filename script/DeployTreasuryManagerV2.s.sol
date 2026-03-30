// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {TreasuryManagerV2} from "../src/TreasuryManagerV2.sol";

contract DeployTreasuryManagerV2 is Script {
    function run() external {
        // Read from environment
        address owner = vm.envAddress("OWNER_ADDRESS");
        address operator = vm.envAddress("OPERATOR_ADDRESS");
        address usdcRecipient = vm.envAddress("USDC_RECIPIENT_ADDRESS");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying TreasuryManagerV2...");
        console.log("  Owner:", owner);
        console.log("  Operator:", operator);
        console.log("  USDC Recipient:", usdcRecipient);

        vm.startBroadcast(deployerPrivateKey);

        TreasuryManagerV2 treasury = new TreasuryManagerV2(owner, operator, usdcRecipient);

        vm.stopBroadcast();

        console.log("TreasuryManagerV2 deployed at:", address(treasury));
    }
}
