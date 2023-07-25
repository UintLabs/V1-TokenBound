// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { Deploy } from "script/Deploy.s.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { InsureaBag as InsureaBagNft } from "src/InsureaBag.sol";
import { IABAccount } from "src/IABAccount.sol";
import {console} from "forge-std/console.sol";
import { ERC1967Proxy } from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Strings } from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {Vm, VmSafe} from "forge-std/Vm.sol";

contract DeployCreateAccount is Script {
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address guardianSigner = vm.addr(2);
    address guardianSetter = vm.addr(3);
    address user1 = vm.addr(4);

    function run() external {
        // Deploy deployer = new Deploy();
        vm.startBroadcast();
        (
            ERC6551Registry registry,
            EntryPoint entryPoint,
            IABGuardian guardian,
            InsureaBagNft nftPolicy,
            IABAccount accountImpl
        ) = deploy();
        nftPolicy.toggleMint();
        nftPolicy.setImplementationAddress(address(accountImpl));
        nftPolicy.setRegistryAddress(address(registry));
        vm.recordLogs();
        nftPolicy.createInsurance();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        address tbAccount = abi.decode(entries[1].data, (address));
        console.log(tbAccount);
        writeLatestFile(registry, entryPoint, guardian, nftPolicy, accountImpl, tbAccount);
        console.log("Finishing transaction.....");
        vm.stopBroadcast();
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
        return (registry, entryPoint, iabGuardian, nftPolicy, accountImpl);
    }

    function writeLatestFile(
        ERC6551Registry registry,
        EntryPoint entryPoint,
        IABGuardian iabGuardian,
        InsureaBagNft nftPolicy,
        IABAccount accountImpl,
        address tbAccount
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
        string memory tbAccountTxt =
            string.concat('"tbAccount"', ":", '"', Strings.toHexString(address(tbAccount)), '"');
        vm.writeFile(
            string.concat(root, "/deployments/latestWithAccount.json"),
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
                ",",
                tbAccountTxt,
                "}"
            )
        );
    }
}
