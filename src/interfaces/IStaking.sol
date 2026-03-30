// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Interface for the ÙSD Staking Contract
interface IStaking {
    function deposit(uint256 poolId, uint256 amount) external;
    function withdraw(uint256 poolId) external;
    function pendingRewards(uint256 poolId, address user) external view returns (uint256);
    function userInfo(uint256 poolId, address user) external view returns (uint256 amount, uint256 rewardDebt);
}
