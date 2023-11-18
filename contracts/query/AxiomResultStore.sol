// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { IAxiomResultStore } from "../interfaces/query/IAxiomResultStore.sol";
import { AxiomAccess } from "../libraries/access/AxiomAccess.sol";

/// @title AxiomResultStore
/// @notice Contract storing results of Axiom queries
contract AxiomResultStore is IAxiomResultStore, AxiomAccess, UUPSUpgradeable {
    mapping(bytes32 => bytes32) public results;

    /// @custom:oz-upgrades-unsafe-allow constructor
    /// @notice Prevents the implementation contract from being initialized outside of the upgradeable proxy.
    constructor() {
        _disableInitializers();
    }

    /// @dev Initialize the contract.
    /// @param axiomQueryAddress The address of the AxiomV2Query contract.
    /// @param timelock The address with the permission of a 'timelock'.
    /// @param guardian The address with the permission of a 'guardian'.
    /// @param unfreeze The address with the permission of a 'unfreezer'.
    function initialize(address axiomQueryAddress, address timelock, address guardian, address unfreeze)
        public
        initializer
    {
        __UUPSUpgradeable_init();
        __AxiomAccess_init_unchained();

        if (axiomQueryAddress == address(0)) {
            revert AxiomQueryAddressIsZero();
        }
        if (timelock == address(0)) {
            revert TimelockAddressIsZero();
        }
        if (guardian == address(0)) {
            revert GuardianAddressIsZero();
        }
        if (unfreeze == address(0)) {
            revert UnfreezeAddressIsZero();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, timelock);
        _grantRole(TIMELOCK_ROLE, timelock);
        _grantRole(GUARDIAN_ROLE, guardian);
        _grantRole(UNFREEZE_ROLE, unfreeze);
        _grantRole(AXIOM_ROLE, axiomQueryAddress);
    }

    /// @inheritdoc IAxiomResultStore
    function writeResultHash(bytes32 queryHash, bytes32 resultHash) external onlyRole(AXIOM_ROLE) onlyNotFrozen {
        results[queryHash] = resultHash;
        emit AxiomResultHashWritten(queryHash, resultHash);
    }

    /// @inheritdoc IAxiomResultStore
    function getResultHash(bytes32 queryHash) external view returns (bytes32) {
        return results[queryHash];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(IAxiomResultStore).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address) internal override onlyRole(TIMELOCK_ROLE) { }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[40] private __gap;
}
