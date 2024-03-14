// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { AccessControl } from "openzeppelin-contracts/access/AccessControl.sol";
import { Module } from "src/abstract/Module/Module.sol";
import { Policy } from "src/abstract/Policy/Policy.sol";
import { Errors } from "src/utils/Errors.sol";
import { Events } from "src/utils/Events.sol";
/////////////////////////////////////////////////////////////////////////////////
//                               Kernel Contract                               //
/////////////////////////////////////////////////////////////////////////////////

/**
 * @title Kernel
 * @notice A registry contract that manages a set of policy and module contracts, as well
 *         as the permissions to interact with those contracts.
 */
contract Kernal is AccessControl {
    ///////////////////////////////////
    /////// Constants&Immuatbles //////
    ///////////////////////////////////
    bytes32 constant public MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");
    bytes32 constant public POLICY_ADMIN_ROLE = keccak256("POLICY_ADMIN_ROLE");

    ///////////////////////////////////
    ///////// State Variables /////////
    ///////////////////////////////////

    mapping(address _moduleAddress => Keycode _keycode) private moduleToKeycode;
    mapping(Keycode _keycode => address _moduleAddress) private keycodeToModule;
    mapping(Keycode _keycode => address[] policies) public moduleDependents;

    // Module <> Policy Permissions. Keycode -> Policy -> Function Selector -> Permission.
    mapping(Keycode => mapping(address _policy => mapping(bytes4 => bool))) private modulePermissions;

    ///////////////////////////////////
    /////////// Constructor ///////////
    ///////////////////////////////////
    constructor(address _defaultAdmin, address _moduleAdmin, address _policyAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(MODULE_ADMIN_ROLE, _moduleAdmin);
        _grantRole(POLICY_ADMIN_ROLE, _policyAdmin);
    }

    ///////////////////////////////////
    /////// External Functions ////////
    ///////////////////////////////////

    /// @notice Install Module
    function installModule(address _module) external onlyRole(MODULE_ADMIN_ROLE) {
        Keycode keycode = Module(_module).KEYCODE();

        // checks if module with this keycode already exists
        if (keycodeToModule[keycode] != address(0)) {
            revert Errors.KeycodeExists(_module, keycode);
        }

        // Updates Variables
        moduleToKeycode[_module] = keycode;
        keycodeToModule[keycode] = _module;

        Module(_module).INIT();

        emit Events.InstalledModule(_module);
    }

    /// @notice Uninstall Module
    function uninstallModule(address _module) external onlyRole(MODULE_ADMIN_ROLE) {
        // checks if module with this module doesn't already exists
        if (Keycode.unwrap(moduleToKeycode[_module]) == bytes5(0)) {
            revert Errors.ModuleDoesntExist(_module);
        }
        Keycode keycode = Module(_module).KEYCODE();
        // Updates Variables
        moduleToKeycode[_module] = Keycode.wrap(0);
        delete keycodeToModule[keycode];

        emit Events.UninstalledModule(_module);
    }

    /// @notice Approves a new Policy
    function addPolicy(address _policy) external onlyRole(POLICY_ADMIN_ROLE) {
        Policy policy = Policy(_policy);
        // CHeck if active already
        if (policy.isActive()) {
            revert Errors.Kernal_PolicyActiveAlready(_policy);
        }
        //Ask for the permissions it needs
        Permission[] memory permissions = policy.requestPermissions();

        //Grant permissions to access modules and their certain functions

        _setPolicyPermissison(_policy, permissions, true);
        // Add Policy to module dependents
        Keycode[] memory dependencies = policy.configureDependencies();
        for (uint256 i = 0; i < dependencies.length; i++) {
            moduleDependents[dependencies[i]].push(_policy);
        }
        // Set status as active

        policy.setActiveStatus(true);
        emit Events.ActivatedPolicy(_policy);
    }

    /// @notice Removes an active policy
    function removePolicy(address _policy) external onlyRole(POLICY_ADMIN_ROLE) {
        Policy policy = Policy(_policy);

        if (!policy.isActive()) {
            revert Errors.Kernal_PolicyInactive(_policy);
        }

        //Ask for the permissions it needs
        Permission[] memory permissions = policy.requestPermissions();

        //Revoke permissions to access modules and their certain functions

        _setPolicyPermissison(_policy, permissions, false);

        //Get the Modules the _policy is dependent on
        Keycode[] memory keycodesUsedByPolicy = policy.configureDependencies();

        // Loop through the keycode/modules the policy is dependent on
        for (uint256 i = 0; i < keycodesUsedByPolicy.length; i++) {
            // Get all the policies that depend on the keycode and cache it
            address[] memory dependentPolicies = moduleDependents[keycodesUsedByPolicy[i]];
            uint256 dependentsLength = dependentPolicies.length;
            // Loop through the dependencies to find the _policy and remove it
            for (uint256 j = 0; j < dependentsLength; j++) {
                address dependentPolicy = dependentPolicies[j];
                if (dependentPolicy == _policy) {
                    dependentPolicies[j] = dependentPolicies[dependentsLength - 1];
                    moduleDependents[keycodesUsedByPolicy[i]] = dependentPolicies;
                    moduleDependents[keycodesUsedByPolicy[i]].pop();
                }
            }
        }

        // Set as Inactive
        policy.setActiveStatus(false);
        emit Events.DeactivatedPolicy(_policy);
    }

    ///////////////////////////////////
    /////// Internal Functions ////////
    ///////////////////////////////////

    function _setPolicyPermissison(address _policy, Permission[] memory _permissions, bool _grant) internal {
        for (uint256 i = 0; i < _permissions.length; i++) {
            Permission memory permission = _permissions[i];
            modulePermissions[permission.keycode][_policy][permission.funcSelector] = _grant;

            emit Events.PermissionUpdated(_policy, permission.keycode, permission.funcSelector, _grant);
        }
    }

    ///////////////////////////////////
    //////// Getter Functions /////////
    ///////////////////////////////////

    function getkeycodeFromModule(address _module) external view returns (Keycode) {
        return moduleToKeycode[_module];
    }

    function getModuleFromKeycode(Keycode _keycode) external view returns (address) {
        return keycodeToModule[_keycode];
    }

    function getModulePermission(Keycode _keycode, address _policy, bytes4 _selector) external view returns (bool) {
        return modulePermissions[_keycode][_policy][_selector];
    }

    function getModuleDependents(Keycode _keycode) external view returns (address[] memory) {
        return moduleDependents[_keycode];
    }
}
