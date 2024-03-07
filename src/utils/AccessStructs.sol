// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


/**
 * @dev Defines permission for a policy to have access to the `funcSelector` at a
 *      specific module contract via its keycode.
 */
struct Permissions {
    Keycode keycode;
    bytes4 funcSelector;
}

/**
 * @dev A 5-character keycode that references a module contract.
 */
type Keycode is bytes5;

/**
 * @dev A unique role which can be granted or revoked by the admin.
 */
type Role is bytes32;