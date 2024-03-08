// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "src/utils/AccessStructs.sol";

library Errors {
    
    error KeycodeExists(address _module, Keycode keycode);
    error NotFromKernal();
    error ModuleDoesntExist(address _module);
}