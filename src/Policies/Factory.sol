// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Initializable } from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { SafeProxyFactory } from "lib/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import { Policy } from "src/abstract/Policy/Policy.sol";
import { VaultModule } from "src/Modules/VaultModule.sol";
import { Errors } from "src/utils/Errors.sol";
import { Events } from "src/utils/Events.sol";
/**
 * @title Factory
 * @author 0xnightfall.eth
 * @notice This factory policy is used for the creation of a Vault
 */

contract Factory is Initializable, UUPSUpgradeable, Policy {
    VaultModule public vaultStorage;

    constructor(address _kernal) Policy(_kernal) {
        _disableInitializers(); //Stops the implementation contract from being initialized
    }

    /**
     * @notice isMintable is used to check whether the minting of vaults is allowed
     */
    modifier isMintable() {
        if (!vaultStorage.isMint()) {
            revert Errors.Factory_NotMintable();
        }
        _;
    }

    ///////////////////////////////////
    /////// External Functions ////////
    ///////////////////////////////////

    /// @notice Initialize function is used by the proxy to initialize itself once it is deployed
    function initialize() external initializer {
        __UUPSUpgradeable_init();
    }

    function configureDependencies() external override onlyKernal returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](1);

        dependencies[0] = Keycode.wrap("VTM");
        vaultStorage = VaultModule(getModuleAddress(Keycode.wrap("VTM")));
    }

    /// @notice Creates a Vault, mints the respective NFT for it and diverts the minting fee to the FeePool
    /// @param isProVault boolean which specifies if the creating vault is a pro vault or not
    function createVault(bool isProVault) external payable isMintable returns (address account) {
        if (isProVault) {
            if (msg.value < getWeiPerUsd()) {
                revert Errors.Factory_NotEnoughEthSent();
            }
            account = _mintProVault();
        } else {
            account = _mintVault();
        }

        emit Events.Factory_VaultCreated(address(account));
    }

    ///////////////////////////////////
    /////// Internal Functions ////////
    ///////////////////////////////////

    function _mintProVault() internal returns (address _account) {
        revert Errors.Factory_ProVaultNotMintable();
    }

    function _mintVault() internal returns (address _account) {
        SafeProxyFactory safeFactory = vaultStorage.safeFactory();
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyKernal { }

    ///////////////////////////////////
    //////// Getter Functions /////////
    ///////////////////////////////////
    function getWeiPerUsd() public view returns (uint256 weiPerUsd) {
        uint8 decimal = vaultStorage.ethPriceFeed().decimals();
        (
            /* uint80 roundID */
            ,
            int256 answer,
            /*uint startedAt*/
            ,
            uint256 timeStamp,
            /*uint80 answeredInRound*/
        ) = vaultStorage.ethPriceFeed().latestRoundData();
        if (block.timestamp - timeStamp > vaultStorage.maxStaleDataTime()) { }
        uint256 chainlinkPrice;
        if (answer < 0) {
            revert Errors.Factory_PriceFeedReturnsZeroOrLess();
        } else {
            chainlinkPrice = uint256(answer);
        }
        // console.log(chainlinkPrice);
        uint256 decimalCorrection = 10 ** decimal;
        weiPerUsd = (1 ether * decimalCorrection) / chainlinkPrice;
        require(weiPerUsd != 0, "Cant be zero");
        // console.log("Wei Per USD");
        // console.log(weiPerUsd);
    }

    function requestPermissions() external view virtual override returns (Permission[] memory requests) {
        requests = new Permission[](1);
        requests[0] = Permission(Keycode.wrap("VTM"), VaultModule.addVault.selector);
    }
}
