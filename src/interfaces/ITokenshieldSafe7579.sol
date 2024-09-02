interface ITokenshieldSafe7579 {
    /**
     * @dev checks if a Module is installed in account
     */
    function isModuleInstalled(
        uint256 moduleType,
        address module,
        bytes calldata additionalContext
    )
        external
        view
        returns (bool);
}
