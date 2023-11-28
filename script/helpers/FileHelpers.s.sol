// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { Strings } from "openzeppelin-contracts/utils/Strings.sol";

contract FileHelpers is Script {
    using Strings for string;

    function writeLatestFile(address registry, address guardian, address tokenShieldNft, address vault) public {
        string memory root = vm.projectRoot();
        string memory anvilFilePath = string.concat(root, "/deployments/anvilLatest");
        string memory sepoliaFilePath = string.concat(root, "/deployments/sepoliaLatest");
        /* solhint-disable */
        string memory registryTxt = string.concat("ERC6551Registry-", Strings.toHexString(registry));
        string memory guardianTxt = string.concat("guardian-", Strings.toHexString(guardian));
        string memory tokenShieldNftTxt = string.concat("tokenShieldNft-", Strings.toHexString(tokenShieldNft));
        string memory vaultTxt = string.concat("vault-", Strings.toHexString(vault));
        if (block.chainid == 11_155_111) {
            removeFileIfExists(sepoliaFilePath);
            vm.writeLine(sepoliaFilePath, registryTxt);
            vm.writeLine(sepoliaFilePath, guardianTxt);
            vm.writeLine(sepoliaFilePath, tokenShieldNftTxt);
            vm.writeLine(sepoliaFilePath, vaultTxt);
            vm.closeFile(sepoliaFilePath);
        } else {
            removeFileIfExists(anvilFilePath);
            vm.writeLine(anvilFilePath, registryTxt);
            vm.writeLine(anvilFilePath, guardianTxt);
            vm.writeLine(anvilFilePath, tokenShieldNftTxt);
            vm.writeLine(anvilFilePath, vaultTxt);
            vm.closeFile(anvilFilePath);
        }

        /* solhint-enable */
    }

    function removeFileIfExists(string memory filePath) public {
        vm.writeFile(filePath, "");
    }
}
