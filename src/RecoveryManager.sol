// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { AutomationCompatibleInterface as IAutomationCompatibleInterface } from
    "@chainlink/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

error RecoveryManager__NotTokenShieldNft();
error RecoveryManager__AddressCantBeZero();
error RecoveryManager__RecoveryAlreadySet();

contract RecoveryManager is IAutomationCompatibleInterface {
    struct RecoveryConfig {
        address trustee;
        uint48 recoveryStartTimestamp;
        uint48 recoveryEndTimestamp;
        bool isRecoverySet;
        bool isUpkeepSet;
        address upkeepForwarder;
    }

    address public s_tokenShieldAddress;
    mapping(uint256 => RecoveryConfig) tokenIdToRecoveryConfig;

    constructor(address _tokenShieldNft) {
        s_tokenShieldAddress = _tokenShieldNft;
    }

    modifier onlyTokenShield() {
        if (msg.sender != s_tokenShieldAddress) {
            revert RecoveryManager__NotTokenShieldNft();
        }
        _;
    }

    modifier noZeroAddress(address _addressToBeNonZero) {
        if (_addressToBeNonZero != address(0)) {
            revert RecoveryManager__AddressCantBeZero();
        }
        _;
    }

    function setRecovery(address _trustee, uint256 tokenId) external onlyTokenShield noZeroAddress(_trustee) {
        RecoveryConfig memory priorRecoveryConfig = tokenIdToRecoveryConfig[tokenId];

        if (priorRecoveryConfig.isRecoverySet) {
            revert RecoveryManager__RecoveryAlreadySet();
        }

        RecoveryConfig memory recoveryConfig = RecoveryConfig({
            trustee: _trustee,
            isRecoverySet: true,
            recoveryStartTimestamp: 0,
            recoveryEndTimestamp: 0,
            isUpkeepSet:false,
            upkeepForwarder: address(0)
        });

        tokenIdToRecoveryConfig[tokenId] = recoveryConfig;
    }
    function startRecovery() external onlyTokenShield returns (address upkeepFowarder) {
        
    }

    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    { 

    }

    function performUpkeep(bytes calldata performData) external override { }
}
