// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { AutomationCompatibleInterface as IAutomationCompatibleInterface } from
    "@chainlink/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import { IKeeperRegistryMaster } from "@chainlink/v0.8/automation/interfaces/v2_1/IKeeperRegistryMaster.sol";
import { ITokenShieldSubscription } from "./interfaces/ITokenShieldSubscription.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ITokenShieldGuardian as TokenGuardian } from "src/interfaces/ITokenShieldGuardian.sol";

error RecoveryManager__NotTokenShieldNft();
error RecoveryManager__AddressCantBeZero();
error RecoveryManager__RecoveryAlreadySet();
error RecoveryManager__RecoveryNotSet();
error RecoveryManager__RecoveryTimeHasntCompleted();
error RecoveryManager__OnlyForwarder();
error RecoveryManager__AddressesCantBeSame();
error RecoveryManager__RecoveryOrUpkeepNotSet();
error RecoveryManager__RecoveryPeriodNotOver();
error RecoveryManager__RecoveryTimeCompleted();
error RecoveryManager__SignatureNotVerified();

contract RecoveryManager is IAutomationCompatibleInterface {
    struct RecoveryConfig {
        address trustee;
        uint48 recoveryStartTimestamp;
        uint48 recoveryEndTimestamp;
        uint256 upkeepId;
        address upkeepForwarder;
        address toAddress;
        bool isRecoverySet;
        bool isUpkeepSet;
        bool isRecoveryPeriod;
    }

    ITokenShieldSubscription private s_tokenShieldAddress;
    TokenGuardian private s_guardian;

    mapping(uint256 => RecoveryConfig) private tokenIdToRecoveryConfig;
    IKeeperRegistryMaster private s_automationRegistry;

    constructor(address _tokenShieldNft, address _automationRegistry, address _guardian) {
        if (_tokenShieldNft == _automationRegistry) {
            revert RecoveryManager__AddressesCantBeSame();
        }
        s_tokenShieldAddress = ITokenShieldSubscription(_tokenShieldNft);
        s_automationRegistry = IKeeperRegistryMaster(_automationRegistry);
        s_guardian = TokenGuardian(_guardian);
    }

    modifier onlyTokenShield() {
        if (msg.sender != address(s_tokenShieldAddress)) {
            revert RecoveryManager__NotTokenShieldNft();
        }
        _;
    }

    modifier noZeroAddress(address _addressToBeNonZero) {
        if (_addressToBeNonZero == address(0)) {
            revert RecoveryManager__AddressCantBeZero();
        }
        _;
    }

    function setRecovery(address _trustee, uint256 tokenId) external onlyTokenShield noZeroAddress(_trustee) {
        RecoveryConfig memory priorRecoveryConfig = tokenIdToRecoveryConfig[tokenId];

        if (priorRecoveryConfig.isRecoverySet) {
            revert RecoveryManager__RecoveryAlreadySet();
        }

        if (_trustee == address(0)) {
            revert RecoveryManager__AddressCantBeZero();
        }

        RecoveryConfig memory recoveryConfig = RecoveryConfig({
            trustee: _trustee,
            isRecoverySet: true,
            recoveryStartTimestamp: 0,
            recoveryEndTimestamp: 0,
            isUpkeepSet: false,
            upkeepForwarder: address(0),
            upkeepId: 0,
            isRecoveryPeriod: false,
            toAddress: address(0)
        });

        tokenIdToRecoveryConfig[tokenId] = recoveryConfig;
    }

    function startRecovery(
        uint256 tokenId,
        address _toAddress
    )
        external
        onlyTokenShield
        returns (address upkeepForwarder, uint256 upkeepId)
    {
        RecoveryConfig memory recoveryConfig = getRecoveryConfig(tokenId);

        if (!recoveryConfig.isRecoverySet) {
            revert RecoveryManager__RecoveryNotSet();
        }

        if (block.timestamp <= recoveryConfig.recoveryEndTimestamp) {
            revert RecoveryManager__RecoveryTimeHasntCompleted();
        }

        recoveryConfig.recoveryStartTimestamp = uint48(block.timestamp);
        recoveryConfig.recoveryEndTimestamp = uint48(block.timestamp) + uint48(7 days);
        if (!recoveryConfig.isUpkeepSet) {
            recoveryConfig.upkeepId = s_automationRegistry.registerUpkeep(
                address(this), 100_000, address(this), abi.encodePacked(tokenId), ""
            );
            recoveryConfig.isUpkeepSet = true;
            recoveryConfig.toAddress = _toAddress;
            recoveryConfig.upkeepForwarder = s_automationRegistry.getForwarder(recoveryConfig.upkeepId);
        } else {
            s_automationRegistry.unpauseUpkeep(recoveryConfig.upkeepId);
        }
        recoveryConfig.isRecoveryPeriod = true;
        upkeepForwarder = recoveryConfig.upkeepForwarder;
        upkeepId = recoveryConfig.upkeepId;
        tokenIdToRecoveryConfig[tokenId] = recoveryConfig;
    }

    function stopRecovery(uint256 tokenId, bytes calldata tokenShieldSig) external onlyTokenShield {
        RecoveryConfig memory recoveryConfig = getRecoveryConfig(tokenId);

        if (!recoveryConfig.isRecoverySet) {
            revert RecoveryManager__RecoveryNotSet();
        }
        if (block.timestamp >= recoveryConfig.recoveryEndTimestamp) {
            revert RecoveryManager__RecoveryTimeCompleted();
        }

        bytes32 digest = keccak256(abi.encode(tokenId, recoveryConfig.recoveryEndTimestamp));
        address guardianSigner = s_guardian.getGuardian();

        bool isTokenShieldVerified = SignatureChecker.isValidSignatureNow(guardianSigner, digest, tokenShieldSig);
        if (!isTokenShieldVerified) {
            revert RecoveryManager__SignatureNotVerified();
        }
        recoveryConfig.isRecoveryPeriod = false;
        tokenIdToRecoveryConfig[tokenId] = recoveryConfig;
        s_automationRegistry.pauseUpkeep(recoveryConfig.upkeepId);
    }

    function checkUpkeep(bytes calldata checkData)
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (uint256 tokenId) = abi.decode(checkData, (uint256));
        (upkeepNeeded, performData) = recoveryStatus(tokenId);
    }

    function recoveryStatus(uint256 tokenId) private view returns (bool, bytes memory) {
        RecoveryConfig memory recoveryConfig = getRecoveryConfig(tokenId);
        if (recoveryConfig.upkeepForwarder != msg.sender) {
            revert RecoveryManager__OnlyForwarder();
        }
        if (!(recoveryConfig.isRecoverySet && recoveryConfig.isUpkeepSet)) {
            revert RecoveryManager__RecoveryOrUpkeepNotSet();
        }
        if (recoveryConfig.isRecoveryPeriod && recoveryConfig.recoveryEndTimestamp <= block.timestamp) {
            return (true, abi.encodePacked(tokenId));
        } else {
            return (false, "");
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        (bool upkeepNeeded,) = checkUpkeep(performData);
        if (!upkeepNeeded) {
            revert RecoveryManager__RecoveryPeriodNotOver();
        }
        (uint256 tokenId) = abi.decode(performData, (uint256));
        completeRecovery(tokenId);
    }

    function completeRecovery(uint256 tokenId) private {
        RecoveryConfig memory recoveryConfig = getRecoveryConfig(tokenId);
        recoveryConfig.isRecoveryPeriod = false;
        tokenIdToRecoveryConfig[tokenId] = recoveryConfig;
        s_tokenShieldAddress.completeRecovery(recoveryConfig.toAddress, tokenId);
        s_automationRegistry.pauseUpkeep(recoveryConfig.upkeepId);
    }

    // Getter Functions
    function getAutomationRegistry() external view returns (address) {
        return address(s_automationRegistry);
    }

    function getRecoveryConfig(uint256 tokenId) public view returns (RecoveryConfig memory) {
        return tokenIdToRecoveryConfig[tokenId];
    }
}
