// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2HeaderVerifier } from "./IAxiomV2HeaderVerifier.sol";
import { IAxiomV2Query } from "./IAxiomV2Query.sol";

interface IAxiomV2Prover {
    /// @notice Emitted when the AxiomQuery address is updated
    /// @param  axiomQueryAddress The new AxiomQuery address
    event UpdateAxiomQueryAddress(address axiomQueryAddress);

    /// @notice Emitted when a prover is added for a given query schema and callback
    /// @param  querySchema The query schema
    /// @param  target The callback address
    /// @param  prover The prover address
    event AddAllowedProver(bytes32 indexed querySchema, address target, address prover);

    /// @notice Emitted when a prover is removed for a given query schema and callback
    /// @param  querySchema The query schema
    /// @param  target The callback address
    /// @param  prover The prover address
    event RemoveAllowedProver(bytes32 indexed querySchema, address target, address prover);

    /// @notice Fulfill an Axiom query made on-chain
    /// @param  mmrWitness Witness data allowing verification of the proof against the MMR of block
    ///         hashes in AxiomV2Core
    /// @param  computeResults The query results to be passed to the callback
    /// @param  proof The ZK proof data
    /// @param  callback Callback to be called after,
    /// @param  queryWitness Witness data identifying the query.
    function fulfillQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        IAxiomV2Query.AxiomV2Callback calldata callback,
        IAxiomV2Query.AxiomV2QueryWitness calldata queryWitness
    ) external;

    /// @notice Fulfill an Axiom query made off-chain
    /// @param  mmrWitness Witness data allowing verification of the proof against the MMR of block
    ///         hashes in AxiomV2Core
    /// @param  computeResults The query results to be passed to the callback
    /// @param  proof The ZK proof data
    /// @param  callback The callback to be called with the query results.
    /// @param  userSalt The salt used to generate the queryId
    function fulfillOffchainQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        IAxiomV2Query.AxiomV2Callback calldata callback,
        bytes32 userSalt
    ) external;

    /// @dev Error returned if the AxiomV2Query address is 0.
    error AxiomQueryAddressIsZero();

    /// @dev Error returned if the timelock address is 0.
    error TimelockAddressIsZero();

    /// @dev Error returned if the guardian address is 0.
    error GuardianAddressIsZero();

    /// @dev Error returned if the unfreeze address is 0.
    error UnfreezeAddressIsZero();

    /// @dev Error returned if the prover address is 0.
    error ProverAddressIsZero();

    /// @dev Error returned if an unauthorized prover attempts to fulfill a query.
    error ProverNotAuthorized();
}
