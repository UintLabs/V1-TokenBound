// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Script } from "forge-std/Script.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
// import {Kernal} from "src/Kernal.sol";
import { VaultModule } from "src/Modules/VaultModule.sol";

contract DeployVaultModule is Script, HelpersConfig {
    function run() external returns (VaultModule vaultModule) {
        vaultModule = deploy(0xaC062861Bb27Ee2Fdd7D2CC9C64B1c5538C914b4);
    }

    function deploy(address _kernal) public returns (VaultModule vaultModule) {
        ChainConfig memory config = getConfig();

        vaultModule = new VaultModule{salt:"1"}(config.vaultModuleKeycode, _kernal);
    }
}
