// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { PackedUserOperation } from "module-bases/external/ERC4337.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ValidationData } from "@ERC4337/account-abstraction/contracts/core/Helpers.sol";
import { IValidator } from "erc7579/interfaces/IERC7579Module.sol";


contract MockGuardianValidator is IValidator {
    
    type Validation is uint256;

    error GuardianValidator_LengthMismatch();

    mapping(address guardian => bool isEnabled) public isGuardianEnabled;

    Validation internal constant VALIDATION_SUCCESS = Validation.wrap(0);
    Validation internal constant VALIDATION_FAILED = Validation.wrap(1);

    function validateUserOp(
        PackedUserOperation calldata
         userOp,
         
        bytes32
    )
        external
        override
        pure
        returns (
            /**
             * userOpHash
             */
            uint256
        )
    {

        
        return Validation.unwrap(VALIDATION_SUCCESS);
    }

    function setGuardian(address[] calldata _guardian, bool[] calldata _isEnabled) external {
        if (_guardian.length != _isEnabled.length) {
            revert GuardianValidator_LengthMismatch();
        }
        for (uint256 i = 0; i < _guardian.length; i++) {
            isGuardianEnabled[_guardian[i]] = _isEnabled[i];
        }
    }

    function onInstall(bytes calldata data) external override { }

    function onUninstall(bytes calldata data) external override { }

    function isModuleType(uint256 moduleTypeId) external view override returns (bool) { }

    function isInitialized(address smartAccount) external view override returns (bool) { }

    function isValidSignatureWithSender(
        address sender,
        bytes32 hash,
        bytes calldata data
    )
        external
        view
        override
        returns (bytes4)
    { }
}
