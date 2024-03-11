// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Module } from "src/abstract/Module/Module.sol";
import "src/utils/AccessStructs.sol";

contract VaultModule is Module {
    constructor(Keycode _keycode, address _kernal) Module(_keycode, _kernal) { }

    function INIT() external override onlyKernal { }

    function addVault() external  {
        
    }
}
