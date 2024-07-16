// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.25;

import { IExecutor } from "erc7579/interfaces/IERC7579Module.sol";

contract RecoveryModule is IExecutor {
    mapping (address account => bool) private _isInitialized;
    /**
     * @dev This function is called by the smart account during installation of the module
     *  arbitrary data that may be required on the module during `onInstall`
     * initialization
     *
     * MUST revert on error (i.e. if module is already enabled)
     */
    function onInstall(bytes calldata /**data*/) external {
        _isInitialized[msg.sender] = true;
     }

    /**
     * @dev This function is called by the smart account during uninstallation of the module
     * @param data arbitrary data that may be required on the module during `onUninstall`
     * de-initialization
     *
     * MUST revert on error
     */
    function onUninstall(bytes calldata data) external { }

    /**
     * @dev Returns boolean value if module is a certain type
     * @param moduleTypeId the module type ID according the ERC-7579 spec
     *
     * MUST return true if the module is of the given type and false otherwise
     */
    function isModuleType(uint256 moduleTypeId) external view returns (bool) { }

    /**
     * @dev Returns if the module was already initialized for a provided smartaccount
     */
    function isInitialized(address smartAccount) external view returns (bool) { 
        return _isInitialized[smartAccount];
    }
}
