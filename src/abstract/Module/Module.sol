// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import {Kernal} from "src/Kernal.sol";

abstract contract Module {

    Keycode immutable keycode;
    Kernal immutable kernal;

    modifier onlyKernal() {
        
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