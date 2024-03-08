// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import {Kernal} from "src/Kernal.sol";


contract DeployKernal is Script, HelpersConfig{
    
    
    function run() external  returns (address kernal) {
        kernal = deployKernal();
    }

    function deployKernal() public  returns (address) {
        ChainConfig memory config = getConfig();
        Kernal kernal = new Kernal{salt:"1"}(config.defaultAdmin, config.moduleAdmin, config.policyAdmin);

        return address(kernal); 
    }
}
