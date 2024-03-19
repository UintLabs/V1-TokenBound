// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Script } from "forge-std/Script.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { SafeProxyFactory } from "@safe-contracts/proxies/SafeProxyFactory.sol";
import { SafeL2 } from "@safe-contracts/SafeL2.sol";

contract DeploySupportMocks is Script, HelpersConfig {
    function run() external returns (SafeProxyFactory safeFactory, SafeL2 safeImp) {
        vm.startBroadcast();
        (safeFactory, safeImp) = deploy();
        vm.stopBroadcast();
    }

    function deploy() public returns (SafeProxyFactory safeFactory, SafeL2 safeImp) {
        if (block.chainid == 11_155_111) {
            safeFactory = SafeProxyFactory(0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67);
            safeImp = SafeL2(payable(0x29fcB43b46531BcA003ddC8FCB67FFE91900C762));
        } else {
            safeFactory = new SafeProxyFactory();
            safeImp = new SafeL2();
        }
    }
}
