// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Module } from "src/abstract/Module/Module.sol";
import { Errors } from "src/utils/Errors.sol";
import { Events } from "src/utils/Events.sol";
import { AggregatorV3Interface } from "@chainlink/v0.8/interfaces/AggregatorV3Interface.sol";
import { SafeProxyFactory } from "lib/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";

contract VaultModule is Module {
    bool public isMint;

    AggregatorV3Interface public ethPriceFeed;
    SafeProxyFactory public safeFactory;
    uint public maxStaleDataTime;

    constructor(Keycode _keycode, address _kernal) Module(_keycode, _kernal) { }

    modifier onlyModuleAdmin() {
        bool isModuleAdmin = kernal.hasRole(kernal.MODULE_ADMIN_ROLE(), msg.sender);
        _;
    }

    function INIT() external override onlyKernal { }

    function addVault() external { }

    ///////////////////////////////////
    //////// Setter Functions /////////
    ///////////////////////////////////

    function setIsMint(bool _isMint) external onlyModuleAdmin {
        isMint = _isMint;
        emit Events.Vault_MintSet(_isMint);
    }

    function setMaxStaleDataTime(uint _maxStaleDataTime)  external onlyModuleAdmin {
        maxStaleDataTime = _maxStaleDataTime;
        emit Events.Vault_MaxStaleDataTimeSet(_maxStaleDataTime);
    }

    ///////////////////////////////////
    //////// Getter Functions /////////
    ///////////////////////////////////
}
