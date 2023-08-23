// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";

contract HelpersConfig is Script {
    struct ChainConfig {
        address contractAdmin;
        address guardianSigner;
        address guardianSetter;
        string domainName;
        string domainVersion;
    }

    // ChainConfig private config;
    uint256 public chainId;

    constructor() {
        chainId = block.chainid;
    }

    function getConfig() public view returns (ChainConfig memory) {
        ChainConfig memory config;
        if (chainId == 31_337) {
            config = getAnvilConfig();
        }
        if (chainId == 11155111) {
            config = getSepoliaConfig();
        }

        return config;
    }

    function getAnvilConfig() internal pure returns (ChainConfig memory) {
        return ChainConfig({
            contractAdmin: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            guardianSigner: vm.addr(2),
            guardianSetter: vm.addr(3),
            domainName: "TokenShield",
            domainVersion: "1"
        });
    }

    function getSepoliaConfig() internal view returns (ChainConfig memory) {
        address adminAddress = vm.envAddress("SEPOLIA_ADMIN_ADDRESS");
        address guardSigner = vm.envAddress("SEPOLIA_GUARDIAN_SIGNER");
        address guardSetter = vm.envAddress("SEPOLIA_GUARDIAN_SETTER"); 
        return ChainConfig({
            contractAdmin: adminAddress,
            guardianSigner: guardSigner,
            guardianSetter: guardSetter,
            domainName: "TokenShield",
            domainVersion: "1"
        });
    }
}
