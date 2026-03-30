// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Interface for Uniswap Universal Router
interface IUniversalRouter {
    /// @notice Executes encoded commands along with provided inputs
    /// @param commands A set of concatenated commands, each 1 byte
    /// @param inputs An array of byte strings containing abi encoded inputs for each command
    /// @param deadline The deadline by which the transaction must be executed
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
}
