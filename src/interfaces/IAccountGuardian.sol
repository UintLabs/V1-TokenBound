// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IAccountGuardian {
    function setTrustedImplementation(address implementation, bool trusted) external;

    function setTrustedExecutor(address executor, bool trusted) external;

    function setTrustedERC721(address collection, bool trusted) external;

    function setTrustedERC1155(address collection, bool trusted) external;

    function defaultImplementation() external view returns (address);

    function isTrustedImplementation(address implementation) external view returns (bool);

    function isTrustedExecutor(address implementation) external view returns (bool);

    function isTrustedERC721(address collection) external view returns (bool);

    function isTrustedERC1155(address collection) external view returns (bool);
}
