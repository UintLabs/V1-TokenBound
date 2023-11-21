// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { EIP712 } from "openzeppelin-contracts/utils/cryptography/EIP712.sol";
import { ITokenShieldGuardian as TokenGuardian } from "src/interfaces/ITokenShieldGuardian.sol";
import { IERC6551Account } from "src/interfaces/IERC6551Account.sol";
////// Errors

error VaultSignatureVerifier__NonceNotCorrect();
error VaultSignatureVerifier__ToAddressNotSame();
error VaultSignatureVerifier__ValueNotSame();
error VaultSignatureVerifier__SignatureSame();
error VaultSignatureVerifier__InvalidSigner();

abstract contract VaultSignatureVerifier is EIP712, IERC6551Account {
    //////////// Structs
    struct Tx {
        address to;
        uint256 value;
        uint256 nonce;
        bytes data;
    }

    //////////// Storage Varibales
    address public immutable guardian;

    constructor(address _guardian) EIP712("TokenShield", "1") {
        guardian = _guardian;
    }

    function owner() public view virtual returns (address);

    function checkSignature(bytes memory data, address to, uint256 value, uint256 state) internal view returns (bool isValidSig) {
        (Tx memory transaction, bytes memory sig) = abi.decode(data, (Tx, bytes));
        if (state != transaction.nonce) {
            revert VaultSignatureVerifier__NonceNotCorrect();
        }
        if (to != transaction.to) {
            revert VaultSignatureVerifier__ToAddressNotSame();
        }
        if (value != transaction.value) {
            revert VaultSignatureVerifier__ValueNotSame();
        }

        // Get the EIP712 Hash
        bytes32 transactionHash = getTransactionHash(transaction);
        bytes32 digest = _hashTypedDataV4(transactionHash);
        isValidSig = splitAndCheckSignature(digest, sig);
    }

    function splitAndCheckSignature(bytes32 dataHash, bytes memory signatures) internal view returns (bool){
        // checking if the length of the signature is correct
        require(signatures.length >= 2 * 65, "signatures too short");

        (bytes memory onwerSignature, bytes memory guardianSignerSignature) = signatureSplit(signatures);
        // Get the signing address for this account from the guardian Contract
        address guardianSigner = TokenGuardian(guardian).getGuardian();

        bool isOwner = SignatureChecker.isValidSignatureNow(owner(), dataHash, onwerSignature);
        bool isGuardian = SignatureChecker.isValidSignatureNow(guardianSigner, dataHash, guardianSignerSignature);

        if (isOwner && isGuardian) {
            return true;
        }
        return false;
        
    }

    function getTransactionHash(Tx memory _transaction) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("Tx(address to,uint256 value,uint256 nonce,bytes data)"),
                _transaction.to,
                _transaction.value,
                _transaction.nonce,
                keccak256(bytes(_transaction.data))
            )
        );
    }

    /// @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s`.
    /// @param signatures concatenated rsv signatures
    function signatureSplit(bytes memory signatures)
        internal
        pure
        returns (bytes memory onwerSignature, bytes memory guardianSignerSignature)
    {
        // The signature should be compactly encoded using encodePacked in
        // the format (uint8 v1, bytes32 r1, bytes32 s1, uint8 v2, bytes32 r2, bytes32 s2)
        (uint8 v1, bytes32 r1, bytes32 s1, uint8 v2, bytes32 r2, bytes32 s2) =
            abi.decode(signatures, (uint8, bytes32, bytes32, uint8, bytes32, bytes32));
        onwerSignature = abi.encodePacked(r1, s1, v1);
        guardianSignerSignature = abi.encodePacked(r2, s2, v2);
    }
}
