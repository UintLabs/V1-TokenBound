// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { Proxy } from "src/proxies/Proxy.sol";
import { AccountProxy } from "src/proxies/AccountProxy.sol";
import { MockNFT } from "src/mock/MockNFT.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { IABAccount } from "src/IABAccount.sol";
import { DeployCreateAccount } from "../script/DeployCreateAccount.s.sol";
// import { InsureaBag as InsureaBagNft } from "src/Tokenshield.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";

contract TokenShieldTest is Test, HelpersConfig {
    Proxy public proxy;
    IABAccount public account;
    AccountProxy public accproxy;
    EntryPoint public entrypoint;
    IABGuardian private guardian;
    MockNFT public sampleNFT;
    ERC6551Registry public registry;
    DeployCreateAccount private deployCreate;
    TokenShieldNft private nftPolicy;
    IABAccount private accountImpl;

    MockNFT private nft;

    string constant domainName = "Tokenshield";
    string constant domainVersion = "1";
    address guardianOwner;
    address guardianSigner;
    address guardianSetter;
    address accountOwner = vm.addr(4);
    address receiverAddress = vm.addr(5);
    address accountOwner2 = vm.addr(6);

    function setUp() public {
        deployCreate = new DeployCreateAccount();
        sampleNFT = new MockNFT();
        (registry, entrypoint, guardian, nftPolicy, accountImpl) = deployCreate.deploy();
        ChainConfig memory config = getConfig();
        guardianOwner = config.contractAdmin;
        guardianSigner = config.guardianSigner;
        guardianSetter = config.guardianSetter;
    }

    function testsetImplementationAddress_Success() public {
        vm.prank(guardianOwner);
        vm.deal(guardianOwner, 10 ether);
        nftPolicy.setImplementationAddress(address(accountImpl));
    }

    function testsetImplementationAddress_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftPolicy.setImplementationAddress(address(accountImpl));
    }

    function testsetRegistryAddress_Success() public {
        vm.prank(guardianOwner);
        nftPolicy.setRegistryAddress(address(registry));
    }

    function testsetRegistryAddress_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftPolicy.setRegistryAddress(address(registry));
    }

    function testToggleInsurance_Success() public {
        vm.prank(guardianOwner);
        nftPolicy.toggleMint();
        assertEq(nftPolicy.initiatedMint(), true);
    }

    function testToggleInsurance_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftPolicy.toggleMint();
    }

    function testSetTokenURI_Success() public {
        vm.prank(guardianOwner);
        nftPolicy.setBaseURI("https://tokenshield.io");

        vm.prank(guardianOwner);
        nftPolicy.setImplementationAddress(address(accountImpl));

        vm.prank(guardianOwner);
        nftPolicy.setRegistryAddress(address(registry));

        vm.prank(guardianOwner);
        nftPolicy.toggleMint();

        vm.prank(address(10));
        vm.deal(address(10), 10 ether);
        nftPolicy.createInsurance{ value: 0.000777 ether }();
        assertEq(nftPolicy.ownerOf(0), address(10));

        vm.prank(address(10));
        assertEq(nftPolicy.tokenURI(0), "https://tokenshield.io");
    }

    function testSetTokenURI_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftPolicy.setBaseURI("https://tokenshield.io");
    }

    function testAccountCreation_Success() public {
        vm.prank(guardianOwner);
        nftPolicy.setImplementationAddress(address(accountImpl));

        vm.prank(guardianOwner);
        nftPolicy.setRegistryAddress(address(registry));

        vm.prank(guardianOwner);
        nftPolicy.toggleMint();

        vm.prank(address(20));
        vm.deal(address(20), 10 ether);
        nftPolicy.createInsurance{ value: 0.000777 ether }();
        assertEq(nftPolicy.ownerOf(0), address(20));

        vm.prank(address(10));
        vm.deal(address(10), 10 ether);
        nftPolicy.createInsurance{ value: 0.000777 ether }();
        assertEq(nftPolicy.ownerOf(1), address(10));
    }

    function testERC721TransferToBoundAddress_Success() public {
        vm.prank(guardianOwner);
        nftPolicy.setImplementationAddress(address(accountImpl));

        vm.prank(guardianOwner);
        nftPolicy.setRegistryAddress(address(registry));

        vm.prank(guardianOwner);
        nftPolicy.toggleMint();

        vm.prank(address(10));
        vm.deal(address(10), 10 ether);
        nftPolicy.createInsurance{ value: 0.000777 ether }();
        assertEq(nftPolicy.ownerOf(0), address(10));

        vm.prank(address(10));
        sampleNFT.safeMint(address(10), 0);
        assertEq(sampleNFT.ownerOf(0), address(10));

        // vm.prank(guardianOwner);
        // guardian.setTrustedERC721(address(sampleNFT), true);

        address tokenAddress = registry.account(address(accountImpl), block.chainid, address(nftPolicy), 0, 0);
        assertEq(IABAccount(payable(tokenAddress)).isAuthorized(address(10)), true);
        assertEq(IABAccount(payable(tokenAddress)).owner(), address(10));

        vm.prank(address(10));
        sampleNFT.safeTransferFrom(address(10), tokenAddress, 0);
        assertEq(sampleNFT.ownerOf(0), tokenAddress);
    }

    function testERC721TransferFromBoundAddress_Success() public {
        vm.prank(guardianOwner);
        nftPolicy.setImplementationAddress(address(accountImpl));

        vm.prank(guardianOwner);
        nftPolicy.setRegistryAddress(address(registry));

        vm.prank(guardianOwner);
        nftPolicy.toggleMint();

        vm.prank(address(10));
        vm.deal(address(10), 10 ether);
        nftPolicy.createInsurance{ value: 0.000777 ether }();
        assertEq(nftPolicy.ownerOf(0), address(10));

        vm.prank(address(10));
        sampleNFT.safeMint(address(10), 0);
        assertEq(sampleNFT.ownerOf(0), address(10));

        // vm.prank(guardianOwner);
        // guardian.setTrustedERC721(address(sampleNFT), true);

        address tokenAddress = registry.account(address(accountImpl), block.chainid, address(nftPolicy), 0, 0);
        assertEq(IABAccount(payable(tokenAddress)).isAuthorized(address(10)), true);
        assertEq(IABAccount(payable(tokenAddress)).owner(), address(10));

        vm.prank(address(10));
        sampleNFT.safeTransferFrom(address(10), tokenAddress, 0);
        assertEq(sampleNFT.ownerOf(0), tokenAddress);

        vm.prank(tokenAddress);
        sampleNFT.safeTransferFrom(tokenAddress, address(20), 0);
        assertEq(sampleNFT.ownerOf(0), address(20));
    }

    function testInsuranceMintScenario_Success() public {
        vm.prank(guardianOwner);
        nftPolicy.setImplementationAddress(address(accountImpl));

        vm.prank(guardianOwner);
        nftPolicy.setRegistryAddress(address(registry));

        vm.prank(guardianOwner);
        nftPolicy.toggleMint();

        address[] memory users = new address[](10001);
        for (uint256 i = 0; i < 10_001; i++) {
            bytes memory byteIndex = abi.encodePacked(i);
            string memory addressLabel = string.concat("user", string(byteIndex));

            address user = makeAddr(addressLabel);
            vm.deal(user, 10 ether);
            users[i] = user;
        }

        for (uint256 i = 0; i < 10_001; i++) {
            vm.prank(users[i], users[i]);
            vm.deal(users[i], 10 ether);
            nftPolicy.createInsurance{ value: 0.000777 ether }();
            assertEq(nftPolicy.ownerOf(i), users[i]);
        }

        for (uint256 i = 0; i < 10_001; i++) {
            vm.prank(users[i], users[i]);
            address tokenAddress = registry.account(address(accountImpl), block.chainid, address(nftPolicy), i, 0);
            assertEq(IABAccount(payable(tokenAddress)).owner(), address(users[i]));
            assertEq(IABAccount(payable(tokenAddress)).isAuthorized(address(users[i])), true);
        }
    }

    function testWithdraw() external {
        vm.prank(guardianOwner);
        nftPolicy.setImplementationAddress(address(accountImpl));

        vm.prank(guardianOwner);
        nftPolicy.setRegistryAddress(address(registry));

        vm.prank(guardianOwner);
        nftPolicy.toggleMint();

        vm.prank(address(10));
        vm.deal(address(10), 10 ether);
        nftPolicy.createInsurance{ value: 0.000777 ether }();

        uint256 priorBalance = address(nftPolicy).balance;
        vm.prank(guardianOwner);
        nftPolicy.withdraw(guardianOwner);
        uint256 postBalance = address(nftPolicy).balance;
        assertEq(priorBalance, postBalance + 0.000777 ether);
    }
}
