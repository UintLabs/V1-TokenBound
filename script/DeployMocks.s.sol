// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.19;

// import { Script } from "forge-std/Script.sol";
// import { console } from "forge-std/console.sol";
// import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
// import { MockNFT } from "src/mock/MockNFT.sol";
// import { MockERC20 } from "src/mock/MockERC20.sol";

// contract DeployERC721 is Script, HelpersConfig {
//     function run() external {
//         // Deploy deployer = new Deploy();
//         uint256 privateKey;
//         if (chainId == 11_155_111) {
//             privateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
//         } else {
//             privateKey = vm.envUint("PRIVATE_KEY");
//         }

//         address addressToMint = 0xB721347D2938a5594a12DF5Cc36D598b839Cb98f;
//         vm.startBroadcast(privateKey);
//         MockNFT nft = new MockNFT("Test721", "T721");
//         nft.safeMint(addressToMint, 1);
//         nft.safeMint(addressToMint, 2);
//         nft.safeMint(addressToMint, 3);
//         nft.safeMint(addressToMint, 4);
//         nft.safeMint(addressToMint, 5);
//         vm.stopBroadcast();
//     }
// }

// contract DeployERC20 is Script, HelpersConfig {
//     function run() external {
//         // Deploy deployer = new Deploy();
//         uint256 privateKey;
//         if (chainId == 11_155_111) {
//             privateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
//         } else {
//             privateKey = vm.envUint("PRIVATE_KEY");
//         }

//         address addressToMint = 0xf46beA4c3Ba0455Bf9537282238eabA193851e30;
//         vm.startBroadcast(privateKey);
//         MockERC20 token = new MockERC20();
//         token.mint(addressToMint, 1_000_000);
//         vm.stopBroadcast();
//     }
// }
