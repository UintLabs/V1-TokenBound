// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import "src/utils/AccessStructs.sol";

contract HelpersConfig is Script {
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

    struct ChainConfig {
        address defaultAdmin;
        address moduleAdmin;
        address policyAdmin;
        Keycode vaultModuleKeycode;
        address guardianSigner;
        address guardianSetter;
        address accountRecoveryManager;
        address ethPriceFeed;
        address automationRegistry;
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
        if (chainId == 11_155_111) {
            config = getSepoliaConfig();
        }

        return config;
    }

    function getAnvilConfig() internal pure returns (ChainConfig memory) {
        return ChainConfig({
            defaultAdmin: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            moduleAdmin: vm.addr(5),
            policyAdmin: vm.addr(6),
            vaultModuleKeycode: Keycode.wrap("VTM"),
            guardianSigner: vm.addr(2),
            guardianSetter: vm.addr(3),
            accountRecoveryManager: vm.addr(4),
            ethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            automationRegistry: 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad,
            domainName: "TokenShield",
            domainVersion: "1"
        });
    }

    function getSepoliaConfig() internal view returns (ChainConfig memory) {
        address adminAddress = vm.envAddress("SEPOLIA_DEFAULT_ADMIN_ADDRESS");
        address guardSigner = vm.envAddress("SEPOLIA_GUARDIAN_SIGNER");
        address guardSetter = vm.envAddress("SEPOLIA_GUARDIAN_SETTER");
        return ChainConfig({
            defaultAdmin: adminAddress,
            moduleAdmin: vm.addr(5),
            policyAdmin: vm.addr(6),
            vaultModuleKeycode: Keycode.wrap("VTM"),
            guardianSigner: guardSigner,
            guardianSetter: guardSetter,
            accountRecoveryManager: vm.addr(4),
            ethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            automationRegistry: 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad,
            domainName: "TokenShield",
            domainVersion: "1"
        });
    }
}
