// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { AccountGuardian } from "src/AccountGuardian.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { InsureaBag as InsureaBagNft } from "src/InsureaBag.sol";
import { IABAccount } from "src/IABAccount.sol";
import { ERC1967Proxy } from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Create2 } from "openzeppelin-contracts/utils/Create2.sol";
import { Strings } from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {console} from "forge-std/console.sol";

contract Deploy is Script {
    using Strings for string;

    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address guardianSigner = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address guardianSetter = vm.addr(3);

    function run() external returns (ERC6551Registry, EntryPoint, IABGuardian, InsureaBagNft, IABAccount) {
        // bytes memory code = registryBytecode;
        vm.startBroadcast();
        (
            ERC6551Registry registry,
            EntryPoint entryPoint,
            IABGuardian iabGuardian,
            InsureaBagNft insureNft,
            IABAccount accountImpl
        ) = deploy();
        vm.stopBroadcast();
        writeLatestFile(registry, entryPoint, iabGuardian, insureNft, accountImpl);
        return (registry, entryPoint, iabGuardian, insureNft, accountImpl);
    }

    function deploy() public returns (ERC6551Registry, EntryPoint, IABGuardian, InsureaBagNft, IABAccount) {
        ERC6551Registry registry = new ERC6551Registry{salt:"6551"}();
        // address registry = Create2.deploy(0,bytes32("0x6551"),keccak256(code));
        EntryPoint entryPoint = new EntryPoint{salt:"6551"}();
        IABGuardian iabGuardian = new IABGuardian{salt:"6551"}(owner,guardianSigner,guardianSetter);
        // ERC1967Proxy guardianProxy =
        // new ERC1967Proxy{salt:"6551"}(address(iabGuardian),
        // abi.encodeWithSelector(accountGuardianImpl.initialize.selector, guardians,2));
        InsureaBagNft insureNftImpl = new InsureaBagNft{salt:"6551"}();
        ERC1967Proxy insureNftProxy =
        new ERC1967Proxy{salt:"6551"}(address(insureNftImpl), abi.encodeWithSelector(insureNftImpl.initialize.selector, "InusreABag","IAB", owner));
        IABAccount accountImpl = new IABAccount{salt:"6551"}(address(iabGuardian),address(entryPoint));
        InsureaBagNft nftPolicy = InsureaBagNft(address(insureNftProxy));
        nftPolicy.toggleMint();
        nftPolicy.setImplementationAddress(address(accountImpl));
        nftPolicy.setRegistryAddress(address(registry));
        nftPolicy.createInsurance();
        console.log("Finishing transaction.....");
        return (registry, entryPoint, iabGuardian, nftPolicy, accountImpl);
    }

    function writeLatestFile(
        ERC6551Registry registry,
        EntryPoint entryPoint,
        IABGuardian iabGuardian,
        InsureaBagNft nftPolicy,
        IABAccount accountImpl
    )
        public
    {
        string memory root = vm.projectRoot();
        string memory registryTxt = string.concat('"registry"', ":", '"', Strings.toHexString(address(registry)), '"');
        string memory entryPointTxt =
            string.concat('"entryPoint"', ":", '"', Strings.toHexString(address(entryPoint)), '"');
        string memory iabGuardianTxt =
            string.concat('"iabGuardian"', ":", '"', Strings.toHexString(address(iabGuardian)), '"');
        string memory nftPolicyTxt =
            string.concat('"nftPolicy"', ":", '"', Strings.toHexString(address(nftPolicy)), '"');
        string memory accountImplTxt =
            string.concat('"accountImpl"', ":", '"', Strings.toHexString(address(accountImpl)), '"');
        vm.writeFile(
            string.concat(root, "/deployments/latest.json"),
            string.concat(
                "{",
                registryTxt,
                ",",
                entryPointTxt,
                ",",
                iabGuardianTxt,
                ",",
                nftPolicyTxt,
                ",",
                accountImplTxt,
                "}"
            )
        );
    }
}
