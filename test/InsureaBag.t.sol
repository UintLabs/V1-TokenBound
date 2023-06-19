// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "prb-test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { InsureaBag } from "src/InsureaBag.sol";
import { IAccountRegistry } from "src/interfaces/IAccountRegistry.sol";
import { AccountRegistry } from "src/registry/AccountRegistry.sol";
import { InsuranceAccount } from "src/InsuranceAccount.sol";
import { IERC721 } from "openzeppelin-contracts/token/ERC721/IERC721.sol";
import { CrossChainExecutorList } from "src/CrossChainExecutorList.sol";

import { Proxy } from "src/Proxy.sol";
import { MockNFT } from "src/mock/MockNFT.sol";

contract InsureaBagTest is PRBTest, StdCheats {
    InsureaBag public nftContract;
    AccountRegistry public registry;
    InsuranceAccount public account;
    CrossChainExecutorList public list;
    Proxy public proxy;
    MockNFT public sampleNFT;
    address admin = address(1);

    function setUp() public {
        InsureaBag iab = new InsureaBag();
        address impAddress = address(iab);
        proxy = new Proxy(impAddress,abi.encodeWithSelector(iab.initialize.selector, "InsureaBag", "IAB", admin));
        nftContract = InsureaBag(address(proxy));

        CrossChainExecutorList chainlist = new CrossChainExecutorList();
        InsuranceAccount insaccount = new InsuranceAccount(address(chainlist));
        registry = new AccountRegistry(address(insaccount));

        sampleNFT = new MockNFT();
    }

    function testERC721ToTokenBoundAddress() public {
        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        address tokenAddress = registry.account(address(nftContract), 0);

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), address(10));
        assertEq(InsuranceAccount(payable(tokenAddress)).owner(), address(10));

        vm.prank(address(10));
        InsuranceAccount(payable(tokenAddress)).addSupportedCollection(address(sampleNFT));

        vm.prank(address(20));
        sampleNFT.safeMint(address(20), 1);
        assertEq(sampleNFT.ownerOf(1), address(20));

        vm.prank(address(20));
        sampleNFT.safeTransferFrom(address(20), tokenAddress, 1);
        assertEq(sampleNFT.ownerOf(1), tokenAddress);
    }

    function testERC721FromTokenBoundAddress() public {
        vm.prank(admin);
        nftContract.setRegistryAddress(address(registry));

        address tokenAddress = registry.account(address(nftContract), 0);

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), address(10));
        assertEq(InsuranceAccount(payable(tokenAddress)).owner(), address(10));

        vm.prank(address(10));
        InsuranceAccount(payable(tokenAddress)).addSupportedCollection(address(sampleNFT));

        vm.prank(address(20));
        sampleNFT.safeMint(address(20), 1);
        assertEq(sampleNFT.ownerOf(1), address(20));

        vm.prank(address(20));
        sampleNFT.safeTransferFrom(address(20), tokenAddress, 1);
        assertEq(sampleNFT.ownerOf(1), tokenAddress);

        vm.prank(tokenAddress);
        sampleNFT.safeTransferFrom(tokenAddress, address(20), 1);
        assertEq(sampleNFT.ownerOf(1), address(20));
    }

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
