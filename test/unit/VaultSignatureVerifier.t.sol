// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { Vault } from "src/Vault.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
import { CreateVault } from "script/CreateVault.s.sol";
import { DeployVault } from "script/DeployVault.s.sol";
import { ERC6551Registry } from "@erc6551/ERC6551Registry.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { Vm } from "forge-std/Vm.sol";

contract VaultSignatureVerifierTest is Test, HelpersConfig, CreateVault {
    Vault vault;
    ERC6551Registry registry;
    TokenShieldNft tokenShieldNft;

    ChainConfig config;

    address vaultMinter = vm.addr(1);
    address defaultAdmin;

    function setUp() public {
        // Getting the config from helpersConfig for the chain
        config = getConfig();

        // Initializing the Deply Scripts
        DeployVault deploy = new DeployVault();

        // Deploying and creating Vaults, TokenShieldNFT etc.
        (address _registry, address _guardian, address _tokenShieldNft, address _vaultImpl) = deploy.deploy();
        vm.startPrank(config.contractAdmin);
        vm.deal(config.contractAdmin, 100 ether);
        address vaultAddress = createVault(_tokenShieldNft, _registry, _vaultImpl);
        vm.stopPrank();
        // Defining the deployed contracts
        vault = Vault(payable(vaultAddress));
        tokenShieldNft = TokenShieldNft(_tokenShieldNft);
    }

    function testOwnerSetCorrectly() public {
        hoax(vaultMinter, 100 ether);
        address _vault = _createVault(tokenShieldNft);
        address actualOwner = Vault(payable(_vault)).owner();
        assertEq(vaultMinter, actualOwner);
    }
}
