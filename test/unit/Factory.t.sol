// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Kernal } from "src/Kernal.sol";
import { VaultModule } from "src/Modules/VaultModule.sol";
import { Factory } from "src/Policies/Factory.sol";
import { Guardian } from "src/Policies/Guardian.sol";
import { DeployKernal } from "script/DeployKernal.s.sol";
import { DeployVaultModule } from "script/DeployVaultModule.s.sol";
import { DeployFactory } from "script/DeployFactory.s.sol";
import { DeployGuardian } from "script/DeployGuardian.s.sol";
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


    address public vaultMinter = makeAddr("VAULT_MINTER");
    address public vaultGuardian = makeAddr("GUARDIAN");

    ChainConfig config;

    Kernal kernal;
    Guardian guardian;
    VaultModule vaultModule;
    Factory factory;
    SafeProxyFactory safeFactory;
    SafeL2 safeImp;

    function setUp() public {
        DeployKernal deployKernal = new DeployKernal();
        DeployVaultModule deployVaultModule = new DeployVaultModule();
        DeployFactory deployFactory = new DeployFactory();
        DeployGuardian deployGuardian = new DeployGuardian();
        DeploySupportMocks deploySupportMocks = new DeploySupportMocks();

        // Deploy Safe infra
        (safeFactory, safeImp) = deploySupportMocks.deploy();

        // Deply Kernal, Modules and Policies

        kernal = Kernal(deployKernal.deployKernal());
        vaultModule = deployVaultModule.deploy(address(kernal));
        factory = deployFactory.deploy(address(kernal));
        guardian = deployGuardian.deploy(address(kernal));

        config = getConfig();
        vm.startPrank(config.moduleAdmin);
        kernal.installModule(address(vaultModule));
        _moduleSetup();
        vm.stopPrank();
        vm.startPrank(config.policyAdmin);
        kernal.addPolicy(address(factory));
        kernal.addPolicy(address(guardian));
        vm.stopPrank();
    }

    function _moduleSetup() internal {
        vaultModule.setIsMint(true);
        vaultModule.setMaxStaleDataTime(1 days);
        vaultModule.setSafeFactory(address(safeFactory));
        vaultModule.setSafeImpl(address(safeImp));
    }

    function test_createVault_StateUpdated() external {
        uint priorNonce = vaultModule.getNonce(vaultMinter);
        vm.startPrank(vaultMinter);
        address account = factory.createVault(false, guardian);
        vm.stopPrank();
        // Updated Nonce
        uint postNonce = vaultModule.getNonce(vaultMinter);
        assertEq(postNonce, priorNonce+1);

        // Added Vault Details

        VaultModule.Vault memory vaultDetails = vaultModule.getVault(account);

        assertEq(vaultDetails.owner, vaultMinter);
        assertEq(vaultDetails.guardian, guardian);
    }
}
