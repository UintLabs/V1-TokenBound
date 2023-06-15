// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ERC721Holder } from "openzeppelin-contracts/token/ERC721/utils/ERC721Holder.sol";
import { ERC1155Holder } from "openzeppelin-contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract MinimalReceiver is ERC721Holder, ERC1155Holder {
    /**
     * @dev Allows all Ether transfers
     */
    receive() external payable virtual { }
}
