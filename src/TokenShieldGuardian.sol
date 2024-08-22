// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { AccessControlEnumerable } from "lib/openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol";

contract TokenShieldGuardian is AccessControlEnumerable {
    address private ownerAddress;
    address private guardian;
    mapping(address => address) accountToGuardian;

    bytes32 private GUARDIAN_SETTER_ROLE = keccak256("GUARDIAN_SETTER_ROLE");

    constructor(address _ownerAddress, address _guardian, address _guardianSetter) {
        ownerAddress = _ownerAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, _ownerAddress);
        _grantRole(GUARDIAN_SETTER_ROLE, _guardianSetter);
        guardian = _guardian;
    }

    function getGuardian() public view returns (address) {
        return guardian;
    }

    function setGuardian(address _newGuardian) external onlyRole(GUARDIAN_SETTER_ROLE) {
        guardian = _newGuardian;
    }

    function getOwnerAddress() public view returns (address) {
        return ownerAddress;
    }
}
