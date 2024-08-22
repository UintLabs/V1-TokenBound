// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC20 } from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import { Ownable } from "openzeppelin-contracts/access/Ownable.sol";

contract MockERC20 is ERC20, Ownable {
    constructor() ERC20("MOCK", "MCK") { }

    function mint(address _mintAddress, uint256 _amount) public {
        _mint(_mintAddress, _amount);
    }
}
