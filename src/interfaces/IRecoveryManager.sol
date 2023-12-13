// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { AutomationCompatibleInterface as IAutomationCompatibleInterface } from
    "@chainlink/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import { IKeeperRegistryMaster } from "@chainlink/src/v0.8/automation/interfaces/v2_1/IKeeperRegistryMaster.sol";
// import "";

error RecoveryManager__NotTokenShieldNft();
error RecoveryManager__AddressCantBeZero();
error RecoveryManager__RecoveryAlreadySet();
error RecoveryManager__RecoveryNotSet();
error RecoveryManager__RecoveryTimeHasntCompleted();
error RecoveryManager__OnlyForwarder();
error RecoveryManager__AddressesCantBeSame();
error RecoveryManager__RecoveryOrUpkeepNotSet();
error RecoveryManager__RecoveryPeriodNotOver();

interface IRecoveryManager is IAutomationCompatibleInterface {
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

    function setRecovery(address _trustee, uint256 tokenId) external;
    function startRecovery(
        uint256 tokenId,
        address _toAddress
    )
        external
        returns (address upkeepForwarder, uint256 upkeepId);

    function stopRecovery(uint256 tokenId, bytes calldata tokenShieldSig) external returns (bool);

    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external override;

    // Getter Functions
    function getAutomationRegistry() external view returns (address);

    function getRecoveryConfig(uint256 tokenId) external view returns (RecoveryConfig memory);
}
