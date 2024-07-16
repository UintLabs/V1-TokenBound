// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20Target is ERC20 {
    constructor() ERC20("MOCK Token", "MCK") {
        
    }

    function mint( uint _amount) external {
        _mint(msg.sender, _amount);
    }
}