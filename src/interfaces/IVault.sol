// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "account-abstraction/interfaces/UserOperation.sol";
// Errors

error InvalidInput();

/**
 * @title Vault Account Contract
 * @author Nightfallsh4
 * @notice This contract is a ERC6551, ERC4337 and ERC 6900 compatible modular smart account owned with account
 * recovery.
 */
interface IVault {
    function token() external view returns (uint256, address, uint256);

    /**
     * @dev See: {IERC6551Account-state}
     */
    function state() external view returns (uint256);
    // Internal Functions

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function owner() external view returns (address);

    function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bytes4 magicValue);

    function isValidSigner(address signer, bytes calldata context) external view returns (bytes4 magicValue);

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    )
        external
        returns (uint256 validationData);
}
