// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;


import { BaseSetup } from "./BaseSetup.t.sol";
import { ExecutionLib } from "erc7579/lib/ExecutionLib.sol";
import { ModeLib } from "erc7579/lib/ModeLib.sol";
import { MockERC20Target } from "./mocks/MockERC20Target.sol";

import "safe7579/test/dependencies/EntryPoint.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IERC7579Account } from "erc7579/interfaces/IERC7579Account.sol";


contract TokenshieldSafe7579Test is BaseSetup {

    Account receiverAddress = makeAccount("RECEIVER_ADDRESS");

    function setUp() public {
        // super.setUp();
        setUpEssentialContracts();
        // Create and Initialise Modules

        createAndInitialseModules();
    }

    function test_IsGuardianValidatorSet() external view {
        bool isEnabled = defaultValidator.isGuardianEnabled(guardian1.addr);
        assert(isEnabled);
    }

    function test_MockERC20_Mint() external {
        setupAccountWithTx();
    }

    modifier setUpAccount {
        // createAndInitialseModules();
        setupAccountWithTx();
        _;
    }

    function test_TestERC20Transfer() setUpAccount external {
        uint256 amountToTransfer = 3 ether;

        uint256 priorBalance = target.balanceOf(address(userAccount));
        // Create calldata for the account to execute
        bytes memory targetCalldata = abi.encodeCall(IERC20.transfer, (receiverAddress.addr, amountToTransfer));

        // Encode the call into the calldata for the userOp
        bytes memory userOpCalldata = abi.encodeCall(
            IERC7579Account.execute,
            (
                ModeLib.encodeSimpleSingle(),
                ExecutionLib.encodeSingle(address(target), uint256(0), targetCalldata)
            )
        );

        PackedUserOperation memory userOp =
            getDefaultUserOp(address(userAccount), address(defaultValidator));

        userOp.initCode = "";
        userOp.callData = userOpCalldata;

        userOp.signature = getSignature(userOp, signer1, guardian1);

        // Create userOps array
        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = userOp;

        // Send the userOp to the entrypoint
        entrypoint.handleOps(userOps, payable(address(0x69)));
        uint256 postBalance = target.balanceOf(address(userAccount));
        assertEq(priorBalance, postBalance + amountToTransfer);

    }
}
