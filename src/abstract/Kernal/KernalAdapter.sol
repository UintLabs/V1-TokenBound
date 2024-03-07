// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Kernal} from "src/Kernal.sol";

/////////////////////////////////////////////////////////////////////////////////
//                         Module Abstract Contracts                           //
/////////////////////////////////////////////////////////////////////////////////

/**
 * @title KernelAdapter
 * @notice A base contract to be inherited by both policies and modules. Provides common
 *         access to logic related to the kernel contract.
 */
abstract contract KernelAdapter {
    // The active kernel contract.
    Kernal public kernal;

    /**
     * @dev Instantiate this contract as a a kernel adapter. When using a proxy, the kernel address
     *      should be set to address(0).
     *
     * @param kernal_ Address of the kernel contract.
     */
    constructor(Kernal kernal_) {
        kernal = kernal_;
    }

    /**
     * @dev Modifier which only allows calls from the active kernel contract.
     */
    modifier onlyKernal() {
        if (msg.sender != address(kernal))
            // revert Errors.KernelAdapter_OnlyKernel(msg.sender);
        _;
    }

    /**
     * @notice Points the adapter to reference a new kernel address. This function can
     *         only be called by the active kernel, and is used to perform migrations by
     *         telling all policies and modules where the new kernel is located before
     *         actually performing the migration.
     *
     * @param newKernal_  Address of the new kernel contract.
     */
    function changeKernel(Kernal newKernal_) external onlyKernal {
        kernal = newKernal_;
    }
}
