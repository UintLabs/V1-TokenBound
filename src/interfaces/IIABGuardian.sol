// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { AccessControlEnumerable } from "lib/openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol";

contract IIABGuardian is AccessControlEnumerable {
    address private ownerAddress;
    address private guardian;
    mapping(address => address) accountToGuardian;

    bytes32 private GUARDIAN_SETTER_ROLE = keccak256("GUARDIAN_SETTER_ROLE");

    constructor(address _ownerAddress, address _guardian, address _guardianSetter) { }

    function getGuardian() public view returns (address) { }

    function setGuardian(address _newGuardian) external { }

    function getOwnerAdress() public view returns (address) { }
}
