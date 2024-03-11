// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Kernal } from "src/Kernal.sol";
import { Errors } from "src/utils/Errors.sol";

abstract contract Policy {
    
    Kernal immutable kernal;
    
    
    Keycode[] private keycodeDependency;
    bool public isActive;

    modifier onlyKernal() {
        if (msg.sender != address(kernal)) {
            revert Errors.NotFromKernal();
        }
        _;
    }

    constructor(address _kernal) {
        kernal = Kernal(_kernal);
    }


    function configureDependencies()  external virtual returns (Keycode[] memory);

    function requestPermissions()
        external
        view
        virtual
        returns (Permission[] memory requests);

    /**
     * @dev Used by a policy to get the current address of a module
     *      at a specific keycode.
     *
     * @param keycode_ Keycode used to get the address of the module.
     */
    function getModuleAddress(Keycode keycode_) internal view returns (address) {
        address moduleForKeycode = address(kernal.getModuleFromKeycode(keycode_));
        if (moduleForKeycode == address(0))
            revert Errors.Policy_ModuleDoesNotExist(keycode_);
        return moduleForKeycode;
    }

    /**
     * @notice Allows the kernel to grant or revoke the active status of the policy.
     *
     * @param activate_ Whether to activate or deactivate the policy.
     */
    function setActiveStatus(bool activate_) external onlyKernal {
        isActive = activate_;
    }
}
