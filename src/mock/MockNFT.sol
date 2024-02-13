// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721 } from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import { Ownable } from "openzeppelin-contracts/access/Ownable.sol";

contract MockNFT is ERC721, Ownable {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) { }

    function _baseURI() internal pure override returns (string memory) {
        return "https://tokenshield.io";
    }

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
