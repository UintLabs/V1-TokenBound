// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC6551Registry } from "src/interfaces/IERC6551Registry.sol";
import { AccessControlUpgradeable } from "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "openzeppelin-contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ERC721Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { CountersUpgradeable } from "openzeppelin-contracts-upgradeable/utils/CountersUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { console } from "forge-std/console.sol";

contract TokenShieldSubscription is ERC721Upgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

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

    /*//////////////////////////////////////////////////////////////
                                 Events
    //////////////////////////////////////////////////////////////*/

    event VaultCreated(address indexed account);

    /*//////////////////////////////////////////////////////////////
                                 State Vars
    //////////////////////////////////////////////////////////////*/

    CountersUpgradeable.Counter idTracker;
    IERC6551Registry registry;
    AggregatorV3Interface internal ethPriceFeed;

    string baseURI;
    address accountImplementation;
    bool public initiatedMint;

    bytes32 public TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    function initialize(string memory _name, string memory _symbol, address _address, address transferRole, address _ethPriceFeedAddress) external initializer {
        __ERC721_init(_name, _symbol);
        __AccessControl_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _address);
        _grantRole(TRANSFER_ROLE, transferRole);
        ethPriceFeed = AggregatorV3Interface(_ethPriceFeedAddress);
    }

    /*//////////////////////////////////////////////////////////////
                                 Modifiers
    //////////////////////////////////////////////////////////////*/

    modifier notZeroAddress(address _address) {
        if (_address == address(0)) revert ZeroAddress();
        _;
    }

    modifier mintInitiated() {
        if (initiatedMint == false) revert InsuranceNotInitiated();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                         Management Functions
    //////////////////////////////////////////////////////////////*/

    function setRegistryAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) notZeroAddress(_address) {
        registry = IERC6551Registry(_address);
    }

    function setImplementationAddress(address _address)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        notZeroAddress(_address)
    {
        if (_address == address(0)) revert ZeroAddress();
        accountImplementation = _address;
    }

    function toggleMint() external onlyRole(DEFAULT_ADMIN_ROLE) {
        initiatedMint = !initiatedMint;
    }

    function setBaseURI(string memory _baseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _baseURI;
    }

    /*//////////////////////////////////////////////////////////////
                           Mint Function
    //////////////////////////////////////////////////////////////*/

    function createInsurance() external payable mintInitiated {
        if (msg.value < getWeiPerUsd()) {
            revert NotEnoughEthSent();
        }
        _mint(msg.sender, idTracker.current());
        address account =
            registry.createAccount(accountImplementation, block.chainid, address(this), idTracker.current(), 0, "");
        idTracker.increment();
        emit VaultCreated(account);
    }

    /*//////////////////////////////////////////////////////////////
                        Transfer Functions
    //////////////////////////////////////////////////////////////*/



    function transferFrom(address /**from */, address /**to */, uint256 /**tokenId */) public pure override {
        require(false, "TokenShield: Non-Transferrable");
    }

    function safeTransferFrom(address /**from */, address /**to */, uint256 /**tokenId */) public pure override {
        require(false, "TokenShield: Non-Transferrable");
    }

    function safeTransferFrom(address /**from */, address /**to */, uint256 /**tokenId */, bytes memory /**data */) public pure override {
        require(false, "TokenShield: Non-Transferrable");
    }

    /*//////////////////////////////////////////////////////////////
                              Other
    //////////////////////////////////////////////////////////////*/

    function getTokenBoundAddress(uint256 _tokenId) external view returns (address) {
        if (_tokenId > idTracker.current()) revert NonexistentToken();
        address account = registry.account(accountImplementation, block.chainid, address(this), _tokenId, 0);
        return account;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);
        return baseURI;
    }

    function getWeiPerUsd() public view  returns (uint256 weiPerUsd) {
        uint8 decimal = ethPriceFeed.decimals();
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = ethPriceFeed.latestRoundData();
        uint256 chainlinkPrice;
        if (answer< 0 ) {
            revert PriceFeedReturnsZeroOrLess();
        } else {
            chainlinkPrice = uint256(answer);
        }
        // console.log(chainlinkPrice);
        uint256 decimalCorrection = 10 ** decimal;
        weiPerUsd = (1 ether * decimalCorrection)/chainlinkPrice;
        require(weiPerUsd!=0,"Cant be zero");
        // console.log("Wei Per USD");
        // console.log(weiPerUsd);
    }

    /*//////////////////////////////////////////////////////////////
                        Supports Interface
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return
        // ERC-4906 support (metadata updates)
        interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
    }

    function withdraw(address withdrawalAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success, ) = payable(withdrawalAddress).call{value:address(this).balance}("");
        if (!success) {
            revert EthNotWithdrawnSuccessfully();
        }
    }
}
