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
import { console } from "forge-std/console.sol";

contract ValidSignature is Script {
    using ECDSA for bytes32;

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct Tx {
        address to;
        uint256 value;
        uint256 nonce;
        bytes data;
    }

    string constant domainName = "Tokenshield";
    string constant domainVersion = "1";
    bytes32 DOMAIN_SEPARATOR = getDomainHash(
        EIP712Domain({
            name: domainName,
            version: domainVersion,
            chainId: block.chainid,
            verifyingContract: 0x1868F2C16f920C62b42F049c84a1eE976958EE82
        })
    );

    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address guardianSigner = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address guardianSetter = vm.addr(3);

    function run() external {
        // bytes memory message = "Hello World";
        // Tx memory transaction = Tx({ to: owner, value: 1 ether, nonce: 0, data: "" });
        // uint256 eoaPrivateKey1 = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        // uint256 eoaPrivateKey2 = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

        // bytes32 hash = getTransactionHash(transaction);
        // bytes32 digest = getTransactionHashWithDomainSeperator(hash);
        // bytes32 digestMessageHash = digest.toEthSignedMessageHash();

        // console.logBytes32(digest);

        // (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(eoaPrivateKey1, digestMessageHash);

        // (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(eoaPrivateKey2, digestMessageHash);

        // bytes memory signature1 = abi.encodePacked(r1, s1, v1);
        // bytes memory signature2 = abi.encodePacked(r2, s2, v2);
        // bytes memory signature = bytes.concat(signature2, signature1);
        IABAccount account = IABAccount(payable(0xDF64039c42Cf52770c8D9C17A8D4F76A73645958));
        uint256 nonce = account.nonce();
        Tx memory transaction =
            Tx({ to: 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65, value: 1 ether, nonce: nonce, data: "" });
        bytes32 hash = getTransactionHash(transaction);
        bytes32 digest = getTransactionHashWithDomainSeperator(hash);
        // bytes32 digestMessageHash = digest.toEthSignedMessageHash();
        // since 4 is the private key for the accountOwner address, we have 4 passed below
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(vm.envUint("SEPOLIA_PRIVATE_KEY"), digest);
        // since 2 is the private key for the accountOwner address, we have 2 passed below
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(0x2, digest);
        bytes memory signature1 = abi.encodePacked(r1, s1, v1);
        bytes memory signature2 = abi.encodePacked(r2, s2, v2);
        bytes memory signature = bytes.concat(signature2, signature1);
        console.log("Digest Outside- ");
        console.logBytes32(digest);
        console.log("Hash Outside- ");
        console.logBytes32(hash);

        console.log("Signature1-");
        console.logBytes(signature1);
        console.log("Signature1-");
        console.logBytes(signature2);
        console.log("Transaction");
        console.logBytes(transaction.data);
        // console.log(v1);
        // console.logBytes32(r1);
        // console.logBytes32(s1);
        vm.startBroadcast();

        account.isValidSignature(digest, signature);
        vm.stopBroadcast();
    }

    function getDomainHash(EIP712Domain memory domain) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(domain.name)),
                keccak256(bytes(domain.version)),
                domain.chainId,
                domain.verifyingContract
            )
        );
    }

    function getTransactionHash(Tx memory _transaction) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("Tx(address to,uint256 value,uint256 nonce,bytes data)"),
                _transaction.to,
                _transaction.value,
                _transaction.nonce,
                _transaction.data
            )
        );
    }

    function getTransactionHashWithDomainSeperator(bytes32 transactionHash) internal view returns (bytes32) {
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, transactionHash));
        return digest;
    }
}
