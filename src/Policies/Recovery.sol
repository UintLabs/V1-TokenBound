// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/utils/AccessStructs.sol";
import { Initializable } from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { Policy } from "src/abstract/Policy/Policy.sol";

import { VaultModule } from "src/Modules/VaultModule.sol";

contract Recovery is Initializable, UUPSUpgradeable, Policy {
    VaultModule public vaultStorage;

    constructor(address _kernal) Policy(_kernal) { }

    ///////////////////////////////////
    /////// External Functions ////////
    ///////////////////////////////////

    /// @notice Initialize function is used by the proxy to initialize itself once it is deployed
    function initialize() external initializer {
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyKernal { }

    function configureDependencies() external virtual override returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](1);

        dependencies[0] = Keycode.wrap("VTM");
        vaultStorage = VaultModule(getModuleAddress(Keycode.wrap("VTM")));
    }

    function requestPermissions() external view virtual override returns (Permission[] memory requests) {
        requests = new Permission[](1);
        requests[0] = Permission(Keycode.wrap("VTM"), VaultModule.addVault.selector);
    }

    function policyId() public view virtual override returns (bytes32) {
        return keccak256("RECOVERY");
    }
}
