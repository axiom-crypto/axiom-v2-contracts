// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title  AxiomAccess
/// @notice Abstract contract controlling permissions of Axiom contracts
/// @dev    For use in a UUPS upgradeable contract.
abstract contract AxiomAccess is Initializable, AccessControlUpgradeable {
    bool public frozen;

    /// @notice Storage slot for the address with the permission of a 'timelock'.
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");

    /// @notice Storage slot for the addresses with the permission of a 'guardian'.
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    /// @notice Storage slot for the addresses with the permission of a 'unfreezer'.
    bytes32 public constant UNFREEZE_ROLE = keccak256("UNFREEZE_ROLE");

    /// @notice Storage slot for the addresses with the permission of a 'prover'.
    bytes32 public constant PROVER_ROLE = keccak256("PROVER_ROLE");

    /// @notice Storage slot for the addresses with the permission of different Axiom versions.
    bytes32 public constant AXIOM_ROLE = keccak256("AXIOM_ROLE");

    /// @notice Emitted when the `freezeAll` is called
    event FreezeAll();

    /// @notice Emitted when the `unfreezeAll` is called
    event UnfreezeAll();

    /// @notice Error when trying to call contract while it is frozen
    error ContractIsFrozen();

    /// @notice Error when trying to call contract from address without 'prover' role
    error NotProverRole();

    /// @notice Error when trying to call contract from address without Axiom role
    error NotAxiomRole();

    /**
     * @dev Modifier to make a function callable only by the 'prover' role.
     * As an initial safety mechanism, the 'update_' functions are only callable by the 'prover' role.
     * Granting the prover role to `address(0)` will enable this role for everyone.
     */
    modifier onlyProver() {
        _checkProver();
        _;
    }

    /// @notice Checks that the contract is not frozen.
    modifier onlyNotFrozen() {
        _checkNotFrozen();
        _;
    }

    /// @dev Factor out prover check to reduce contract size.
    function _checkProver() internal view {
        if (!hasRole(PROVER_ROLE, address(0)) && !hasRole(PROVER_ROLE, _msgSender())) {
            revert NotProverRole();
        }
    }

    /// @dev Factor out freeze check to reduce contract size.
    function _checkNotFrozen() internal view {
        if (frozen) {
            revert ContractIsFrozen();
        }
    }

    /// @notice Initializes the contract in the unfrozen state
    function __AxiomAccess_init() internal onlyInitializing {
        __AxiomAccess_init_unchained();
    }

    /// @notice Initializes the contract in the unfrozen state
    function __AxiomAccess_init_unchained() internal onlyInitializing {
        frozen = false;
    }

    /// @notice Set the contract state to frozen, which will disable a set of security-sensitive functions.
    ///         Intended only for use in reaction to an unforeseen vulnerability in ZK circuits or smart contracts.
    function freezeAll() external onlyRole(GUARDIAN_ROLE) {
        frozen = true;
        emit FreezeAll();
    }

    /// @notice Set the contract state to unfrozen, which re-enables a set of security-sensitive functions.
    ///         Intended for use after any vulnerability or potential vulnerability leading to a freeze is fixed.
    function unfreezeAll() external onlyRole(UNFREEZE_ROLE) {
        frozen = false;
        emit UnfreezeAll();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[40] private __gap;
}
