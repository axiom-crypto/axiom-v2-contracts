// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAxiomV2Client {
    /// @notice Emitted when a callback is made from AxiomV2Query via an on-chain query.
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  caller The address of the account that initiated the query.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    /// @param  queryId The unique ID identifying the query.
    event AxiomV2Call(
        uint64 indexed sourceChainId, address caller, bytes32 indexed querySchema, uint256 indexed queryId
    );

    /// @notice Emitted when a callback is made from AxiomV2Query via an off-chain query.
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  caller The address of the account that initiated the query fulfillment.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    /// @param  queryId The unique ID identifying the query.
    event AxiomV2OffchainCall(
        uint64 indexed sourceChainId, address caller, bytes32 indexed querySchema, uint256 indexed queryId
    );

    /// @notice Return the address of the AxiomV2Query contract.
    /// @return The address of the AxiomV2Query contract.
    function axiomV2QueryAddress() external view returns (address);

    /// @notice Callback which is intended to be called upon on-chain query fulfillment by AxiomV2Query
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  caller The address of the account that initiated the query.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    /// @param  queryId The unique ID identifying the query.
    /// @param  axiomResults The results of the query.
    /// @param  extraData Additional data passed to the callback.
    function axiomV2Callback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) external;

    /// @notice Callback which is intended to be called upon off-chain query fulfillment by AxiomV2Query
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  caller The address of the account that initiated the query fulfillment.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    /// @param  queryId The unique ID identifying the query.
    /// @param  axiomResults The results of the query.
    /// @param  extraData Additional data passed to the callback.
    function axiomV2OffchainCallback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) external;

    /// @dev Error returned if initialized with `axiomV2QueryAddress` set to the zero address.
    error AxiomV2QueryAddressIsZero();

    /// @dev Error returned if the caller is not the AxiomV2Query contract.
    error CallerMustBeAxiomV2Query();
}
