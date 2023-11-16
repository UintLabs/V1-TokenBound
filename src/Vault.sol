// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC6551Vault } from "src/abstract/ERC6551Vault.sol";
import { ERC4337Account } from "@tokenbound/abstract/ERC4337Account.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { EIP712 } from "openzeppelin-contracts/utils/cryptography/EIP712.sol";

/**
 * @title Vault Account Contract
 * @author Nightfallsh4
 * @notice This contract is a ERC6551, ERC4337 and ERC 6900 compatible modular smart account owned with account
 * recovery.
 */
contract Vault is ERC6551Vault, ERC4337Account, ERC721Holder, ERC1155Holder{
    // Errors
    error InvalidInput();

    // Storage Variables
    address immutable s_guardian;
    address immutable s_entryPoint;

    constructor(address _guardian, address _entryPoint) ERC4337Account(_entryPoint) {
        if (_guardian == address(0) || _entryPoint == address(0)) {
            revert InvalidInput();
        }
        s_guardian = _guardian;
    }

    // Internal Functions

    /**
     * @dev Returns true if a given signer is authorized to use this account
     */
    function _isValidSigner(address signer, bytes memory) internal view override returns (bool) { }
}
