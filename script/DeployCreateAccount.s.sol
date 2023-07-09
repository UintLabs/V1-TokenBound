// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { Deploy } from "script/Deploy.s.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { InsureaBag as InsureaBagNft } from "src/InsureaBag.sol";
import { IABAccount } from "src/IABAccount.sol";

contract DeployCreateAccount is Script {
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address guardianSigner = vm.addr(2);
    address guardianSetter = vm.addr(3);
    address user1 = vm.addr(4);

    function run() external {
        Deploy deployer = new Deploy();
        vm.startBroadcast();
        (
            ERC6551Registry registry,
            EntryPoint entryPoint,
            IABGuardian guardian,
            InsureaBagNft nftPolicy,
            IABAccount accountImpl
        ) = deployer.deploy();
        nftPolicy.toggleMint();
        nftPolicy.setImplementationAddress(address(accountImpl));
        nftPolicy.setRegistryAddress(address(registry));
        nftPolicy.createInsurance();
        vm.stopBroadcast();
    }
}
