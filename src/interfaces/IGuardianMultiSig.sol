// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

interface IGuardianMultiSigWallet {
    function initialize(address[] calldata _guardians, uint16 _threshold) external;

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4);

    /**
     * referece from gnosis safe validation
     *
     */
    function checkNSignatures(bytes32 dataHash, bytes memory signatures, uint16 requiredSignatures) external view;
}
