// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "src/utils/AccessStructs.sol";
library Events {
    
    event InstalledModule(address indexed _module);
    event UninstalledModule(address indexed _module);
    event ActivatedPolicy(address indexed _policy);
    event DeactivatedPolicy(address indexed _policy);
    event PermissionUpdated(address indexed _policy, Keycode indexed _keycode, bytes4 indexed selector, bool _grant);
}