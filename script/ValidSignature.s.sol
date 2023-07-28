// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { ECDSA } from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";
import { AccountGuardian } from "src/AccountGuardian.sol";
import { IERC1271 } from "openzeppelin-contracts/interfaces/IERC1271.sol";
import { IABAccount } from "src/IABAccount.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { InsureaBag as InsureaBagNft } from "src/InsureaBag.sol";
import { Deploy } from "script/Deploy.s.sol";
import {console} from "forge-std/console.sol";

contract ValidSignature is Script {
    using ECDSA for bytes32;
    

    function run() external {
        bytes memory message = "Hello World";
        // address eoa1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        // address eoa2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        uint256 eoaPrivateKey1 = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        uint256 eoaPrivateKey2 = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        // address signer1 = vm.addr(eoaPrivateKey1);
        // address signer2 = vm.addr(eoaPrivateKey2);
        bytes32 hash = keccak256(abi.encodePacked(message));
        bytes32 digest = hash.toEthSignedMessageHash();
        // bytes32 digest = hash;
        console.logBytes32(digest);
        // log(digest);
        // vm.startPrank(signer1);

        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(eoaPrivateKey1, digest);
        // vm.startPrank(signer2);
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(eoaPrivateKey2, digest);
        // vm.stopPrank();
        bytes memory signature1 = abi.encodePacked(r1, s1, v1);
        bytes memory signature2 = abi.encodePacked(r2, s2, v2);
        bytes memory signature = bytes.concat(signature2, signature1);
        IABAccount account = IABAccount(payable(0xa78f1AeD8fBB8Ffd5D8dE874f60F86F78FcEF044));
        // Deploy deployer = new Deploy();
        vm.startBroadcast();
        // (
        //     ERC6551Registry registry,
        //     EntryPoint entryPoint,
        //     IABGuardian guardian,
        //     InsureaBagNft nftPolicy,
        //     IABAccount accountImpl
        // ) = deployer.deploy();
        account.isValidSignature(hash, signature);
        vm.stopBroadcast();
        // AccountGuardian guardian = AccountGuardian(0x300CD264D50946796e9e4abB3DBd2677adEEE249);
        // bytes4 selector = guardian.isValidSignature(hash, signature);
        // bytes4 actualSelector = IERC1271.isValidSignature.selector;
        // bool isValid =  selector == bytes32(IERC1271.isValidSignature.selector);
    }
}
