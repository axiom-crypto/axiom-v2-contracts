// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { AxiomAccess } from "../libraries/access/AxiomAccess.sol";
import { IAxiomV2Prover } from "../interfaces/query/IAxiomV2Prover.sol";
import { IAxiomV2Query } from "../interfaces/query/IAxiomV2Query.sol";
import { IAxiomV2HeaderVerifier } from "../interfaces/query/IAxiomV2HeaderVerifier.sol";

/// @title AxiomV2Prover
/// @notice Contract controlling prover permissions for fulfilling Axiom V2 queries
contract AxiomV2Prover is IAxiomV2Prover, AxiomAccess, UUPSUpgradeable {
    /// @dev The address of AxiomV2Query
    address public axiomQueryAddress;

    /// @dev `allowedProvers[keccak(querySchema . target)][prover]` is true
    ///      if `prover` is allowed to fulfill queries of type `querySchema` with the given callback
    mapping(bytes32 => mapping(address => bool)) public allowedProvers;

    /// @custom:oz-upgrades-unsafe-allow constructor
    /// @notice Prevents the implementation contract from being initialized outside of the upgradeable proxy.
    constructor() {
        _disableInitializers();
    }

    /// @dev Initialize the contract.
    /// @param _axiomQueryAddress The address of the AxiomV2Query contract.
    /// @param prover The address with the permission of a 'prover'.
    /// @param timelock The address with the permission of a 'timelock'.
    /// @param guardian The address with the permission of a 'guardian'.
    /// @param unfreeze The address with the permission of a 'unfreeze'.
    function initialize(
        address _axiomQueryAddress,
        address prover,
        address timelock,
        address guardian,
        address unfreeze
    ) public initializer {
        __UUPSUpgradeable_init();
        __AxiomAccess_init_unchained();

        if (_axiomQueryAddress == address(0)) {
            revert AxiomQueryAddressIsZero();
        }
        if (prover == address(0)) {
            revert ProverAddressIsZero();
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

        axiomQueryAddress = _axiomQueryAddress;
        emit UpdateAxiomQueryAddress(_axiomQueryAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, timelock);
        _grantRole(TIMELOCK_ROLE, timelock);
        _grantRole(GUARDIAN_ROLE, guardian);
        _grantRole(PROVER_ROLE, prover);
        _grantRole(UNFREEZE_ROLE, unfreeze);
    }

    /// @inheritdoc IAxiomV2Prover
    function fulfillQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        IAxiomV2Query.AxiomV2Callback calldata callback,
        IAxiomV2Query.AxiomV2QueryWitness calldata queryWitness
    ) external onlyNotFrozen {
        bytes32 querySchema = _getQuerySchema(proof);
        _validateProver(querySchema, callback.target, msg.sender);
        IAxiomV2Query(axiomQueryAddress).fulfillQuery(mmrWitness, computeResults, proof, callback, queryWitness);
    }

    /// @inheritdoc IAxiomV2Prover
    function fulfillOffchainQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        IAxiomV2Query.AxiomV2Callback calldata callback,
        bytes32 userSalt
    ) external onlyNotFrozen {
        bytes32 querySchema = _getQuerySchema(proof);
        _validateProver(querySchema, callback.target, msg.sender);
        IAxiomV2Query(axiomQueryAddress).fulfillOffchainQuery(
            mmrWitness, computeResults, proof, callback, msg.sender, userSalt
        );
    }

    /// @dev Add allowed prover address for a given query schema and target address
    /// @param querySchema The query schema
    /// @param target The callback address
    /// @param prover The prover address
    function addAllowedProver(bytes32 querySchema, address target, address prover) external onlyRole(TIMELOCK_ROLE) {
        allowedProvers[keccak256(abi.encodePacked(querySchema, target))][prover] = true;
        emit AddAllowedProver(querySchema, target, prover);
    }

    /// @dev Remove allowed prover address for a given query schema and target address
    /// @param querySchema The query schema
    /// @param target The callback address
    /// @param prover The prover address
    function removeAllowedProver(bytes32 querySchema, address target, address prover)
        external
        onlyRole(TIMELOCK_ROLE)
    {
        allowedProvers[keccak256(abi.encodePacked(querySchema, target))][prover] = false;
        emit RemoveAllowedProver(querySchema, target, prover);
    }

    /// @dev Reads the query schema from the proof instance data.
    /// @param proof The ZK proof data
    /// @return querySchema The claimed query schema the ZK proof corresponds to
    function _getQuerySchema(bytes calldata proof) internal pure returns (bytes32) {
        return bytes32(
            (uint256(bytes32(proof[384 + 8 * 32:384 + 9 * 32])) << 128)
                | uint256(bytes32(proof[384 + 9 * 32:384 + 10 * 32]))
        );
    }

    /// @dev Validate that the prover is allowed to fulfill the query
    /// @param querySchema The query schema
    /// @param target The callback address
    /// @param prover The prover address
    function _validateProver(bytes32 querySchema, address target, address prover) internal view {
        if (hasRole(PROVER_ROLE, address(0)) || hasRole(PROVER_ROLE, prover)) {
            return;
        }
        if (!allowedProvers[keccak256(abi.encodePacked(querySchema, target))][prover]) {
            revert ProverNotAuthorized();
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(IAxiomV2Prover).interfaceId || super.supportsInterface(interfaceId);
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
