// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC6551Account } from "src/interfaces/IERC6551Account.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { Signatory } from "@tokenbound/abstract/Signatory.sol";
import {IERC721} from "openzeppelin-contracts/token/ERC721/IERC721.sol";
import "@erc6551/lib/ERC6551AccountLib.sol";
import {VaultSignatureVerifier} from "./VaultSignatureVerifier.sol";

abstract contract ERC6551Vault is VaultSignatureVerifier, ERC165{
    uint256 _state;

    receive() external payable virtual { }

    constructor(address _guardian) VaultSignatureVerifier(_guardian) {}

    /**
     * @dev See: {IERC6551Account-isValidSigner}
     */
    function isValidSigner(address signer, bytes calldata data) external override view returns (bytes4 magicValue) {
        if (_isValidSigner(signer, data)) {
            return IERC6551Account.isValidSigner.selector;
        }

        return bytes4(0);
    }

    /**
     * @dev See: {IERC6551Account-token}
     */
    function token() public view virtual returns (uint256, address, uint256) {
        bytes memory footer = new bytes(0x60);

        assembly {
            extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
        }

        return abi.decode(footer, (uint256, address, uint256));
    }

    function owner() public view virtual override returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    /**
     * @dev See: {IERC6551Account-state}
     */
    function state() public override view returns (uint256) {
        return _state;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC6551Account).interfaceId || super.supportsInterface(interfaceId);
    }

    function _incrementState() internal {
        _state++;
    }

    /**
     * @dev Returns true if a given signer is authorized to use this account
     */
    function _isValidSigner(address signer, bytes memory data) internal view returns (bool) { 
        if (signer == owner()) {
            return true;
        }
        return false;
    }
}
