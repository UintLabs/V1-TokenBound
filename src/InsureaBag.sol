// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IERC1155Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import { IERC721Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import { AccessControlUpgradeable } from "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "openzeppelin-contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { BitMapsUpgradeable } from "openzeppelin-contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import { ERC721Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { CountersUpgradeable } from "openzeppelin-contracts-upgradeable/utils/CountersUpgradeable.sol";
import { ERC1155ReceiverUpgradeable } from
    "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC1155/utils/ERC1155ReceiverUpgradeable.sol";
import { ERC721HolderUpgradeable } from
    "openzeppelin-contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import { ERC1155HolderUpgradeable } from
    "openzeppelin-contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { MerkleProofUpgradeable } from
    "openzeppelin-contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import {IAccountRegistry} from "src/interfaces/IAccountRegistry.sol";


contract InsureaBag is
    ERC721Upgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC1155HolderUpgradeable,
    ERC721HolderUpgradeable
{
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

    function initiateInsurance() external onlyRole(DEFAULT_ADMIN_ROLE) {
        insuranceStarted = true;
    }

    function stopInsuranceProcess() external onlyRole(DEFAULT_ADMIN_ROLE) {
        insuranceStarted = false;
    }

    function setBaseURI(string memory _baseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _baseURI;
    }

    function createInsurance() external payable {
        _mint(msg.sender, idTracker.current());
        registry.createAccount(address(this), idTracker.current());
        idTracker.increment();
    }

    function getAddressOfInsurance(uint256 _tokenId) public view returns (address) {
        address insAcc = registry.account(address(this), _tokenId);
        return insAcc;
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
        override(AccessControlUpgradeable, ERC1155ReceiverUpgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return
        // ERC-4906 support (metadata updates)
        interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
    }
}
