// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { FileHelpers } from "script/helpers/FileHelpers.s.sol";
import { ERC6551Registry } from "@erc6551/ERC6551Registry.sol";
import { TokenShieldGuardian as Guardian } from "src/TokenShieldGuardian.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
import { Vault } from "src/Vault.sol";
import { MockAggregatorV3 } from "src/mock/MockPriceFeeds.sol";
import { ERC1967Proxy } from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Vm } from "forge-std/Vm.sol";

contract CreateVault is Script, HelpersConfig, FileHelpers {
    function run() external returns (address createdVault) {
        uint256 privateKey;
        address tokenShieldNftAddress = 0x7C2562c8eC021c82E51E7C6737d3F613026e263d;
        address erc6551RegistryAddress = 0xf8666e5042139b90670b5548BFBeCd61b9a45897;
        address vaultImplAddress = 0xd2B513C2fC13C200c2f9E080C5b99fb5897F7E3e;
        address recoveryManager = address(0);
        if (chainId == 11_155_111) {
            privateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        } else {
            privateKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(privateKey);
        createdVault = createVault(tokenShieldNftAddress, erc6551RegistryAddress, vaultImplAddress, recoveryManager);
        vm.stopBroadcast();
    }

    function createVault(
        address _tokenShieldNftAddress,
        address _erc6551RegistryAddress,
        address _vaultImplAddress,
        address _recoveryManager
    )
        public
        returns (address createdVault)
    {
        TokenShieldNft tokenShieldNft = TokenShieldNft(_tokenShieldNftAddress);
        bool isMintInitiated = tokenShieldNft.initiatedMint();

        if (!isMintInitiated) {
            tokenShieldNft.setRegistryAddress(_erc6551RegistryAddress);
            tokenShieldNft.setRecoveryManager(_recoveryManager);
            tokenShieldNft.setImplementationAddress(_vaultImplAddress);
            tokenShieldNft.toggleMint();
        }
        createdVault = _createVault(tokenShieldNft);
    }

    function _createVault(TokenShieldNft tokenShieldNft) internal returns (address createdVault) {
        vm.recordLogs();
        tokenShieldNft.createSubscription{ value: 0.0012 ether }();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        createdVault = abi.decode(entries[1].data, (address));
    }
}
