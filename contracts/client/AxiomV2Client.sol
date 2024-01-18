// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2Client } from "../interfaces/client/IAxiomV2Client.sol";

abstract contract AxiomV2Client is IAxiomV2Client {
    /// @dev address of AxiomV2Query
    address public immutable axiomV2QueryAddress;

    /// @notice Whether the callback is made from an on-chain or off-chain query
    /// @param OnChain The callback is made from an on-chain query
    /// @param OffChain The callback is made from an off-chain query
    enum AxiomCallbackType {
        OnChain,
        OffChain
    }

    /// @notice Construct a new AxiomV2Client contract.
    /// @param  _axiomV2QueryAddress The address of the AxiomV2Query contract.
    constructor(address _axiomV2QueryAddress) {
        if (_axiomV2QueryAddress == address(0)) {
            revert AxiomV2QueryAddressIsZero();
        }
        axiomV2QueryAddress = _axiomV2QueryAddress;
    }

    /// @inheritdoc IAxiomV2Client
    function axiomV2Callback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) external {
        if (msg.sender != axiomV2QueryAddress) {
            revert CallerMustBeAxiomV2Query();
        }
        emit AxiomV2Call(sourceChainId, caller, querySchema, queryId);

        _validateAxiomV2Call(AxiomCallbackType.OnChain, sourceChainId, caller, querySchema, queryId, extraData);
        _axiomV2Callback(sourceChainId, caller, querySchema, queryId, axiomResults, extraData);
    }

    /// @inheritdoc IAxiomV2Client
    function axiomV2OffchainCallback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) external {
        if (msg.sender != axiomV2QueryAddress) {
            revert CallerMustBeAxiomV2Query();
        }
        emit AxiomV2OffchainCall(sourceChainId, caller, querySchema, queryId);

        _validateAxiomV2Call(AxiomCallbackType.OffChain, sourceChainId, caller, querySchema, queryId, extraData);
        _axiomV2Callback(sourceChainId, caller, querySchema, queryId, axiomResults, extraData);
    }

    /// @notice Validate the callback from AxiomV2Query
    /// @param  callbackType Whether the callback is made from an on-chain or off-chain query
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  caller The address of the account that initiated the query.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    /// @param  queryId The unique ID identifying the query.
    /// @param  extraData Additional data passed to the callback.
    function _validateAxiomV2Call(
        AxiomCallbackType callbackType,
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes calldata extraData
    ) internal virtual;

    /// @notice Perform application logic after receiving callback.
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  caller The address of the account that initiated the query.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    /// @param  queryId The unique ID identifying the query.
    /// @param  axiomResults The results of the query.
    /// @param  extraData Additional data passed to the callback.
    function _axiomV2Callback(
        uint64 sourceChainId,
        address caller,
        bytes32 querySchema,
        uint256 queryId,
        bytes32[] calldata axiomResults,
        bytes calldata extraData
    ) internal virtual;
}
