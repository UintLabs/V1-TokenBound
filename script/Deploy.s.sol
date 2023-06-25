// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { AccountGuardian } from "src/AccountGuardian.sol";
import { InsureaBag as InsureaBagNft } from "src/InsureaBag.sol";
import { IABAccount } from "src/IABAccount.sol";
import { ERC1967Proxy } from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Create2} from "openzeppelin-contracts/utils/Create2.sol";

contract Deploy is Script {
    address eoa1 = address(1);
    address eoa2 = address(2);
    address[] public guardians = [eoa1, eoa2];
   
    function run() external returns(ERC6551Registry, EntryPoint, AccountGuardian,InsureaBagNft, IABAccount){
        // bytes memory code = registryBytecode;
        vm.startBroadcast();
        ERC6551Registry registry = new ERC6551Registry{salt:"6551"}();
        // address registry = Create2.deploy(0,bytes32("0x6551"),keccak256(code));
        EntryPoint entryPoint = new EntryPoint{salt:"6551"}();
        AccountGuardian accountGuardianImpl = new AccountGuardian{salt:"6551"}();
        ERC1967Proxy guardianProxy =
        new ERC1967Proxy{salt:"6551"}(address(accountGuardianImpl), abi.encodeWithSelector(accountGuardianImpl.initialize.selector, guardians,2));
        InsureaBagNft insureNftImpl = new InsureaBagNft{salt:"6551"}();
        IABAccount accountImpl = new IABAccount{salt:"6551"}(address(guardianProxy),address(entryPoint));
        vm.stopBroadcast();
        address guardianProxyAddress = address(guardianProxy);
        AccountGuardian accountGuardian = AccountGuardian(guardianProxyAddress);

        return (registry, entryPoint, accountGuardian, insureNftImpl, accountImpl);
    }
}
