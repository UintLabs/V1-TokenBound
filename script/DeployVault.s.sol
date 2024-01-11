// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { FileHelpers } from "script/helpers/FileHelpers.s.sol";
import { ERC6551Registry } from "@erc6551/ERC6551Registry.sol";
import { TokenShieldGuardian as Guardian } from "src/TokenShieldGuardian.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
import { Vault } from "src/Vault.sol";
import { RecoveryManager } from "src/RecoveryManager.sol";
import { MockAggregatorV3 } from "src/mock/MockPriceFeeds.sol";
import { ERC1967Proxy } from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { MockAutomation } from "src/mock/MockAutomation.sol";

contract DeployVault is Script, HelpersConfig, FileHelpers {
    address entryPoint = address(6);
    address constant SEPOLIA_AUTOMATION_REGISTRY = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;

    function run() external returns (address, address, address, address, address) {
        uint256 privateKey;
        if (chainId == 11_155_111) {
            privateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        } else {
            privateKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(privateKey);
        (address registry, address guardian, address tokenShieldNft, address vaultImpl, address recoveryManager) = deploy();
        vm.stopBroadcast();
        writeLatestFile(registry, guardian, tokenShieldNft, vaultImpl);
        return (registry, guardian, tokenShieldNft, vaultImpl, recoveryManager);
    }

    function deploy() public returns (address, address, address, address, address) {
        // Getting the appropriate config for the chain
        ChainConfig memory config = getConfig();
        address admin = config.contractAdmin;
        address guardianSigner = config.guardianSigner;
        address guardianSetter = config.guardianSetter;

        ERC6551Registry registry;
        if (chainId == 11_155_111) {
            registry = ERC6551Registry(0x000000006551c19487814612e58FE06813775758);
            config.automationRegistry = SEPOLIA_AUTOMATION_REGISTRY;
        } else {
            registry = new ERC6551Registry{ salt: "655165516551" }();
            MockAggregatorV3 mockPriceFeed = new MockAggregatorV3();
            MockAutomation automationRegistry = new MockAutomation();
            config.ethPriceFeed = address(mockPriceFeed);
            config.automationRegistry = address(automationRegistry);
        }
        Guardian guardian = new Guardian{ salt: "655165516551" }(admin, guardianSigner, guardianSetter);

        TokenShieldNft tokenShieldNftImpl = new TokenShieldNft{ salt: "655165516551" }();
        ERC1967Proxy tokenShieldNftProxy = new ERC1967Proxy{ salt: "655165516551" }(
            address(tokenShieldNftImpl),
            abi.encodeWithSelector(
                tokenShieldNftImpl.initialize.selector,
                "TokenShield",
                "TSD",
                admin,
                config.ethPriceFeed
            )
        );
        Vault vaultImpl = new Vault{ salt: "655165516551" }(address(guardian), address(entryPoint));
        TokenShieldNft tokenShieldNft = TokenShieldNft(address(tokenShieldNftProxy));
        RecoveryManager recoveryManager =
            new RecoveryManager{ salt: "655165516551" }(address(tokenShieldNftProxy), config.automationRegistry, address(guardian));
        return (address(registry), address(guardian), address(tokenShieldNft), address(vaultImpl), address(recoveryManager));
    }
}
