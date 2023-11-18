// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAxiomResultStore {
    /// @notice Emitted when a result hash is written
    /// @param  queryHash The unique hash identifying the query.
    /// @param  resultHash The hash of the result.
    event AxiomResultHashWritten(bytes32 indexed queryHash, bytes32 resultHash);

    /// @notice Write a result hash to the result store
    /// @param  queryHash The unique hash identifying the query.
    /// @param  resultHash The hash of the result.
    function writeResultHash(bytes32 queryHash, bytes32 resultHash) external;

    /// @notice Read a result hash from the result store
    /// @param  queryHash The unique hash identifying the query.
    /// @return resultHash The hash of the result.
    function getResultHash(bytes32 queryHash) external view returns (bytes32);

    /// @dev Error returned if the AxiomV2Query address is 0.
    error AxiomQueryAddressIsZero();

    /// @dev Error returned if the timelock address is 0.
    error TimelockAddressIsZero();

    /// @dev Error returned if the guardian address is 0.
    error GuardianAddressIsZero();

    /// @dev Error returned if the unfreeze address is 0.
    error UnfreezeAddressIsZero();
}
