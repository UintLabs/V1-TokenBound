// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

abstract contract FileHelpers is Script {
    using Strings for string;

    function writeLatestFile(
        address registry,
        address guardian,
        address tokenShieldNft,
        address vault,
        address recoveryManager
    )
        public
    {
        string memory root = vm.projectRoot();
        string memory anvilFilePath = string.concat(root, "/deployments/anvilLatest");
        string memory sepoliaFilePath = string.concat(root, "/deployments/sepoliaLatest");
        string memory scrollFilePath = string.concat(root, "/deployments/scrollLatest");
        /* solhint-disable */
        string memory registryTxt = string.concat("ERC6551Registry-", Strings.toHexString(registry));
        string memory guardianTxt = string.concat("guardian-", Strings.toHexString(guardian));
        string memory tokenShieldNftTxt = string.concat("tokenShieldNft-", Strings.toHexString(tokenShieldNft));
        string memory vaultTxt = string.concat("vault-", Strings.toHexString(vault));
        string memory recoveryManagerTxt = string.concat("recoveryManager-", Strings.toHexString(recoveryManager));
        if (block.chainid == 11_155_111) {
            removeFileIfExists(sepoliaFilePath);
            vm.writeLine(sepoliaFilePath, registryTxt);
            vm.writeLine(sepoliaFilePath, guardianTxt);
            vm.writeLine(sepoliaFilePath, tokenShieldNftTxt);
            vm.writeLine(sepoliaFilePath, vaultTxt);
            vm.writeLine(sepoliaFilePath, recoveryManagerTxt);
            vm.closeFile(sepoliaFilePath);
        } else if (block.chainid == 534_351) {
            removeFileIfExists(scrollFilePath);
            vm.writeLine(scrollFilePath, registryTxt);
            vm.writeLine(scrollFilePath, guardianTxt);
            vm.writeLine(scrollFilePath, tokenShieldNftTxt);
            vm.writeLine(scrollFilePath, vaultTxt);
            vm.writeLine(scrollFilePath, recoveryManagerTxt);
            vm.closeFile(scrollFilePath);
        } else {
            removeFileIfExists(anvilFilePath);
            vm.writeLine(anvilFilePath, registryTxt);
            vm.writeLine(anvilFilePath, guardianTxt);
            vm.writeLine(anvilFilePath, tokenShieldNftTxt);
            vm.writeLine(anvilFilePath, vaultTxt);
            vm.writeLine(anvilFilePath, recoveryManagerTxt);
            vm.closeFile(anvilFilePath);
        }

        /* solhint-enable */
    }

    function removeFileIfExists(string memory filePath) public {
        vm.writeFile(filePath, "");
    }
}
