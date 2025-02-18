// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { ERC1967Proxy } from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Proxy is ERC1967Proxy {
    constructor(address _implementationAddress, bytes memory data) ERC1967Proxy(_implementationAddress, data) { }
}
