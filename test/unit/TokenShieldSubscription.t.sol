// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { Vault } from "src/Vault.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
import { CreateVault } from "script/CreateVault.s.sol";
import { DeployVault } from "script/DeployVault.s.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { RecoveryManager } from "src/RecoveryManager.sol";

/*//////////////////////////////////////////////////////////////
                                 Errors
    //////////////////////////////////////////////////////////////*/

error NonexistentToken();
error InsuranceNotStarted();
error ZeroAddress();
error InsuranceNotInitiated();
error PriceFeedReturnsZeroOrLess();
error NotEnoughEthSent();
error EthNotWithdrawnSuccessfully();
error TokenShield__NotGuardian();
error TokenShield__NotOwner();
error TokenShield__OwnerCantBeTrustee();

contract TokenShieldSubscriptionTest is Test, HelpersConfig, CreateVault {
    Vault vault;
    // ERC6551Registry registry;
    TokenShieldNft tokenShieldNft;
    RecoveryManager recoveryManager;
    ChainConfig config;

    address vaultMinter = vm.addr(1);
    address trustee = vm.addr(5);

    bytes32 public TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    // Events
    event RecoverySet(uint256 indexed tokenId);

    function setUp() public {
        // Getting the config from helpersConfig for the chain
        config = getConfig();

        // Initializing the Deply Scripts
        DeployVault deploy = new DeployVault();

        // Deploying and creating Vaults, TokenShieldNFT etc.
        (
            address _registry,
            /**
             * address _guardian
             */
            ,
            address _tokenShieldNft,
            address _vaultImpl,
            address _recoveryManager
        ) = deploy.deploy();
        tokenShieldNft = TokenShieldNft(_tokenShieldNft);

        vm.startPrank(config.contractAdmin);
        vm.deal(config.contractAdmin, 100 ether);
        address vaultAddress = createVault(_tokenShieldNft, _registry, _vaultImpl, _recoveryManager);
        tokenShieldNft.grantRole(TRANSFER_ROLE, _recoveryManager);
        vm.stopPrank();
        vault = Vault(payable(vaultAddress));
        // Defining the deployed contracts
    }

    function testTokenSetCorrectly() external {
        (uint256 chainId, address tokenAddress, uint256 tokenId) = vault.token();
        assertEq(tokenId, 0); // since the first NFT token ID is gonna be 0
        assertEq(chainId, block.chainid);
        assertEq(tokenAddress, address(tokenShieldNft));
    }

    function testSetRecovery__RequireMintedReverted() external {
        (,, uint256 tokenId) = vault.token();
        vm.expectRevert("ERC721: invalid token ID");
        tokenShieldNft.setRecovery(tokenId + 1, trustee);
    }

    function testSetRecovery__NotOwner() external {
        (,, uint256 tokenId) = vault.token();
        vm.expectRevert(TokenShield__NotOwner.selector);
        tokenShieldNft.setRecovery(tokenId, trustee);
    }

    function testSetRecovery__OwnerCantBeTrustee() external {
        (,, uint256 tokenId) = vault.token();
        address owner = vault.owner();
        vm.expectRevert(TokenShield__OwnerCantBeTrustee.selector);
        hoax(owner, 10 ether);
        tokenShieldNft.setRecovery(tokenId, owner);
    }

    function testSetRecovery__tokenIdToTrusteeSet() external {
        (,, uint256 tokenId) = vault.token();
        address owner = vault.owner();
        hoax(owner, 10 ether);
        tokenShieldNft.setRecovery(tokenId, trustee);
        address actualTrustee = tokenShieldNft.tokenIdToTrustee(tokenId);
        assertEq(actualTrustee, trustee);
    }

    function testSetRecovery__EmitEvent() external {
        (,, uint256 tokenId) = vault.token();
        address owner = vault.owner();
        hoax(owner, 10 ether);
        vm.expectEmit(true, false, false, false);
        emit RecoverySet(tokenId);
        tokenShieldNft.setRecovery(tokenId, trustee);
    }
}
