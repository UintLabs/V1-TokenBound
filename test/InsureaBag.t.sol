// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { PRBTest } from "prb-test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { InsureaBag } from "src/InsureaBag.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { Proxy } from "src/proxies/Proxy.sol";
import { AccountProxy } from "src/proxies/AccountProxy.sol";
import { MockNFT } from "src/mock/MockNFT.sol";
import { AccountGuardian } from "src/AccountGuardian.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { IABAccount } from "src/IABAccount.sol";

contract InsureaBagTest is PRBTest, StdCheats {
    InsureaBag public nftContract;
    Proxy public proxy;
    IABAccount public account;
    AccountProxy public accproxy;
    EntryPoint public entrypoint;
    AccountGuardian public guardian;
    MockNFT public sampleNFT;
    ERC6551Registry public registry;

    address admin = address(1);
    address public implementation;

    function setUp() public {
        //Set-up of InsureaBag implementation contract
        InsureaBag iab = new InsureaBag();
        proxy = new Proxy(address(iab),abi.encodeWithSelector(iab.initialize.selector, "InsureaBag", "IAB", admin));
        nftContract = InsureaBag(address(proxy));

        //Set-up of EntryPoint and Guardian
        guardian = new AccountGuardian();
        entrypoint = new EntryPoint();

        //Set-up of Account
        IABAccount acc = new IABAccount(address(guardian), address(entrypoint));
        implementation = address(acc);
        accproxy = new AccountProxy(address(implementation));

        //Set-up of ERC6551Registry
        registry = new ERC6551Registry();

        //Set-up of MockNFT();
        sampleNFT = new MockNFT();
    }

    function testsetImplementationAddress_Success() public {
        vm.prank(admin);
        nftContract.setImplementationAddress(implementation);
    }

    function testsetImplementationAddress_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftContract.setImplementationAddress(address(implementation));
    }

    function testsetRegistryAddress_Success() public {
        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));
    }

    function testsetRegistryAddress_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftContract.setRegistryAddress(address(registry));
    }

    function testToggleInsurance_Success() public {
        vm.prank(admin);
        nftContract.toggleMint();
        assertEq(nftContract.initiatedMint(), true);
    }

    function testToggleInsurance_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftContract.toggleMint();
    }

    function testSetTokenURI_Success() public {
        vm.prank(admin);
        nftContract.setBaseURI("https://Insureabag");

        vm.prank(admin);
        nftContract.setImplementationAddress(address(implementation));

        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        vm.prank(admin);
        nftContract.toggleMint();

        vm.prank(admin);
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), admin);

        vm.prank(admin);
        assertEq(nftContract.tokenURI(0), "https://Insureabag");
    }

    function testSetTokenURI_Revert() public {
        vm.prank(address(10));
        vm.expectRevert();
        nftContract.setBaseURI("https://Insureabag");
    }

    function testAccountCreation_Success() public {
        vm.prank(admin);
        nftContract.setImplementationAddress(address(implementation));

        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        vm.prank(admin);
        nftContract.toggleMint();

        vm.prank(admin);
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), admin);

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(1), address(10));
    }

    function testERC721TransferToBoundAddress_Success() public {
        vm.prank(admin);
        nftContract.setImplementationAddress(address(implementation));

        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        vm.prank(admin);
        nftContract.toggleMint();

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), address(10));

        vm.prank(address(10));
        sampleNFT.safeMint(address(10), 0);
        assertEq(sampleNFT.ownerOf(0), address(10));

        address tokenAddress = registry.account(implementation, block.chainid, address(nftContract), 0, 0);
        assertEq(IABAccount(payable(tokenAddress)).isAuthorized(address(10)), true);
        assertEq(IABAccount(payable(tokenAddress)).owner(), address(10));

        vm.prank(address(10));
        sampleNFT.safeTransferFrom(address(10), tokenAddress, 0);
        assertEq(sampleNFT.ownerOf(0), tokenAddress);
    }

    function testERC721TransferFromBoundAddress_Success() public {
        vm.prank(admin);
        nftContract.setImplementationAddress(address(implementation));

        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        vm.prank(admin);
        nftContract.toggleMint();

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), address(10));

        vm.prank(address(10));
        sampleNFT.safeMint(address(10), 0);
        assertEq(sampleNFT.ownerOf(0), address(10));

        address tokenAddress = registry.account(implementation, block.chainid, address(nftContract), 0, 0);
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
        vm.prank(admin);
        nftContract.setImplementationAddress(address(implementation));

        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        vm.prank(admin);
        nftContract.toggleMint();

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
            nftContract.createInsurance();
            assertEq(nftContract.ownerOf(i), users[i]);
        }

        for (uint256 i = 0; i < 10_001; i++) {
            vm.prank(users[i], users[i]);
            address tokenAddress = registry.account(implementation, block.chainid, address(nftContract), i, 0);
            assertEq(IABAccount(payable(tokenAddress)).owner(), address(users[i]));
            assertEq(IABAccount(payable(tokenAddress)).isAuthorized(address(users[i])), true);
        }
    }
}
