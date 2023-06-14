// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721 } from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import { Ownable } from "openzeppelin-contracts/access/Ownable.sol";

contract MockNFT is ERC721, Ownable {
    constructor() ERC721("MOCK", "MCK") { }

    function _baseURI() internal pure override returns (string memory) {
        return "BAMBA";
    }

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
