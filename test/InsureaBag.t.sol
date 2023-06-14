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
import { MockNFT } from "src/mock/MockNFT.sol";

contract InsureaBagTest is PRBTest, StdCheats {
    InsureaBag public nftContract;
    ERC6551Registry public registry;
    MockNFT public sampleNFT;
    InsuranceAccount public implementation;
    string public name = "InsureaBag";
    string public symbol = "IAB";
    address public defaultAdmin = address(10);

    function setUp() public {
        InsureaBag iab = new InsureaBag();
        address impAddress = address(iab);

        Proxy proxy = new Proxy(impAddress,
                abi.encodePacked(iab.initialize.selector));

        nftContract = InsureaBag(address(proxy));

        vm.prank(address(2));
        sampleNFT = new MockNFT();

        vm.prank(address(3));
        registry = new ERC6551Registry();

        vm.prank(address(3));
        implementation = new InsuranceAccount(address(3), address(nftContract));
    }

    function testDeploymentMockNFT() public {
        assertEq(sampleNFT.name(), "MOCK");
        assertEq(sampleNFT.symbol(), "MCK");
    }

    function testERC721tokenTransfer() public {
        nftContract.setImplementationAddress(address(implementation));
        nftContract.setRegistryAddress(address(registry));

        vm.prank(address(10));
        nftContract.createInsurance();
        assertEq(nftContract.ownerOf(0), address(10));

        vm.prank(address(10));
        sampleNFT.safeMint(address(10), 1);
        assertEq(sampleNFT.ownerOf(1), address(10));

        vm.prank(address(10));
        sampleNFT.approve(address(nftContract), 1);

        vm.prank(address(nftContract));
        nftContract.transferERC721token(address(sampleNFT), 0, 1);
        assertEq(sampleNFT.ownerOf(1), nftContract.getAddressOfInsurance(0));
    }
}
