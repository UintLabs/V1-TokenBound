// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

error Tokenshield_Validator_Guardian_InValidThreshold(uint256 expectedThreshold, uint256 actualThreshold);
error Tokenshield_ZeroAddress();
error Tokenshield_EoaNotSupported();
error Tokenshield_Validator_Guardian_AccountNotInitialized();
error Tokenshield_InvalidGuardian();
error Tokenshield_GuardianValidator_LengthMismatch();
error Tokenshield_NotValidOwner();
error Tokenshield_InvalidSignature(address signer, address guardian);
error Tokenshield_Executor_Recovery_AccountNotInitialized();
error Tokenshield_Account_Already_Recoverying();