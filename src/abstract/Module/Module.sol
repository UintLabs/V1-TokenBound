// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import {Kernal} from "src/Kernal.sol";
import {Errors} from "src/utils/Errors.sol";

abstract contract Module {

    Keycode immutable keycode;
    Kernal immutable kernal;

    modifier onlyKernal() {
        if (msg.sender != address(kernal)) {
            revert Errors.NotFromKernal();
        }
        _;
    }

    modifier permissioned() {
        bool isAllowed = kernal.getModulePermission(keycode, msg.sender, msg.sig);

        if (!isAllowed) {
            revert Errors.NotFromAuthorisedPolicy(msg.sender);
        }
        _;
    }

    constructor(Keycode _keycode, address _kernal) {
        keycode = _keycode;
        kernal = Kernal(_kernal);
    }


    function INIT() external virtual onlyKernal{}

    function KEYCODE() public view returns (Keycode) {
        return keycode;
    }
    
}