// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC721Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import { IAccountRegistry } from "src/interfaces/IAccountRegistry.sol";
import { AccessControlUpgradeable } from "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "openzeppelin-contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { BitMapsUpgradeable } from "openzeppelin-contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import { ERC721Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { CountersUpgradeable } from "openzeppelin-contracts-upgradeable/utils/CountersUpgradeable.sol";

contract InsureaBag is ERC721Upgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter public idTracker;
    string public baseURI;

    IAccountRegistry public registry;

    bool public insuranceStarted;

    function initialize(string memory _name, string memory _symbol, address _address) external initializer {
        __ERC721_init(_name, _symbol);
        __AccessControl_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function setRegistryAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        registry = IAccountRegistry(_address);
    }

    function toggleInsurance() external onlyRole(DEFAULT_ADMIN_ROLE) {
        insuranceStarted = !insuranceStarted;
    }

    function setBaseURI(string memory _baseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _baseURI;
    }

    function createInsurance() external payable {
        _mint(msg.sender, idTracker.current());
        registry.createAccount(address(this), idTracker.current());
        idTracker.increment();
    }

    function transferERC721token(address _tokenAddress, uint256 _insuranceId, uint256 _tokenId) external {
        address insAcc = registry.account(address(this), _insuranceId);
        address tokenOwner = IERC721Upgradeable(_tokenAddress).ownerOf(_tokenId);
        IERC721Upgradeable(_tokenAddress).safeTransferFrom(tokenOwner, insAcc, _tokenId);
    }

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
