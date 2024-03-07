// // SPDX-License-Identifier: LGPL-3.0-only
// pragma solidity ^0.8.19;

// import { Test, console2 } from "forge-std/Test.sol";
// import { Vm } from "forge-std/Vm.sol";
// import { Vault } from "src/Vault.sol";
// import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
// import { CreateVault } from "script/CreateVault.s.sol";
// import { DeployVault } from "script/DeployVault.s.sol";
// import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
// import { ERC6551Registry } from "@erc6551/ERC6551Registry.sol";
// import { EIP712 } from "openzeppelin-contracts/utils/cryptography/EIP712.sol";

// contract VaultSignatureVerifierTest is Test, HelpersConfig, CreateVault, EIP712 {
//     Vault vault;
//     ERC6551Registry registry;
//     TokenShieldNft tokenShieldNft;

//     ChainConfig config;

//     address vaultMinter = vm.addr(1);
//     address nonMinter = vm.addr(5);

//     constructor() EIP712("TokenShield", "1") { }

//     function setUp() public {
//         // Getting the config from helpersConfig for the chain
//         config = getConfig();

//         // Initializing the Deply Scripts
//         DeployVault deploy = new DeployVault();

//         // Deploying and creating Vaults, TokenShieldNFT etc.
//         (
//             address _registry,
//             address _guardian,
//             address _tokenShieldNft,
//             address _vaultImpl,
//             address _recoveryManager
//         ) = deploy.deploy();
//         vm.startPrank(config.contractAdmin);
//         vm.deal(config.contractAdmin, 100 ether);
//         address vaultAddress = createVault(_tokenShieldNft, _registry, _vaultImpl, _recoveryManager);
//         vm.stopPrank();
//         // Defining the deployed contracts
//         vault = Vault(payable(vaultAddress));
//         tokenShieldNft = TokenShieldNft(_tokenShieldNft);
//     }

//     function testOwnerSetCorrectly() external {
//         hoax(vaultMinter, 100 ether);
//         address _vault = _createVault(tokenShieldNft);
//         address actualOwner = Vault(payable(_vault)).owner();
//         assertEq(vaultMinter, actualOwner);
//     }

//     modifier mintVault() {
//         hoax(vaultMinter, 100 ether);
//         address _vault = _createVault(tokenShieldNft);
//         vault = Vault(payable(_vault));
//         _;
//     }

//     function testIsValidSigner() external mintVault {
//         bytes4 returnedValue = vault.isValidSigner(vaultMinter, "");
//         assertEq(returnedValue, vault.isValidSigner.selector);

//         bytes4 returnedValue2 = vault.isValidSigner(nonMinter, "");
//         assertEq(returnedValue2, bytes4(0));
//     }

//     function testIsValidSignature() external mintVault {
//         bytes32 digest = keccak256("Random Hash");

//         // Since the private key of the vaultMinter is 1
//         (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, digest);

//         // Since the private key of the guardianSigner is 2 from HelpersConfig
//         (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);

//         bytes memory signature = abi.encode(v1, r1, s1, v2, r2, s2);
//         bytes4 returnedValue = vault.isValidSignature(digest, signature);
//         assertEq(returnedValue, vault.isValidSignature.selector);
//     }

//     function testIsValidSignatureRevertsWhenWrongSig() public {
//         bytes32 digest = keccak256("Random Hash");

//         // Signing with wrong private key
//         (uint8 v3, bytes32 r3, bytes32 s3) = vm.sign(3, digest);

//         // Since with wrong private key
//         (uint8 v4, bytes32 r4, bytes32 s4) = vm.sign(4, digest);

//         bytes memory signature2 = abi.encode(v3, r3, s3, v4, r4, s4);
//         bytes4 returnedValue2 = vault.isValidSignature(digest, signature2);
//         assertEq(returnedValue2, bytes4(0));
//     }

//     function test_checkForAbiEncode() external {
//         bytes32 digest = keccak256("Random Hash");

//         // Since the private key of the vaultMinter is 1
//         (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, digest);

//         // Since the private key of the guardianSigner is 2 from HelpersConfig
//         (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);

//         bytes memory combinedTogether = abi.encode(v1, r1, s1, v2, r2, s2);

//         bytes memory signature1 = abi.encode(v1, r1, s1);
//         bytes memory signature2 = abi.encode(v2, r2, s2);
//         bytes memory combinedSeperately = abi.encodePacked(signature1, signature2);

//         console2.log("CombinedTogether- ");
//         console2.logBytes(combinedTogether);
//         console2.log("CombinedSeperately- ");
//         console2.logBytes(combinedSeperately);
//         assertEq(combinedSeperately, combinedTogether);
//         bytes memory signature1_1 = abi.encodePacked(r1, s1, v1);

//         console2.log("Signature1_1- ");
//         console2.logBytes(signature1_1);
//     }
// }
