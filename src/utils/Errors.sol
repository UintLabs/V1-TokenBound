// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "src/utils/AccessStructs.sol";

library Errors {
    
    error KeycodeExists(address _module, Keycode keycode);
    error NotFromKernal();
    error ModuleDoesntExist(address _module);
    error Policy_ModuleDoesNotExist(Keycode keycode);
    error Kernal_PolicyActiveAlready(address policy);
    error Kernal_PolicyInactive(address policy);
}