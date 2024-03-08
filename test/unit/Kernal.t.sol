// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { Kernal } from "src/Kernal.sol";
import { VaultModule } from "src/Modules/VaultModule.sol";
import { DeployKernal } from "script/DeployKernal.s.sol";
import { DeployVaultModule } from "script/DeployVaultModule.s.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { Errors } from "src/utils/Errors.sol";
import { Events } from "src/utils/Events.sol";

contract KernalTest is Test, HelpersConfig {
    ///////////////////////////////////
    /////// Constants&Immuatbles //////
    ///////////////////////////////////
    bytes32 constant MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");
    bytes32 constant POLICY_ADMIN_ROLE = keccak256("POLICY_ADMIN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; // this is got from the AccessControl contract in OZ

    ChainConfig config;

    Kernal kernal;
    VaultModule vaultModule;

    function setUp() public {
        DeployKernal deployKernal = new DeployKernal();
        DeployVaultModule deployVaultModule = new DeployVaultModule();

        kernal = Kernal(deployKernal.deployKernal());
        vaultModule = deployVaultModule.deploy(address(kernal));
        config = getConfig();
    }

    function test_initializedCorrectly() external view {
        assert(kernal.hasRole(MODULE_ADMIN_ROLE, config.moduleAdmin));
        assert(kernal.hasRole(DEFAULT_ADMIN_ROLE, config.defaultAdmin));
        assert(kernal.hasRole(POLICY_ADMIN_ROLE, config.policyAdmin));
    }

    function test_installsModule_revertsIfNotModuleAdmin() external {
        vm.expectRevert();
        kernal.installModule(address(vaultModule));
    }

    function test_installsModule_correctly() external {
        vm.startPrank(config.moduleAdmin);
        kernal.installModule(address(vaultModule));

        vm.stopPrank();

        Keycode expectedKeycode = config.vaultModuleKeycode;
        address expectedModule = address(vaultModule);

        Keycode actualKeycode = kernal.getkeycodeFromModule(address(vaultModule));
        address actualModule = kernal.getModuleFromKeycode(config.vaultModuleKeycode);

        assert(Keycode.unwrap(actualKeycode) == Keycode.unwrap(expectedKeycode));
        assertEq(expectedModule, actualModule);
    }

    function test_installModule_RevertsIfKeycodeExists() external {
        vm.startPrank(config.moduleAdmin);
        kernal.installModule(address(vaultModule));
        vm.expectRevert(
            abi.encodeWithSelector(Errors.KeycodeExists.selector, address(vaultModule), config.vaultModuleKeycode)
        );
        kernal.installModule(address(vaultModule));
        vm.stopPrank();
    }

    function test_installModule_EmitsEvents() external {
        vm.startPrank(config.moduleAdmin);

        vm.expectEmit(true, true, false, false, address(kernal));
        emit Events.InstalledModule(address(vaultModule));
        kernal.installModule(address(vaultModule));

        vm.stopPrank();
    }

    modifier installModule(address _module) {
        vm.startPrank(config.moduleAdmin);
        kernal.installModule(_module);
        vm.stopPrank();
        _;
    }

    function test_uninstallModule_RevertsIfModuleDoesntExist() external installModule(address(vaultModule)) {
        vm.startPrank(config.moduleAdmin);
        vm.expectRevert(abi.encodeWithSelector(Errors.ModuleDoesntExist.selector,address(25)));
        kernal.uninstallModule(address(25));

        vm.stopPrank();
    }

    function test_uninstallModule_Correctly() external {
        Keycode expectedKeycode = kernal.getkeycodeFromModule(address(vaultModule));
        address expectedModule = address(0);


        vm.startPrank(config.moduleAdmin);
        kernal.installModule(address(vaultModule));
        kernal.uninstallModule(address(vaultModule));
        vm.stopPrank();

        Keycode actualKeycode = kernal.getkeycodeFromModule(address(vaultModule));
        address actualModule = kernal.getModuleFromKeycode(config.vaultModuleKeycode);

        assertEq(expectedModule, actualModule);
        assert(Keycode.unwrap(expectedKeycode) == Keycode.unwrap(actualKeycode));
    }

    function test_uninstallModule_EmitsEvents() external installModule(address(vaultModule)) {
        vm.startPrank(config.moduleAdmin);

        vm.expectEmit(true, true, false, false, address(kernal));
        emit Events.UninstalledModule(address(vaultModule));
        kernal.uninstallModule(address(vaultModule));

        vm.stopPrank();
    }
}
