// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { MockValidator as MockValidatorBase } from "module-bases/mocks/MockValidator.sol";
import { PackedUserOperation } from "module-bases/external/ERC4337.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
contract MockGuardianValidator is MockValidatorBase {
    error GuardianValidator_LengthMismatch();

    mapping(address guardian => bool isEnabled) public isGuardianEnabled;

    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    )
        external
        virtual
        override
        returns (ValidationData)
    {
        return VALIDATION_SUCCESS;
    }

    function setGuardian(address[] calldata _guardian, bool[] calldata _isEnabled) external {
        if (_guardian.length != _isEnabled.length) {
            revert GuardianValidator_LengthMismatch();
        }
        for (uint256 i = 0; i < _guardian.length; i++) {
            isGuardianEnabled[_guardian[i]] = _isEnabled[i];
        }
    }
}
