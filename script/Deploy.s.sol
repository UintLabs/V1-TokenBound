// SPDX-License-Identifier: GPL-v3
pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { MockRegistry } from "safe7579/test/mocks/MockRegistry.sol";
import { TokenshieldSafe7579 } from "src/TokenshieldSafe7579.sol";
import { Safe7579Launchpad } from "safe7579/src/Safe7579Launchpad.sol";
import { BlockGuardSetter } from "src/guard/BlockGuardSetter.sol";
import { BlockSafeGuard } from "src/guard/BlockSafeGuard.sol";
import { GuardianValidator } from "src/modules/GuardianValidator.sol";
import { RecoveryModule } from "src/modules/RecoveryModule.sol";
import { MockERC20Target } from "../test/unit/mocks/MockERC20Target.sol";
import { BaseSetup } from "test/unit/BaseSetup.t.sol";
import { IERC7484 } from "safe7579/src/interfaces/IERC7484.sol";
import { IEntryPoint } from "account-abstraction/interfaces/IEntryPoint.sol";
import { Safe } from "@safe-global/safe-contracts/contracts/Safe.sol";
import { SafeProxyFactory } from "@safe-global/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import { TokenshieldKernal } from "src/TokenshieldKernal.sol";

contract Deploy is Script, BaseSetup {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        deployContracts();
        vm.stopBroadcast();
    }

    function deployContracts() internal {
        entrypoint = IEntryPoint(0x0000000071727De22E5E9d8BAf0edAc6f37da032);
        // ERC7484 Registry for ERC7579
        registry = new MockRegistry{ salt: "12345" }();

        // ERC7579 Adapter for Safe
        tsSafe = new TokenshieldSafe7579{ salt: "12345" }();
        launchpad = new Safe7579Launchpad{ salt: "12345" }(address(entrypoint), IERC7484(address(registry)));
        singleton = new Safe{ salt: "12345" }();
        safeProxyFactory = new SafeProxyFactory{ salt: "12345" }();
        // Setting Up Guard and guard Setter
        guardSetter = new BlockGuardSetter{ salt: "12345" }();
        blockSafeGuard = new BlockSafeGuard{ salt: "12345" }();

        // Create Kernal
        kernal = new TokenshieldKernal(defaultAdmin.addr, mfaSetterAdmin.addr);

        // Create Guardian Validator
        defaultValidator = new GuardianValidator{ salt: "12345" }(address(kernal));

        // Initialise GuardianValidator
        setGuardiansForGuardianValidator(address(defaultValidator), guardian1);

        // create executor
        defaultExecutor = new RecoveryModule{ salt: "12345" }(address(kernal));

        target = new MockERC20Target{ salt: "12345" }();
    }

    // function setGuardiansForGuardianValidator(address _validator, Account memory _guardian) public virtual {
    //     // Initialise Validator
    //     address[] memory guardians = new address[](1);
    //     guardians[0] = _guardian.addr;

    //     bool[] memory isEnabled = new bool[](1);
    //     isEnabled[0] = true;
    //     GuardianValidator(_validator).setGuardian(guardians, isEnabled);
    // }
}
