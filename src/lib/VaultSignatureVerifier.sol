// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { EIP712 } from "openzeppelin-contracts/utils/cryptography/EIP712.sol";
import { ITokenShieldGuardian as Guardian } from "src/interfaces/ITokenShieldGuardian.sol";
import { IERC6551Account } from "src/interfaces/IERC6551Account.sol";
////// Errors

error VaultSignatureVerifier__NonceNotCorrect();
error VaultSignatureVerifier__ToAddressNotSame();
error VaultSignatureVerifier__ValueNotSame();

abstract contract VaultSignatureVerifier is EIP712, IERC6551Account {
    //////////// Structs
    struct Tx {
        address to;
        uint256 value;
        uint256 nonce;
        bytes data;
    }

    //////////// Storage Varibales
    address immutable guardian;

    constructor(address _guardian) EIP712("TokenShield", "1") {
        guardian = _guardian;
    }

    function owner() public view virtual returns (address) { }

    function checkSignature(
        address owner,
        bytes memory data,
        address to,
        uint256 value,
        uint256 state
    )
        internal
        view
        returns (bool)
    {
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
    }

    function splitAndCheckSignature(
        bytes32 dataHash,
        bytes memory signatures,
        uint16 requiredSignatures
    )
        internal
        view
    {
        require(signatures.length >= requiredSignatures * 65, "signatures too short");
        // There cannot be an owner with address 0.
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        // console.log("Starting loop...");
        for (i = 0; i < requiredSignatures; i++) {
            (v, r, s) = signatureSplit(signatures, i);

            // EOA guardian reccover follow the eth_sign flow, the messageHash with the Ethereum message prefix
            // before applying ecrecover
            currentOwner = SignatureChecker.isValidSignatureNow(owner(), dataHash, );

            require(currentOwner > lastOwner, "verify failed");

            require(
                Guardian(guardian).getGuardian() == currentOwner || owner() == currentOwner, "verify not owner"
            );
            lastOwner = currentOwner;
        }
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
    /// @notice Make sure to perform a bounds check for @param pos, to avoid out of bounds access on @param signatures
    /// @param pos which signature to read. A prior bounds check of this parameter should be performed, to avoid out of
    /// bounds access
    /// @param signatures concatenated rsv signatures
    function signatureSplit(
        bytes memory signatures,
        uint256 pos
    )
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }
}
