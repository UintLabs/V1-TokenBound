// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Script } from "forge-std/Script.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { Guardian } from "src/Policies/Guardian.sol";
import { ERC1967Proxy as Proxy } from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployGuardian is Script, HelpersConfig {
    function run() external returns (Guardian guardian) {
        vm.startBroadcast();
        guardian = deploy(0xaC062861Bb27Ee2Fdd7D2CC9C64B1c5538C914b4);
        vm.stopBroadcast();
    }

    function deploy(address _kernal) public returns (Guardian guardian) {
        guardian = new Guardian{salt:"1"}(_kernal);

        Proxy proxy = new Proxy{salt:"1"}(address(guardian), abi.encodePacked(guardian.initialize.selector));

        return Guardian(address(proxy));
    }
}
