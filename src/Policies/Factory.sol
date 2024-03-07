// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Initializable } from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title Factory
 * @author 0xnightfall.eth
 * @notice This factory policy is used for the creation of a Vault
 */
contract Factory is Initializable, UUPSUpgradeable {
    constructor() {
        _disableInitializers(); //Stops the implementation contract from being initialized
    }

    /**
     * @notice isMintable is used to check whether the minting of vaults is allowed
     */
    modifier isMintable() {
        _;
    }

    modifier permissioned() {
        
        _;
    }

    /// @notice Initialize function is used by the proxy to initialize itself once it is deployed
    function initialize() external initializer {
        __UUPSUpgradeable_init();
    }

    /// @notice Creates a Vault, mints the respective NFT for it and diverts the minting fee to the FeePool
    /// @param isProVault boolean which specifies if the creating vault is a pro vault or not
    function createVault(bool isProVault) external payable isMintable returns (address account) {
        
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override permissioned { }
}
