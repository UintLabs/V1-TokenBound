// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


import "src/utils/AccessStructs.sol";
import { AccessControl } from "openzeppelin-contracts/access/AccessControl.sol";
import {Module} from "src/abstract/Module/Module.sol";
import {Errors} from "src/utils/Errors.sol";
/////////////////////////////////////////////////////////////////////////////////
//                               Kernel Contract                               //
/////////////////////////////////////////////////////////////////////////////////

/**
 * @title Kernel
 * @notice A registry contract that manages a set of policy and module contracts, as well
 *         as the permissions to interact with those contracts.
 */
contract Kernal is  AccessControl {
    
    ///////////////////////////////////
    /////// Constants&Immuatbles //////
    ///////////////////////////////////
    bytes32 constant MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");
    bytes32 constant POLICY_ADMIN_ROLE = keccak256("POLICY_ADMIN_ROLE");

    ///////////////////////////////////
    ///////// State Variables /////////
    ///////////////////////////////////

    mapping (address _moduleAddress => Keycode _keycode) private moduleToKeycode;
    mapping (Keycode keycode => address _moduleAddress) private keycodeToModule;


    ///////////////////////////////////
    /////////// Constructor ///////////
    ///////////////////////////////////
    constructor(address _defaultAdmin, address _moduleAdmin, address _policyAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(MODULE_ADMIN_ROLE,_moduleAdmin);
        _grantRole(POLICY_ADMIN_ROLE, _policyAdmin);
    }

    ///////////////////////////////////
    /////// External Functions ////////
    ///////////////////////////////////

    /// @notice Install Module
    function installModule(address _module)  external onlyRole(MODULE_ADMIN_ROLE) {
        Keycode keycode = Module(_module).KEYCODE();

        // checks if module with this keycode already exists 
        if (keycodeToModule[keycode] != address(0)) {
            revert Errors.KeycodeExists(_module, keycode);
        }

        // Updates Variables
        moduleToKeycode[_module] = keycode;
        keycodeToModule[keycode] = _module;
        
        Module(_module).INIT();
    }


    /// @notice Approves a new Policy
    // function addPolicy()  returns () {   }

    /// @notice Removes an active policy
    // function removePolicy()  returns () {}

    

    /// @notice Uninstall Module



    ///////////////////////////////////
    //////// Getter Functions /////////
    ///////////////////////////////////

    function getkeycodeFromModule(address _module) external view returns (Keycode) {
        return moduleToKeycode[_module];
    }

    function getModuleFromKeycode(Keycode _keycode) external view  returns (address) {
        return keycodeToModule[_keycode];
    }
}