// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;


import { BaseSetup } from "./BaseSetup.t.sol";

contract TokenshieldSafe7579Test is BaseSetup {
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
}
