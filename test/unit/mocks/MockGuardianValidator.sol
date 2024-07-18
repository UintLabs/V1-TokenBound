// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { PackedUserOperation } from "module-bases/external/ERC4337.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ValidationData } from "@ERC4337/account-abstraction/contracts/core/Helpers.sol";
import { IValidator } from "erc7579/interfaces/IERC7579Module.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ISafe2 as ISafe } from "../../../src/interfaces/ISafe2.sol";
// import { Tx } from "../../../src/utils/DataTypes.sol";
import "src/utils/Errors.sol";

contract MockGuardianValidator is IValidator, EIP712 {
    using ECDSA for bytes32;

    type Validation is uint256;

    enum AccountInitialization {
        NotInitialized,
        Initializing,
        Initialized
    }

    error GuardianValidator_LengthMismatch();

    mapping(address guardian => bool isEnabled) public isGuardianEnabled;
    mapping(address account => AccountInitialization initStatus) accountStatus;

    Validation internal constant VALIDATION_SUCCESS = Validation.wrap(0);
    Validation internal constant VALIDATION_FAILED = Validation.wrap(1);

    constructor() EIP712("TokenShield", "1") { }

    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    )
        external
        override
        returns (
            /**
             * userOpHash
             */
            uint256
        )
    {
        return verifySignatureOfUserOp(userOp, userOpHash);
    }

    function setGuardian(address[] calldata _guardian, bool[] calldata _isEnabled) external {
        if (_guardian.length != _isEnabled.length) {
            revert GuardianValidator_LengthMismatch();
        }
        for (uint256 i = 0; i < _guardian.length; i++) {
            isGuardianEnabled[_guardian[i]] = _isEnabled[i];
        }
    }

    function onInstall(bytes calldata data) external override {
        address owner = abi.decode(data, (address));
        address account = msg.sender;

        if (owner == address(0)) revert Tokenshield_ZeroAddress();

        if (account.code.length == 0) revert Tokenshield_EoaNotSupported();

        bytes32 hashLocation = keccak256(abi.encodePacked(account));
        accountStatus[account] = AccountInitialization.Initializing;
        assembly {
            // priorOwner := tload(hashLocation)

            tstore(hashLocation, owner)
        }
    }

    function onUninstall(bytes calldata data) external override { }

    function isModuleType(uint256 moduleTypeId) external view override returns (bool) { }

    function isInitialized(address smartAccount) external view override returns (bool) { }

    function isValidSignatureWithSender(
        address sender,
        bytes32 hash,
        bytes calldata data
    )
        external
        view
        override
        returns (bytes4)
    { }

    function verifySignatureOfUserOp(
        PackedUserOperation calldata _userOp,
        bytes32 _userOpHash
    )
        internal
        returns (uint256)
    {
        address owner;
        AccountInitialization currentAccountStatus = accountStatus[_userOp.sender];

        if (currentAccountStatus == AccountInitialization.NotInitialized) {
            revert Tokenshield_Validator_Guardian_AccountNotInitialized();
        } else if (currentAccountStatus == AccountInitialization.Initializing) {
            bytes32 ownerLocation = keccak256(abi.encodePacked(_userOp.sender));
            assembly {
                owner := tload(ownerLocation)
                tstore(ownerLocation, 0)
            }

            accountStatus[_userOp.sender] = AccountInitialization.Initialized;
        } else if (currentAccountStatus == AccountInitialization.Initialized) {
            // Check Threshold is one
            ISafe account = ISafe(_userOp.sender);
            uint256 threshold = account.getThreshold();

            // bool isOwner = account.isOwner(_userOp.sender);
            owner = address(2); //Temperary

            if (threshold != 1) {
                revert Tokenshield_Validator_Guardian_InValidThreshold(1, threshold);
            }
        }

        if (owner == address(0)) revert Tokenshield_ZeroAddress();

        // // Create Transaction Object
        // Tx memory transaction = Tx(
        //     to: _userOp.
        // )
        // // Get the EIP712 Hash
        // bytes32 transactionHash = getTransactionHash(transaction);
        // bytes32 digest = _hashTypedDataV4(transactionHash);
        // (bytes32 r1, bytes32 s1, uint8 v1, bytes32 r, bytes32 s, uint8 v) = abi.decode(_userOp.signature,);

        // bool isOwnerSignature = digest.tryRecover(_userOp.signature);
        // bool isGuardianSignature = SignatureChecker.isValidSignatureNow(guardianSigner, dataHash,
        // guardianSignerSignature);

        return Validation.unwrap(VALIDATION_SUCCESS);
    }

    // function getTransactionHash(Tx memory _transaction) public pure returns (bytes32) {
    //     return keccak256(
    //         abi.encode(
    //             keccak256("Tx(address to,uint256 value,uint256 nonce,bytes data)"),
    //             _transaction.to,
    //             _transaction.value,
    //             _transaction.nonce,
    //             keccak256(bytes(_transaction.data))
    //         )
    //     );
    // }
}
