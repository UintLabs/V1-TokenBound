// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Script } from "forge-std/Script.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { Factory } from "src/Policies/Factory.sol";
import { ERC1967Proxy as Proxy } from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployFactory is Script, HelpersConfig {
    function run() external returns (Factory _factory) {
        vm.startBroadcast();
        _factory = deploy(0xaC062861Bb27Ee2Fdd7D2CC9C64B1c5538C914b4);
        vm.stopBroadcast();
    }

    function deploy(address _kernal) public returns (Factory) {
        Factory _factory = new Factory{salt:"1"}(_kernal);

        Proxy proxy = new Proxy{salt:"1"}(address(_factory), abi.encodePacked(Factory.initialize.selector));

        return Factory(address(proxy));
    }
}
