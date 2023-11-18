// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AxiomV2Client } from "./AxiomV2Client.sol";

/// @title  Example AxiomV2Client Contract
/// @notice Example AxiomV2Client contract which emits events upon callback.
contract ExampleV2Client is AxiomV2Client {
    /// @dev Error returned if the `sourceChainId` does not match.
    error SourceChainIdDoesNotMatch();

    /// @notice Emitted after validation of a callback.
    /// @param  caller The address of the account that initiated the query.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    event ExampleClientAddrAndSchema(address indexed caller, bytes32 indexed querySchema);

    /// @notice Emitted after callback is made.
    /// @param  queryId The unique ID identifying the query.
    /// @param  axiomResults The results of the query.
    /// @param  extraData Additional data passed to the callback.
    event ExampleClientEvent(uint256 indexed queryId, bytes32[] axiomResults, bytes extraData);

    /// @dev The chain ID of the chain whose data the callback is expected to be called from.
    uint64 public callbackSourceChainId;

    /// @notice Construct a new ExampleV2Client contract.
    /// @param  _axiomV2QueryAddress The address of the AxiomV2Query contract.
    /// @param  _callbackSourceChainId The ID of the chain the query reads from.
    constructor(address _axiomV2QueryAddress, uint64 _callbackSourceChainId) AxiomV2Client(_axiomV2QueryAddress) {
        callbackSourceChainId = _callbackSourceChainId;
    }

    /// @inheritdoc AxiomV2Client
    function _validateAxiomV2Call(
        AxiomCallbackType callbackType,
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes calldata extraData
    ) internal override {
        if (sourceChainId != callbackSourceChainId) {
            revert SourceChainIdDoesNotMatch();
        }

        // We do not validate the caller or querySchema for example purposes,
        // but a typical application will want to validate that the querySchema matches
        // their application.
        emit ExampleClientAddrAndSchema(caller, querySchema);
    }

    /// @inheritdoc AxiomV2Client
    function _axiomV2Callback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) internal override {
        emit ExampleClientEvent(queryId, axiomResults, extraData);
    }
}
