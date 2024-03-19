// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Kernal } from "src/Kernal.sol";
import { VaultModule } from "src/Modules/VaultModule.sol";
import { Factory } from "src/Policies/Factory.sol";
import { DeployKernal } from "script/DeployKernal.s.sol";
import { DeployVaultModule } from "script/DeployVaultModule.s.sol";
import { DeployFactory } from "script/DeployFactory.s.sol";
import { DeploySupportMocks } from "script/DeploySupportMocks.s.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { Errors } from "src/utils/Errors.sol";
import { Events } from "src/utils/Events.sol";
import { SafeProxyFactory } from "@safe-contracts/proxies/SafeProxyFactory.sol";
import { SafeL2 } from "@safe-contracts/SafeL2.sol";

contract FactoryTest is Test, HelpersConfig {
    ///////////////////////////////////
    /////// Constants&Immuatbles //////
    ///////////////////////////////////
    bytes32 constant MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");
    bytes32 constant POLICY_ADMIN_ROLE = keccak256("POLICY_ADMIN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; // this is got from the AccessControl contract in OZ

    ChainConfig config;

    Kernal kernal;
    VaultModule vaultModule;
    Factory factory;
    SafeProxyFactory safeFactory;
    SafeL2 safeImp;

    function setUp() public {
        DeployKernal deployKernal = new DeployKernal();
        DeployVaultModule deployVaultModule = new DeployVaultModule();
        DeployFactory deployFactory = new DeployFactory();
        DeploySupportMocks deploySupportMocks = new DeploySupportMocks();

        // Deploy Safe infra
        (safeFactory, safeImp) = deploySupportMocks.deploy();

        // Deply Kernal, Modules and Policies

        kernal = Kernal(deployKernal.deployKernal());
        vaultModule = deployVaultModule.deploy(address(kernal));
        factory = deployFactory.deploy(address(kernal));
        config = getConfig();
        kernal.installModule(address(vaultModule));
        kernal.addPolicy(address(factory));
    }

    function test_createVault() external { }
}
