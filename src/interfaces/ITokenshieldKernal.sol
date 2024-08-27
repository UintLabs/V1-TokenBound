// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.25;


interface ITokenshieldKernal {
    function isApprovedGuardian(address guardian) external view returns (bool);
}