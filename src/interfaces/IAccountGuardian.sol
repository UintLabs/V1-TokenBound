// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IGuardianMultiSigWallet} from "src/interfaces/IGuardianMultiSig.sol";

interface IAccountGuardian is IGuardianMultiSigWallet{
    function setTrustedImplementation(address implementation, bool trusted) external;

    function setTrustedExecutor(address executor, bool trusted) external;

    function setTrustedERC721(address collection, bool trusted) external;

    function setTrustedERC1155(address collection, bool trusted) external;

    function defaultImplementation() external view returns (address);

    function isTrustedImplementation(address implementation) external view returns (bool);

    function isTrustedExecutor(address implementation) external view returns (bool);

    function isTrustedERC721(address collection) external view returns (bool);

    function isTrustedERC1155(address collection) external view returns (bool);
    function initialize(address[] calldata _guardians, uint16 _threshold) external;


    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4);
    
    /** 
         referece from gnosis safe validation
    **/
    function checkNSignatures(
        bytes32 dataHash,
        bytes memory signatures,
        uint16 requiredSignatures
    ) external view;
}
