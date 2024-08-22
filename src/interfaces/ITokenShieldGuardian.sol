// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ITokenShieldGuardian {
    // constructor(address _ownerAddress, address _guardian, address _guardianSetter);

    function getGuardian() external view returns (address);

    function setGuardian(address _newGuardian) external;

    function getOwnerAdress() external view returns (address);
}
