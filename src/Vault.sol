// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC6551Vault } from "src/abstract/ERC6551Vault.sol";
import { ERC4337Account } from "@tokenbound/abstract/ERC4337Account.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { EIP712 } from "openzeppelin-contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IERC6551Account } from "src/interfaces/IERC6551Account.sol";
import { Signatory } from "@tokenbound/abstract/Signatory.sol";

// Errors
error InvalidInput();

/**
 * @title Vault Account Contract
 * @author Nightfallsh4
 * @notice This contract is a ERC6551, ERC4337 and ERC 6900 compatible modular smart account owned with account
 * recovery.
 */
contract Vault is ERC6551Vault, ERC4337Account, ERC721Holder, ERC1155Holder {
  constructor(address _guardian, address _entryPoint) ERC6551Vault(_guardian) ERC4337Account(_entryPoint) {
    if (_guardian == address(0) || _entryPoint == address(0)) {
      revert InvalidInput();
    }
  }

  // Internal Functions

  function _isValidSignature(
    bytes32 hash,
    bytes calldata signature
  ) internal view virtual override(ERC4337Account, Signatory) returns (bool) {
    return splitAndCheckSignature(hash, signature);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC1155Receiver, ERC6551Vault) returns (bool) {
    return
      interfaceId == type(IERC6551Account).interfaceId ||
      interfaceId == type(IERC1155Receiver).interfaceId ||
      super.supportsInterface(interfaceId);
  }


  function owner() public view virtual override returns (address) {}

 
}
