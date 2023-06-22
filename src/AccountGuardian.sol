// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Ownable2Step } from "openzeppelin-contracts/access/Ownable2Step.sol";

/// @dev manages upgrade and cross-chain execution settings for accounts
contract AccountGuardian is Ownable2Step {
    /// @dev mapping from cross-chain executor => is trusted
    mapping(address => bool) public isTrustedImplementation;

    /// @dev mapping from implementation => is trusted
    mapping(address => bool) public isTrustedExecutor;

    /// @dev mapping from address => is supported ERC721
    mapping(address => bool) public isTrustedERC721;

    /// @dev mapping from address => is supported ERC1155
    mapping(address => bool) public isTrustedERC1155;

    event TrustedImplementationUpdated(address implementation, bool trusted);
    event TrustedExecutorUpdated(address executor, bool trusted);
    event TrustedERC721(address collection, bool trusted);
    event TrustedERC1155(address collection, bool trusted);

    function setTrustedImplementation(address implementation, bool trusted) external onlyOwner {
        isTrustedImplementation[implementation] = trusted;
        emit TrustedImplementationUpdated(implementation, trusted);
    }

    function setTrustedExecutor(address executor, bool trusted) external onlyOwner {
        isTrustedExecutor[executor] = trusted;
        emit TrustedExecutorUpdated(executor, trusted);
    }

    function setTrustedERC721(address collection, bool trusted) external onlyOwner {
        isTrustedERC721[collection] = trusted;
        emit TrustedERC721(collection, trusted);
    }

    function setTrustedERC1155(address collection, bool trusted) external onlyOwner {
        isTrustedERC1155[collection] = trusted;
        emit TrustedERC1155(collection, trusted);
    }
}
