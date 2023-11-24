// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error NotAuthorizedExecutor();
error Executor__OnlyCallOpAllowed();
error Executor__NotValidSig();


abstract contract ERC6551Executor {
    uint8 constant OP_CALL = 0;
    /**
     * Executes a low-level operation from this account if the caller is a valid executor
     *
     * @param to Account to operate on
     * @param value Value to send with operation
     * @param data Encoded calldata of operation
     * @param operation Operation type (0=CALL, 1=DELEGATECALL, 2=CREATE, 3=CREATE2)
     */

    function execute(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation
    )
        external
        payable
        virtual
        returns (bytes memory)
    {
        if (!isValidExecutor(msg.sender)) revert NotAuthorizedExecutor();
        if (operation != OP_CALL) {
            revert Executor__OnlyCallOpAllowed();
        }
        (bool isValidSig, bytes memory txData) = checkSignature(data, to, value);
        if (!isValidSig) {
            revert Executor__NotValidSig();
        }
        beforeExecute();
        return _call(to, value, txData);
    }

    function _call(address to, uint256 value, bytes memory data) internal returns (bytes memory result) {
        bool success;
        (success, result) = to.call{ value: value }(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function owner() public view virtual returns (address);

    function beforeExecute() internal virtual returns (uint256);

    function isValidExecutor(address _sender) public virtual returns (bool isExecutor) {
        if (_sender == owner()) {
            return true;
        }
        return false;
    }

    function checkSignature(
        bytes memory data,
        address to,
        uint256 value
    )
        public
        view
        virtual
        returns (bool isValidSig, bytes memory txData){
            return (false, "");
        }
}
