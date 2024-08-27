// SPDX-License-Identifier: GPL3
pragma solidity 0.8.25;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import "src/utils/Events.sol";
import "src/utils/Errors.sol";

contract TokenshieldKernal is AccessControl {
    bytes32 constant MFA_SETTER = keccak256("TOKENSHIELD_MFA_SETTER_ROLE");
    bytes32 constant MFA_SETTER_ADMIN = keccak256("TOKENSHIELD_MFA_SETTER_ROLE_ADMIN");

    mapping(address guardian => bool isEnabled) public isGuardianEnabled;

    constructor(address defaultAdminRole, address mfaSetterRoleAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdminRole);
        _grantRole(MFA_SETTER_ADMIN, mfaSetterRoleAdmin);
        _setRoleAdmin(MFA_SETTER, MFA_SETTER_ADMIN);
    }

    function setGuardian(address[] calldata _guardian, bool[] calldata _isEnabled) external {
        if (_guardian.length != _isEnabled.length) {
            revert Tokenshield_GuardianValidator_LengthMismatch();
        }
        for (uint256 i = 0; i < _guardian.length; i++) {
            isGuardianEnabled[_guardian[i]] = _isEnabled[i];
            emit Tokenshield_Guardian_Changed(_guardian[i], _isEnabled[i]);
        }
    }

    
}
