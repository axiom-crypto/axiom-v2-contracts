// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

/// @dev Error returned if the minDelay is too short
error MinDelayTooShort();

/// @title  Axiom Upgrades Timelock
/// @author Axiom
/// @notice Timelock controller to govern Axiom V2 smart contract upgrades.
contract AxiomTimelock is TimelockController {
    /// @notice Initialize the timelock controller.
    /// @param  minDelay The initial minimum delay (in seconds) for timelock operations.
    /// @param  _multisig The address of the multisig to use for proposing and executing operations.
    /// @dev    Initializes the `TimelockController` with the following parameters:
    ///         - `minDelay`: initial minimum delay (in seconds) for operations
    ///         - `proposers`: `_multisig`
    ///         - `executors`: `_multisig`
    ///         - `admin`: `address(0)` so contract is self-administered
    constructor(uint256 minDelay, address _multisig)
        TimelockController(minDelay, singletonArray(_multisig), singletonArray(_multisig), address(0))
    {
        // enforces minimum delay is at least 3 hours
        if (minDelay < 3 * 60 * 60) {
            revert MinDelayTooShort();
        }
    }
}

/// @dev Error returned if the timelock address is 0.
error TimelockAddressIsZero();

/// @notice Return an array with a single element.
/// @param  addr The address to include in the array.
/// @return array an array with a single element containing `addr`.
function singletonArray(address addr) pure returns (address[] memory) {
    if (addr == address(0)) {
        revert TimelockAddressIsZero();
    }
    address[] memory array = new address[](1);
    array[0] = addr;
    return array;
}
