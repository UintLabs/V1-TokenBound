// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC6551Registry } from "src/interfaces/IERC6551Registry.sol";
import { AccessControlUpgradeable } from "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "openzeppelin-contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ERC721Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { CountersUpgradeable } from "openzeppelin-contracts-upgradeable/utils/CountersUpgradeable.sol";

contract InsureaBag is ERC721Upgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    /*//////////////////////////////////////////////////////////////
                                 Errors
    //////////////////////////////////////////////////////////////*/

    error NonexistentToken();
    error InsuranceNotStarted();
    error ZeroAddress();
    error InsuranceNotInitiated();

    /*//////////////////////////////////////////////////////////////
                                 Events
    //////////////////////////////////////////////////////////////*/

    event VaultCreated(address indexed account);

    /*//////////////////////////////////////////////////////////////
                                 State Vars
    //////////////////////////////////////////////////////////////*/

    CountersUpgradeable.Counter idTracker;
    IERC6551Registry registry;

    string baseURI;
    address accountImplementation;
    bool public initiatedMint;

    function initialize(string memory _name, string memory _symbol, address _address) external initializer {
        __ERC721_init(_name, _symbol);
        __AccessControl_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _address);
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
        _mint(msg.sender, idTracker.current());
        address account =
            registry.createAccount(accountImplementation, block.chainid, address(this), idTracker.current(), 0, "");
        idTracker.increment();
        emit VaultCreated(account);
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
}
