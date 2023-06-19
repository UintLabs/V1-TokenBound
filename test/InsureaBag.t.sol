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

    function setUp() public {
        //Set-up of InsureaBag implementation contract
        InsureaBag iab = new InsureaBag();
        proxy = new Proxy(address(iab),abi.encodeWithSelector(iab.initialize.selector, "InsureaBag", "IAB", admin));
        nftContract = InsureaBag(address(proxy));

        //Set-up of EntryPoint and Guardian
        guardian = new AccountGuardian();
        entrypoint = new EntryPoint();

        //Set-up of Account
        IABAccount acc = new IABAccount(address(entrypoint), address(guardian));
        accproxy = new AccountProxy(address(acc));

        //Set-up of ERC6551Registry
        registry = new ERC6551Registry();

        //Set-up of MockNFT();
        sampleNFT = new MockNFT();
    }

    function testAccountCreation_Success() public {
        vm.prank(admin);
        nftContract.setImplementationAddress(address(accproxy));

        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        vm.prank(admin);
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), admin);

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(1), address(10));
    }

    function testERC721TransferToBoundAddress_Success() public {
        vm.prank(admin);
        nftContract.setImplementationAddress(address(accproxy));

        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), address(10));

        address tokenAddress = registry.account(address(accproxy), block.chainid, address(nftContract), 0, 0);
        assertEq(IABAccount(payable(tokenAddress)).owner(), address(nftContract));
    }

    // function testERC721ToTokenBoundAddress() public {
    //     vm.prank(admin);
    //     nftContract.setRegistryAddress(address(registry));

    //     address tokenAddress = registry.account(address(nftContract), 0);

    //     vm.prank(address(10));
    //     nftContract.createInsurance();
    //     assertEq(nftContract.ownerOf(0), address(10));
    //     assertEq(InsuranceAccount(payable(tokenAddress)).owner(), address(10));

    //     vm.prank(address(10));
    //     InsuranceAccount(payable(tokenAddress)).addSupportedCollection(address(sampleNFT));

    //     vm.prank(address(20));
    //     sampleNFT.safeMint(address(20), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(20));

    //     vm.prank(address(20));
    //     sampleNFT.safeTransferFrom(address(20), tokenAddress, 1);
    //     assertEq(sampleNFT.ownerOf(1), tokenAddress);
    // }

    // function testERC721FromTokenBoundAddress() public {
    //     vm.prank(admin);
    //     nftContract.setRegistryAddress(address(registry));

    //     address tokenAddress = registry.account(address(nftContract), 0);

    //     vm.prank(address(10));
    //     nftContract.createInsurance();
    //     assertEq(nftContract.ownerOf(0), address(10));
    //     assertEq(InsuranceAccount(payable(tokenAddress)).owner(), address(10));

    //     vm.prank(address(10));
    //     InsuranceAccount(payable(tokenAddress)).addSupportedCollection(address(sampleNFT));

    //     vm.prank(address(20));
    //     sampleNFT.safeMint(address(20), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(20));

    //     vm.prank(address(20));
    //     sampleNFT.safeTransferFrom(address(20), tokenAddress, 1);
    //     assertEq(sampleNFT.ownerOf(1), tokenAddress);

    //     vm.prank(tokenAddress);
    //     sampleNFT.safeTransferFrom(tokenAddress, address(20), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(20));
    // }

    // function test_ERC721TransferThroughInsureABag() public {
    //     vm.prank(admin);
    //     nftContract.setRegistryAddress(address(registry));

    //     address tokenAddress = registry.account(address(nftContract), 0);

    //     vm.prank(address(10));
    //     nftContract.createInsurance();

    //     vm.prank(address(10));
    //     sampleNFT.safeMint(address(10), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(10));

    //     vm.prank(address(10));
    //     sampleNFT.approve(address(nftContract), 1);

    //     vm.prank(address(nftContract));
    //     nftContract.transferERC721token(address(sampleNFT), 0, 1);
    //     assertEq(sampleNFT.ownerOf(1), tokenAddress);
    // }

    // function testERC721tokenTransferDirectlyThroughNFTContractShouldBeSuccessfull() public {
    //     vm.prank(admin);
    //     nftContract.setRegistryAddress(address(registry));

    //     address tokenAddress = registry.account(address(nftContract), 0);

    //     vm.prank(address(10));
    //     nftContract.createInsurance();

    //     vm.prank(address(10));
    //     sampleNFT.safeMint(address(10), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(10));

    //     vm.prank(address(10));
    //     sampleNFT.safeTransferFrom(address(10), tokenAddress, 1);
    //     assertEq(sampleNFT.ownerOf(1), tokenAddress);
    // }

    // function testCheckAddressThatIsOwnerOfTokenBoundAccount() public {
    //     vm.prank(admin);
    //     nftContract.setRegistryAddress(address(registry));

    //     vm.prank(address(10));
    //     nftContract.createInsurance();
    // }

    // function testERC721tokenTransferThroughContract() public {
    //     vm.prank(admin);
    //     nftContract.setRegistryAddress(address(registry));

    //     address tokenAddress = registry.account(block.chainid, address(nftContract), 0);

    //     vm.prank(address(10));
    //     sampleNFT.safeMint(address(10), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(10));

    //     vm.prank(address(10));
    //     sampleNFT.safeTransferFrom(address(10), tokenAddress, 1);
    //     assertEq(sampleNFT.ownerOf(1), nftContract.getAddressOfInsurance(0));
    // }

    // function testERC721tokenTransferToTokenBoundAddressDirectly() public {
    //     nftContract.setImplementationAddress(address(implementation));
    //     nftContract.setRegistryAddress(address(registry));

    //     vm.prank(address(10));
    //     nftContract.createInsurance();
    //     assertEq(nftContract.ownerOf(0), address(10));

    //     vm.prank(address(10));
    //     sampleNFT.safeMint(address(10), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(10));

    //     vm.prank(address(10));
    //     sampleNFT.transferFrom(address(10), nftContract.getAddressOfInsurance(0), 1);
    //     assertEq(sampleNFT.ownerOf(1), nftContract.getAddressOfInsurance(0));
    // }
}
