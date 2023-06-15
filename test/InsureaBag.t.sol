// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "prb-test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { InsureaBag } from "src/InsureaBag.sol";
import { IERC6551Registry } from "src/interfaces/IERC6551Registry.sol";
import { ERC6551Registry } from "src/ERC6551/ERC6551Registry.sol";
import { InsuranceAccount } from "src/InsuranceAccount.sol";
import { IERC721 } from "openzeppelin-contracts/token/ERC721/IERC721.sol";

import { Proxy } from "src/Proxy.sol";
import { AccountProxy } from "src/AccountProxy.sol";
import { MockNFT } from "src/mock/MockNFT.sol";

contract InsureaBagTest is PRBTest, StdCheats {
    InsureaBag public insregistry;
    ERC6551Registry public registry;
    InsuranceAccount public accimplementation;
    Proxy public proxy;
    AccountProxy public accproxy;
    address public admin = address(1);

    function setUp() public {
        InsureaBag iab = new InsureaBag();
        registry = new ERC6551Registry();
        accimplementation = new InsuranceAccount();
        accproxy = new AccountProxy(address(accimplementation));
        proxy = new Proxy(address(iab),abi.encodeWithSelector(iab.initialize.selector, "InsureaBag", "IAB", admin));
        insregistry = InsureaBag(address(proxy));
    }

    function testDeloyment() public {
        vm.prank(admin);
        insregistry.setImplementationAddress(address(accproxy));
        vm.prank(admin);
        insregistry.setRegistryAddress(address(registry));

        vm.prank(admin);
        insregistry.createInsurance();
        assertEq(insregistry.ownerOf(0), admin);
    }

    // function testDeploymentMockNFT() public {
    //     assertEq(sampleNFT.name(), "MOCK");
    //     assertEq(sampleNFT.symbol(), "MCK");
    // }

    // function testERC721tokenTransferThroughContract() public {
    //     nftContract.setImplementationAddress(address(implementation));
    //     nftContract.setRegistryAddress(address(registry));

    //     vm.prank(address(10));
    //     nftContract.createInsurance();
    //     assertEq(nftContract.ownerOf(0), address(10));

    //     vm.prank(address(10));
    //     sampleNFT.safeMint(address(10), 1);
    //     assertEq(sampleNFT.ownerOf(1), address(10));

    //     vm.prank(address(10));
    //     sampleNFT.approve(address(nftContract), 1);

    //     vm.prank(address(nftContract));
    //     nftContract.transferERC721token(address(sampleNFT), 0, 1);
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
