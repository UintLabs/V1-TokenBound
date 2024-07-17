// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import {ISafe} from "safe7579/src/interfaces/ISafe.sol";

interface ISafe2 is ISafe {
    function checkNSignatures(bytes32 dataHash, bytes memory data, bytes memory signatures, uint256 requiredSignatures) external view;
}