// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITokenShieldSubscription {
    /*//////////////////////////////////////////////////////////////
                                 Errors
    //////////////////////////////////////////////////////////////*/

    error NonexistentToken();
    error InsuranceNotStarted();
    error ZeroAddress();
    error InsuranceNotInitiated();
    error PriceFeedReturnsZeroOrLess();
    error NotEnoughEthSent();
    error EthNotWithdrawnSuccessfully();
    error TokenShield__NotGuardian();
    error TokenShield__NotOwner();
    error TokenShield__OwnerCantBeTrustee();

    /*//////////////////////////////////////////////////////////////
                                 Events
    //////////////////////////////////////////////////////////////*/

    event VaultCreated(address indexed account);

    /*//////////////////////////////////////////////////////////////
                                 State Vars
    //////////////////////////////////////////////////////////////*/

    function initialize(
        string memory _name,
        string memory _symbol,
        address _adminAddress,
        address transferRole,
        address _ethPriceFeedAddress
    )
        external;

    /*//////////////////////////////////////////////////////////////
                         Management Functions
    //////////////////////////////////////////////////////////////*/

    function setRegistryAddress(address _address) external;

    function setImplementationAddress(address _address) external;

    function toggleMint() external;

    function setBaseURI(string memory _baseURI) external;
    /*//////////////////////////////////////////////////////////////
                           Mint Function
    //////////////////////////////////////////////////////////////*/

    function createVault() external payable;

    /*//////////////////////////////////////////////////////////////
                           Mint Function
    //////////////////////////////////////////////////////////////*/

    function setRecovery(uint256 tokenId, address trustee) external;

    function startRecovery(uint256 tokenId) external;

    function stopRecovery() external;

    function completeRecovery(address _toAddress, uint256 tokenId) external;

    /*//////////////////////////////////////////////////////////////
                        Transfer Functions
    //////////////////////////////////////////////////////////////*/

    function transferFrom(
        address,
        /**
         * from
         */
        address,
        /**
         * to
         */
        uint256
    )
        /**
         * tokenId
         */
        external
        pure;

    function safeTransferFrom(
        address,
        /**
         * from
         */
        address,
        /**
         * to
         */
        uint256
    )
        /**
         * tokenId
         */
        external
        pure;

    function safeTransferFrom(
        address,
        /**
         * from
         */
        address,
        /**
         * to
         */
        uint256,
        /**
         * tokenId
         */
        bytes memory
    )
        /**
         * data
         */
        external
        pure;
    /*//////////////////////////////////////////////////////////////
                              Other
    //////////////////////////////////////////////////////////////*/

    function getTokenBoundAddress(uint256 _tokenId) external view returns (address);

    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function getWeiPerUsd() external view returns (uint256 weiPerUsd);

    /*//////////////////////////////////////////////////////////////
                        Supports Interface
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function withdraw(address withdrawalAddress) external;
}
