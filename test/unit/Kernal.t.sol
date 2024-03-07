// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.19;

import { Test, console2 } from "forge-std/Test.sol";
import {Kernal} from "src/Kernal.sol";
import {DeployKernal} from "script/DeployKernal.s.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import {Errors} from "src/utils/Errors.sol";

contract KernalTest is HelpersConfig{
    
    ///////////////////////////////////
    /////// Constants&Immuatbles //////
    ///////////////////////////////////
    bytes32 constant MODULE_ADMIN_ROLE = keccak256("MODULE_ADMIN_ROLE");
    bytes32 constant POLICY_ADMIN_ROLE = keccak256("POLICY_ADMIN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; // this is got from the AccessControl contract in OZ

    Kernal kernal;

    function setUp() public {
        DeployKernal deployKernal = new DeployKernal();

        kernal = Kernal(deployKernal.deployKernal());
    }


    function test_initializedCorrectly() external view {
        ChainConfig memory config = getConfig();
        assert(kernal.hasRole(MODULE_ADMIN_ROLE, config.moduleAdmin));
        assert(kernal.hasRole(DEFAULT_ADMIN_ROLE, config.defaultAdmin));
        assert(kernal.hasRole(POLICY_ADMIN_ROLE, config.policyAdmin));
    }

    function test_installsModuleCorrectly() external {
        
    }


}