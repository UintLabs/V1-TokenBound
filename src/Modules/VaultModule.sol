// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Module } from "src/abstract/Module/Module.sol";
import { Errors } from "src/utils/Errors.sol";
import { Events } from "src/utils/Events.sol";
import { AggregatorV3Interface } from "@chainlink/v0.8/interfaces/AggregatorV3Interface.sol";
import { SafeProxyFactory } from "lib/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import { SafeL2 } from "@safe-contracts/SafeL2.sol";

contract VaultModule is Module {
    struct Vault {
        address vaultAddress;
        address owner;
        address guardian;
    }

    bool public isMint;

    AggregatorV3Interface public ethPriceFeed;
    SafeProxyFactory public safeFactory;
    SafeL2 public safeImplementation;
    uint256 public maxStaleDataTime;

    mapping(address user => uint256 nonce) private userToNonce;
    mapping(address vaultAccount => Vault vault) private vaultToDetails;

    constructor(Keycode _keycode, address _kernal) Module(_keycode, _kernal) { }

    modifier onlyModuleAdmin() {
        bool isModuleAdmin = kernal.hasRole(kernal.MODULE_ADMIN_ROLE(), msg.sender);
        _;
    }

    function INIT() external override onlyKernal { }

    function incrementNonce(address user) external permissioned {
        userToNonce[user] += userToNonce[user];
    }

    function addVault(address vaultAccount, address owner, address guardian) external permissioned {
        vaultToDetails[vaultAccount] = Vault(vaultAccount, owner, guardian);
    }

    ///////////////////////////////////
    //////// Setter Functions /////////
    ///////////////////////////////////

    function setIsMint(bool _isMint) external onlyModuleAdmin {
        isMint = _isMint;
        emit Events.Vault_MintSet(_isMint);
    }

    function setMaxStaleDataTime(uint256 _maxStaleDataTime) external onlyModuleAdmin {
        maxStaleDataTime = _maxStaleDataTime;
        emit Events.Vault_MaxStaleDataTimeSet(_maxStaleDataTime);
    }

    function setSafeFactory(address _safeFactory) external onlyModuleAdmin {
        safeFactory = SafeProxyFactory(_safeFactory);
        emit Events.Vault_SafeFactorySet(_safeFactory);
    }

    function setSafeImpl(address _safeImpl) external onlyModuleAdmin {
        safeImplementation = SafeL2(payable(_safeImpl));
    }

    ///////////////////////////////////
    //////// Getter Functions /////////
    ///////////////////////////////////

    function getNonce(address user) external view returns (uint256) {
        return userToNonce[user];
    }

    function getVault(address vaultAddress) external view  returns (Vault memory) {
        return vaultToDetails[vaultAddress];
    }
}
