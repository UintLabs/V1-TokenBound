// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.25;

import { IExecutor } from "erc7579/interfaces/IERC7579Module.sol";
import "erc7579/interfaces/IERC7579Module.sol";
import "src/utils/Errors.sol";
import "src/utils/Roles.sol";
import { ITokenshieldSafe7579 } from "src/interfaces/ITokenshieldSafe7579.sol";

import { ITokenshieldKernal } from "src/interfaces/ITokenshieldKernal.sol";

contract RecoveryModule is IExecutor {
    struct AccountStatus {
        address nominee;
        uint64 recoveryEndTime;
        address newOwner;
        bool isInitialized;
        // bool isRecoverying;
    }

    ITokenshieldKernal immutable kernal;

    mapping(address account => AccountStatus status) private accountStatus;

    constructor(address _kernal) {
        kernal = ITokenshieldKernal(_kernal);
    }

    modifier onlyInitialised(address account) {
        if (!getAccountStatus(account).isInitialized) {
            revert Tokenshield_Executor_Recovery_AccountNotInitialized();
        }
        _;
    }

    modifier whenNotRecoverying(address account) {
        if (isRecovering(account)) {
            revert Tokenshield_Account_Already_Recoverying();
        }
        _;
    }

    /**
     * @dev This function is called by the smart account during installation of the module
     *  arbitrary data that may be required on the module during `onInstall`
     * initialization
     *
     * MUST revert on error (i.e. if module is already enabled)
     */
    function onInstall(bytes calldata data) external {
        address initialNominee = abi.decode(data, (address));
        accountStatus[msg.sender].nominee = initialNominee;
        accountStatus[msg.sender].isInitialized = true;
    }

    /**
     * @dev This function is called by the smart account during uninstallation of the module
     * @param data arbitrary data that may be required on the module during `onUninstall`
     * de-initialization
     *
     * MUST revert on error
     */
    function onUninstall(bytes calldata data) external { }

    /**
     * @dev Returns boolean value if module is a certain type
     * @param moduleTypeId the module type ID according the ERC-7579 spec
     *
     * MUST return true if the module is of the given type and false otherwise
     */
    function isModuleType(uint256 moduleTypeId) external view returns (bool) {
        if (moduleTypeId == MODULE_TYPE_EXECUTOR) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev This function is used to start the recovery process
     */
    function startRecovery(
        address account,
        address newOwner,
        bytes memory signatures
    )
        external
        onlyInitialised(account)
        whenNotRecoverying(account)
    {
        if (account == address(0) || newOwner == address(0)) {
            revert Tokenshield_ZeroAddress();
        }

        // address guardianValidator = kernal.getRoleMember(TOKENSHIELD_GUARDIAN_VALIDATOR, 0);
        // if (guardianValidator == address(0)) {
        //     revert Tokenshield_ZeroAddress();
        // }

        // bool isTokenshieldValidatorInstalled =
        //     ITokenshieldSafe7579(account).isModuleInstalled(MODULE_TYPE_VALIDATOR, guardianValidator, "");
        // if (isTokenshieldValidatorInstalled) { }
        checkSignatures(account, newOwner, signatures);

        // accountStatus[account].isRecoverying = true;
        accountStatus[account].newOwner = newOwner;
    }

    function completeRecovery(address account) external { }

    function stopRecovery(address account, bytes memory signatures) external { }

    /**
     * @dev Function to change the nominee of the account. SHould be called
     * @param account The smart account whose nominee is being changed
     * @param newNominee The address of the new nominee to be set
     * @param signatures  The signature of the account owner and the guardianValidator
     */
    function changeNominee(
        address account,
        address newNominee,
        bytes memory signatures
    )
        external
        onlyInitialised(account)
    { }

    /**
     * @dev Returns if the module was already initialized for a provided smartaccount
     */
    function getAccountStatus(address account) public view returns (AccountStatus memory) {
        return accountStatus[account];
    }

    function isInitialized(address account) external view override returns (bool) {
        return accountStatus[account].isInitialized;
    }

    function isRecovering(address account) public view returns (bool) {
        return accountStatus[account].recoveryEndTime > block.timestamp;
    }

    function checkSignatures(address account, address newOwner, bytes memory signatures) internal { }
}
