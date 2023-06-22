// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { PRBTest } from "prb-test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { AccountGuardian } from "src/AccountGuardian.sol";

contract AccountGuardianTest is PRBTest, StdCheats {
    AccountGuardian public guardian;

    function setUp() public {
        vm.prank(address(10));
        guardian = new AccountGuardian();
    }

    function testSetTrustedImplementation_Success() public {
        vm.prank(address(10));
        guardian.setTrustedImplementation(address(10), true);
        (bool trusted) = guardian.isTrustedImplementation(address(10));
        assertEq(trusted, true);
    }

    function testSetTrustedImplementation_Revert() public {
        vm.prank(address(20));
        vm.expectRevert(abi.encodePacked("Ownable: caller is not the owner"));
        guardian.setTrustedImplementation(address(10), true);
    }

    function testSetTrustedExecutor_Success() public {
        vm.prank(address(10));
        guardian.setTrustedExecutor(address(10), true);
        (bool trusted) = guardian.isTrustedExecutor(address(10));
        assertEq(trusted, true);
    }

    function testSetTrustedExecutor_Revert() public {
        vm.prank(address(20));
        vm.expectRevert(abi.encodePacked("Ownable: caller is not the owner"));
        guardian.setTrustedExecutor(address(10), true);
    }
}
