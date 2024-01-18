// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { IAxiomV2HeaderVerifier } from "../interfaces/query/IAxiomV2HeaderVerifier.sol";
import {
    IAxiomV2Query,
    AXIOM_QUERY_STATE_INACTIVE,
    AXIOM_QUERY_STATE_ACTIVE,
    AXIOM_QUERY_STATE_FULFILLED,
    AXIOM_QUERY_STATE_PAID
} from "../interfaces/query/IAxiomV2Query.sol";
import { IAxiomV2Client } from "../interfaces/client/IAxiomV2Client.sol";

import { AxiomAccess } from "../libraries/access/AxiomAccess.sol";
import {
    MAX_DEPOSIT_SIZE,
    MAX_PROOF_VERIFICATION_GAS,
    MAX_AXIOM_QUERY_FEE,
    VERSION
} from "../libraries/configuration/AxiomV2Configuration.sol";

/// @title  AxiomV2Query
/// @notice Axiom smart contract that verifies AxiomV2 queries.
/// @dev    Is a UUPS upgradeable contract.
contract AxiomV2Query is IAxiomV2Query, AxiomAccess, UUPSUpgradeable {
    using Address for address payable;

    /// @dev address of deployed Axiom header verifier
    address public axiomHeaderVerifierAddress;

    /// @dev address of deployed ZKP verifier for queries
    address public verifierAddress;

    /// @dev the set of `aggregateVkeyHashes` accepted for proof fulfillment for any query
    mapping(bytes32 => bool) public aggregateVkeyHashes;

    /// @dev `perQueryAggregateVkeyHashes[querySchema][target][aggregateVkeyHash]` is true
    ///      if `aggregateVkeyHash` is valid for queries of type `querySchema` with callback `target`
    mapping(bytes32 => mapping(address => mapping(bytes32 => bool))) public perQueryAggregateVkeyHashes;

    /// @dev `perQueryProvers[querySchema][target][prover]` is true
    ///      if `prover` is allowed to fulfill queries of type `querySchema` with callback `target`
    mapping(bytes32 => mapping(address => mapping(address => bool))) public perQueryProvers;

    /// @dev the number of blocks after which a query is eligible for refund
    uint32 public queryDeadlineInterval;

    /// @dev the gas allocated for proof verification
    uint32 public proofVerificationGas;

    /// @dev the fee charged for Axiom proofs
    uint256 public axiomQueryFee;

    /// @dev the minimum allowed maxFeePerGas in a query
    uint64 public minMaxFeePerGas;

    /// @dev the maximum allowed queryDeadlineInterval, cannot be changed after initialization
    uint32 public maxQueryDeadlineInterval;

    /// @dev `queries[queryId]` stores the metadata for an on-chain query
    mapping(uint256 => AxiomQueryMetadata) public queries;

    /// @dev `balances[addr]` stores the amount of unescrowed wei deposited by `addr`
    mapping(address => uint256) public balances;

    /// @custom:oz-upgrades-unsafe-allow constructor
    /// @notice Prevents the implementation contract from being initialized outside of the upgradeable proxy.
    constructor() {
        _disableInitializers();
    }

    /// @dev    Initialize the contract.
    /// @param  init the initialization parameters
    function initialize(AxiomV2QueryInit calldata init) public initializer {
        __UUPSUpgradeable_init();
        __AxiomAccess_init_unchained();

        if (init.timelock == address(0)) {
            revert TimelockAddressIsZero();
        }
        if (init.guardian == address(0)) {
            revert GuardianAddressIsZero();
        }
        if (init.unfreeze == address(0)) {
            revert UnfreezeAddressIsZero();
        }

        _updateAxiomHeaderVerifierAddress(init.axiomHeaderVerifierAddress);
        _updateVerifierAddress(init.verifierAddress);

        for (uint256 i; i < init.aggregateVkeyHashes.length;) {
            _addAggregateVkeyHash(init.aggregateVkeyHashes[i]);
            unchecked {
                ++i;
            }
        }

        maxQueryDeadlineInterval = init.maxQueryDeadlineInterval;
        _updateQueryDeadlineInterval(init.queryDeadlineInterval);
        _updateProofVerificationGas(init.proofVerificationGas);
        _updateAxiomQueryFee(init.axiomQueryFee);
        _updateMinMaxFeePerGas(init.minMaxFeePerGas);

        _grantRole(DEFAULT_ADMIN_ROLE, init.timelock);
        _grantRole(TIMELOCK_ROLE, init.timelock);
        _grantRole(GUARDIAN_ROLE, init.guardian);
        _grantRole(UNFREEZE_ROLE, init.unfreeze);

        address prover;
        for (uint256 i; i < init.proverAddresses.length;) {
            prover = init.proverAddresses[i];
            if (prover == address(0)) {
                revert ProverAddressIsZero();
            }
            _grantRole(PROVER_ROLE, prover);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Updates the address of the IAxiomV2HeaderVerifier contract used to validate blockhashes, governed by a 'timelock'.
    /// @param  _axiomHeaderVerifierAddress the new address
    function updateAxiomHeaderVerifierAddress(address _axiomHeaderVerifierAddress) external onlyRole(TIMELOCK_ROLE) {
        _updateAxiomHeaderVerifierAddress(_axiomHeaderVerifierAddress);
    }

    /// @notice Updates the address of the query verifier contract, governed by a 'timelock'.
    /// @param  _verifierAddress the new address
    function updateVerifierAddress(address _verifierAddress) external onlyRole(TIMELOCK_ROLE) {
        _updateVerifierAddress(_verifierAddress);
    }

    /// @notice Add a new `aggregateVkeyHash` which can be used to fulfill queries.
    /// @param  _aggregateVkeyHash the new `aggregateVkeyHash`
    function addAggregateVkeyHash(bytes32 _aggregateVkeyHash) external onlyRole(TIMELOCK_ROLE) {
        _addAggregateVkeyHash(_aggregateVkeyHash);
    }

    /// @notice Remove an existing `aggregateVkeyHash` which can be used to fulfill queries.
    /// @param  _aggregateVkeyHash the `aggregateVkeyHash` to remove
    function removeAggregateVkeyHash(bytes32 _aggregateVkeyHash) external onlyRole(TIMELOCK_ROLE) {
        aggregateVkeyHashes[_aggregateVkeyHash] = false;
        emit RemoveAggregateVkeyHash(_aggregateVkeyHash);
    }

    /// @notice Updates the query deadline interval, governed by a 'timelock'.
    /// @param  _queryDeadlineInterval the new query deadline interval
    function updateQueryDeadlineInterval(uint32 _queryDeadlineInterval) external onlyRole(TIMELOCK_ROLE) {
        _updateQueryDeadlineInterval(_queryDeadlineInterval);
    }

    /// @notice Updates the proof verification gas, governed by a 'timelock'.
    /// @param  _proofVerificationGas the new proof verification gas
    function updateProofVerificationGas(uint32 _proofVerificationGas) external onlyRole(TIMELOCK_ROLE) {
        _updateProofVerificationGas(_proofVerificationGas);
    }

    /// @notice Updates the Axiom query fee, governed by a 'timelock'.
    /// @param  _axiomQueryFee the new Axiom query fee
    function updateAxiomQueryFee(uint256 _axiomQueryFee) external onlyRole(TIMELOCK_ROLE) {
        _updateAxiomQueryFee(_axiomQueryFee);
    }

    /// @notice Updates the minimum allowed maxFeePerGas in a query, governed by a 'timelock'.
    /// @param  _minMaxFeePerGas the new minimum allowed maxFeePerGas
    function updateMinMaxFeePerGas(uint64 _minMaxFeePerGas) external onlyRole(TIMELOCK_ROLE) {
        _updateMinMaxFeePerGas(_minMaxFeePerGas);
    }

    /// @notice Add allowed aggregateVkeyHash for a given query schema and target address
    /// @param querySchema The query schema
    /// @param target The callback address
    /// @param aggregateVkeyHash The aggregateVkeyHash to add
    function addPerQueryAggregateVkeyHash(bytes32 querySchema, address target, bytes32 aggregateVkeyHash)
        external
        onlyRole(TIMELOCK_ROLE)
    {
        perQueryAggregateVkeyHashes[querySchema][target][aggregateVkeyHash] = true;
        emit AddPerQueryAggregateVkeyHash(querySchema, target, aggregateVkeyHash);
    }

    /// @notice Remove allowed aggregateVkeyHash for a given query schema and target address
    /// @param querySchema The query schema
    /// @param target The callback address
    /// @param aggregateVkeyHash The aggregateVkeyHash to add
    function removePerQueryAggregateVkeyHash(bytes32 querySchema, address target, bytes32 aggregateVkeyHash)
        external
        onlyRole(TIMELOCK_ROLE)
    {
        perQueryAggregateVkeyHashes[querySchema][target][aggregateVkeyHash] = false;
        emit RemovePerQueryAggregateVkeyHash(querySchema, target, aggregateVkeyHash);
    }

    /// @dev Add allowed prover address for a given query schema and target address
    /// @param querySchema The query schema
    /// @param target The callback address
    /// @param prover The prover address
    function addPerQueryProver(bytes32 querySchema, address target, address prover) external onlyRole(TIMELOCK_ROLE) {
        perQueryProvers[querySchema][target][prover] = true;
        emit AddPerQueryProver(querySchema, target, prover);
    }

    /// @dev Remove allowed prover address for a given query schema and target address
    /// @param querySchema The query schema
    /// @param target The callback address
    /// @param prover The prover address
    function removePerQueryProver(bytes32 querySchema, address target, address prover)
        external
        onlyRole(TIMELOCK_ROLE)
    {
        perQueryProvers[querySchema][target][prover] = false;
        emit RemovePerQueryProver(querySchema, target, prover);
    }

    /// @inheritdoc IAxiomV2Query
    function sendQuery(
        uint64 sourceChainId,
        bytes32 dataQueryHash,
        AxiomV2ComputeQuery calldata computeQuery,
        AxiomV2Callback calldata callback,
        AxiomV2FeeData calldata feeData,
        bytes32 userSalt,
        address refundee,
        bytes calldata /* dataQuery */
    ) external payable onlyNotFrozen returns (uint256 queryId) {
        if (sourceChainId != IAxiomV2HeaderVerifier(axiomHeaderVerifierAddress).getSourceChainId()) {
            revert SourceChainIdDoesNotMatch();
        }

        if (refundee == address(0)) {
            refundee = msg.sender;
        }

        bytes32 queryHash;
        if (computeQuery.k == 0) {
            queryHash = keccak256(
                abi.encodePacked(VERSION, sourceChainId, dataQueryHash, computeQuery.k, computeQuery.resultLen)
            );
        } else {
            bytes memory encodedComputeQuerySchema = abi.encodePacked(
                computeQuery.k, computeQuery.resultLen, uint8(computeQuery.vkey.length), computeQuery.vkey
            );
            queryHash = keccak256(
                abi.encodePacked(
                    VERSION,
                    sourceChainId,
                    dataQueryHash,
                    encodedComputeQuerySchema,
                    uint32(computeQuery.computeProof.length),
                    computeQuery.computeProof
                )
            );
        }

        queryId = _computeQueryId(
            queryHash, keccak256(abi.encodePacked(callback.target, callback.extraData)), userSalt, refundee, msg.sender
        );
        _sendQuery(queryId, feeData.maxFeePerGas, feeData.callbackGasLimit, feeData.overrideAxiomQueryFee);

        emit QueryInitiatedOnchain(
            msg.sender, queryHash, queryId, userSalt, refundee, callback.target, callback.extraData
        );
    }

    /// @inheritdoc IAxiomV2Query
    function sendQueryWithIpfsData(
        bytes32 queryHash,
        bytes32 ipfsHash,
        AxiomV2Callback calldata callback,
        AxiomV2FeeData calldata feeData,
        bytes32 userSalt,
        address refundee
    ) external payable onlyNotFrozen returns (uint256 queryId) {
        if (refundee == address(0)) {
            refundee = msg.sender;
        }

        queryId = _computeQueryId(
            queryHash, keccak256(abi.encodePacked(callback.target, callback.extraData)), userSalt, refundee, msg.sender
        );
        _sendQuery(queryId, feeData.maxFeePerGas, feeData.callbackGasLimit, feeData.overrideAxiomQueryFee);

        emit QueryInitiatedWithIpfsData(
            msg.sender, queryHash, queryId, userSalt, ipfsHash, refundee, callback.target, callback.extraData
        );
    }

    /// @inheritdoc IAxiomV2Query
    function increaseQueryGas(
        uint256 queryId,
        uint64 newMaxFeePerGas,
        uint32 newCallbackGasLimit,
        uint256 overrideAxiomQueryFee
    ) external payable onlyNotFrozen {
        AxiomQueryMetadata storage queryMetadata = queries[queryId];
        if (queryMetadata.state != AXIOM_QUERY_STATE_ACTIVE) {
            revert CanOnlyIncreaseGasOnActiveQuery();
        }
        if (newMaxFeePerGas < minMaxFeePerGas) {
            revert MaxFeePerGasIsTooLow();
        }

        uint256 oldAmount = queryMetadata.payment;

        uint256 _axiomQueryFee = axiomQueryFee;
        if (overrideAxiomQueryFee > _axiomQueryFee) {
            _axiomQueryFee = overrideAxiomQueryFee;
        }
        uint256 newMaxQueryPri = _getMaxQueryPri(newMaxFeePerGas, newCallbackGasLimit, _axiomQueryFee);
        if (newMaxQueryPri <= oldAmount) {
            revert NewMaxQueryPriMustBeLargerThanPrevious();
        }
        uint256 increaseAmount;
        unchecked {
            // in this branch, we know that newMaxQueryPri > oldAmount
            increaseAmount = newMaxQueryPri - oldAmount;
        }
        if (msg.value < increaseAmount) {
            revert InsufficientFunds();
        }
        queryMetadata.payment = newMaxQueryPri;
        emit QueryGasIncreased(queryId, newMaxFeePerGas, newCallbackGasLimit, overrideAxiomQueryFee);

        if (msg.value > increaseAmount) {
            unchecked {
                // in this branch, we know that msg.value > increaseAmount
                _recordDeposit(msg.sender, msg.value - increaseAmount);
            }
        }
    }

    /// @inheritdoc IAxiomV2Query
    function fulfillQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        AxiomV2Callback calldata callback,
        AxiomV2QueryWitness calldata queryWitness
    ) external onlyNotFrozen {
        AxiomProofData memory proofData =
            _verifyResult(mmrWitness, proof, callback.target, keccak256(abi.encodePacked(computeResults)));

        uint256 queryId = _computeQueryId(
            queryWitness.queryHash,
            queryWitness.callbackHash,
            queryWitness.userSalt,
            queryWitness.refundee,
            queryWitness.caller
        );

        if (queryWitness.callbackHash != keccak256(abi.encodePacked(callback.target, callback.extraData))) {
            revert CallbackHashDoesNotMatchQueryWitness();
        }

        if (queryWitness.queryHash != proofData.queryHash) {
            revert QueryHashDoesNotMatchProof();
        }

        AxiomQueryMetadata storage queryMetadata = queries[queryId];
        if (queryMetadata.state != AXIOM_QUERY_STATE_ACTIVE) {
            revert CannotFulfillIfNotActive();
        }

        queryMetadata.payee = proofData.payee;
        queryMetadata.state = AXIOM_QUERY_STATE_FULFILLED;

        bool success;
        /// @dev re-entrancy protection:
        ///   we check and transition the query state before calling a client contract
        if (callback.target != address(0)) {
            bytes memory data = abi.encodeWithSelector(
                IAxiomV2Client.axiomV2Callback.selector,
                proofData.sourceChainId,
                queryWitness.caller,
                proofData.querySchema,
                queryId,
                computeResults,
                callback.extraData
            );

            /// @dev This checks that the callback is provided at least `callbackGasLimit` gas.
            ///      Factor of 64 / 63 accounts for the EIP-150 gas forwarding rule.
            ///      Additional 300 gas accounts for computation of the conditional branch.
            if (gasleft() - 300 <= queryMetadata.callbackGasLimit * 64 / 63) {
                revert InsufficientGasForCallback();
            }
            success = _callWithNoReturn(callback.target, queryMetadata.callbackGasLimit, data);
        }
        emit QueryFulfilled(queryId, proofData.payee, success);
    }

    /// @inheritdoc IAxiomV2Query
    function fulfillOffchainQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        AxiomV2Callback calldata callback,
        bytes32 userSalt
    ) external onlyNotFrozen {
        AxiomProofData memory proofData =
            _verifyResult(mmrWitness, proof, callback.target, keccak256(abi.encodePacked(computeResults)));

        uint256 queryId = _computeQueryId(
            proofData.queryHash,
            keccak256(abi.encodePacked(callback.target, callback.extraData)),
            userSalt,
            address(0),
            msg.sender
        );

        AxiomQueryMetadata storage queryMetadata = queries[queryId];
        if (queryMetadata.state != AXIOM_QUERY_STATE_INACTIVE) {
            revert CannotFulfillFromOffchainIfNotInactive();
        }

        if (proofData.payee != msg.sender) {
            revert OnlyPayeeCanFulfillOffchainQuery();
        }

        queryMetadata.state = AXIOM_QUERY_STATE_FULFILLED;

        bool success;
        /// @dev re-entrancy protection:
        ///   we check and transition the query state before calling a client contract
        if (callback.target != address(0)) {
            bytes memory data = abi.encodeWithSelector(
                IAxiomV2Client.axiomV2OffchainCallback.selector,
                proofData.sourceChainId,
                msg.sender,
                proofData.querySchema,
                queryId,
                computeResults,
                callback.extraData
            );
            success = _callWithNoReturn(callback.target, gasleft(), data);
        }
        emit OffchainQueryFulfilled(queryId, success);
    }

    /// @inheritdoc IAxiomV2Query
    function refundQuery(AxiomV2QueryWitness calldata queryWitness) external onlyNotFrozen {
        address refundee = queryWitness.refundee;
        uint256 queryId = _computeQueryId(
            queryWitness.queryHash, queryWitness.callbackHash, queryWitness.userSalt, refundee, queryWitness.caller
        );

        if (msg.sender != refundee) {
            revert CannotRefundIfNotRefundee();
        }

        AxiomQueryMetadata storage queryMetadata = queries[queryId];
        if (queryMetadata.state != AXIOM_QUERY_STATE_ACTIVE) {
            revert CannotRefundIfNotActive();
        }
        if (block.number <= queryMetadata.deadlineBlockNumber) {
            revert CannotRefundBeforeDeadline();
        }

        unchecked {
            // balances cannot overflow
            balances[refundee] += queryMetadata.payment;
        }

        delete queries[queryId];

        emit QueryRefunded(queryId, refundee);
    }

    /// @inheritdoc IAxiomV2Query
    function deposit(address payor) external payable onlyNotFrozen {
        if (payor == address(0)) {
            revert PayorAddressIsZero();
        }
        if (msg.value == 0) {
            revert DepositAmountIsZero();
        }
        _recordDeposit(payor, msg.value);
    }

    /// @inheritdoc IAxiomV2Query
    function unescrow(AxiomV2QueryWitness calldata queryWitness, uint256 amountUsed) external onlyNotFrozen {
        address refundee = queryWitness.refundee;
        uint256 queryId = _computeQueryId(
            queryWitness.queryHash, queryWitness.callbackHash, queryWitness.userSalt, refundee, queryWitness.caller
        );

        AxiomQueryMetadata storage queryMetadata = queries[queryId];
        if (queryMetadata.state != AXIOM_QUERY_STATE_FULFILLED) {
            revert QueryIsNotFulfilled();
        }
        uint256 payment = queryMetadata.payment;
        if (amountUsed > payment) {
            revert UnescrowAmountExceedsEscrowedAmount();
        }
        address payee = queryMetadata.payee;
        if (msg.sender != payee) {
            revert OnlyPayeeCanUnescrow();
        }

        queryMetadata.state = AXIOM_QUERY_STATE_PAID;

        unchecked {
            // in this branch, we know that amountUsed <= payment
            // in addition, balances cannot overflow
            balances[payee] += amountUsed;
            balances[refundee] += payment - amountUsed;
        }
        emit Unescrow(queryWitness.caller, queryId, payee, refundee, amountUsed);
    }

    /// @inheritdoc IAxiomV2Query
    function withdraw(uint256 amount, address payable payee) external {
        if (payee == address(0)) {
            revert PayeeAddressIsZero();
        }
        if (amount > balances[msg.sender]) {
            revert WithdrawalAmountExceedsFreeBalance();
        }
        if (amount == 0) {
            revert WithdrawalAmountIsZero();
        }

        unchecked {
            // in this branch, we know that amount <= balances[msg.sender]
            balances[msg.sender] -= amount;
        }
        payee.sendValue(amount);
        emit Withdraw(msg.sender, amount, payee);
    }

    /// @dev Update the address of the IAxiomV2HeaderVerifier contract used to validate blockhashes.
    /// @param  _axiomHeaderVerifierAddress the new address
    function _updateAxiomHeaderVerifierAddress(address _axiomHeaderVerifierAddress) internal {
        if (_axiomHeaderVerifierAddress == address(0)) {
            revert AxiomHeaderVerifierAddressIsZero();
        }
        axiomHeaderVerifierAddress = _axiomHeaderVerifierAddress;
        emit UpdateAxiomHeaderVerifierAddress(_axiomHeaderVerifierAddress);
    }

    /// @dev Update the address of the query verifier contract.
    /// @param  _verifierAddress the new address
    function _updateVerifierAddress(address _verifierAddress) internal {
        if (_verifierAddress == address(0)) {
            revert VerifierAddressIsZero();
        }
        verifierAddress = _verifierAddress;
        emit UpdateVerifierAddress(_verifierAddress);
    }

    /// @dev Add a new `aggregateVkeyHash` which can be used to fulfill queries.
    /// @param  _aggregateVkeyHash the new `aggregateVkeyHash`
    function _addAggregateVkeyHash(bytes32 _aggregateVkeyHash) internal {
        aggregateVkeyHashes[_aggregateVkeyHash] = true;
        emit AddAggregateVkeyHash(_aggregateVkeyHash);
    }

    /// @dev Update the query deadline interval.
    /// @param  _queryDeadlineInterval the new query deadline interval
    function _updateQueryDeadlineInterval(uint32 _queryDeadlineInterval) internal {
        if (_queryDeadlineInterval > maxQueryDeadlineInterval) {
            revert QueryDeadlineIntervalIsTooLarge();
        }
        queryDeadlineInterval = _queryDeadlineInterval;
        emit UpdateQueryDeadlineInterval(_queryDeadlineInterval);
    }

    /// @dev Update the proof verification gas.
    /// @param  _proofVerificationGas the new proof verification gas
    function _updateProofVerificationGas(uint32 _proofVerificationGas) internal {
        if (_proofVerificationGas > MAX_PROOF_VERIFICATION_GAS) {
            revert ProofVerificationGasIsTooLarge();
        }
        proofVerificationGas = _proofVerificationGas;
        emit UpdateProofVerificationGas(_proofVerificationGas);
    }

    /// @dev Update the Axiom query fee.
    /// @param  _axiomQueryFee the new Axiom query fee
    function _updateAxiomQueryFee(uint256 _axiomQueryFee) internal {
        if (_axiomQueryFee > MAX_AXIOM_QUERY_FEE) {
            revert AxiomQueryFeeIsTooLarge();
        }
        axiomQueryFee = _axiomQueryFee;
        emit UpdateAxiomQueryFee(_axiomQueryFee);
    }

    /// @dev Update the minimum allowed maxFeePerGas in a query.
    /// @param  _minMaxFeePerGas the new minimum allowed maxFeePerGas
    function _updateMinMaxFeePerGas(uint64 _minMaxFeePerGas) internal {
        if (_minMaxFeePerGas == 0) {
            revert MinMaxFeePerGasIsZero();
        }
        minMaxFeePerGas = _minMaxFeePerGas;
        emit UpdateMinMaxFeePerGas(_minMaxFeePerGas);
    }

    /// @notice Compute the query ID
    /// @param  queryHash The hash of the query.
    /// @param  callbackHash The hash of the callback, defined as `keccak(target || extraData)`
    /// @param  userSalt The user salt.
    /// @param  refundee The address to refund if the query is not fulfilled.
    /// @param  caller The address of the caller submitting the query.
    /// @return queryId The query ID.
    function _computeQueryId(
        bytes32 queryHash,
        bytes32 callbackHash,
        bytes32 userSalt,
        address refundee,
        address caller
    ) internal view returns (uint256 queryId) {
        queryId = uint256(
            keccak256(abi.encodePacked(uint64(block.chainid), caller, userSalt, queryHash, callbackHash, refundee))
        );
    }

    /// @notice Record on-chain query
    /// @param  queryId The unique ID identifying the query.
    /// @param  maxFeePerGas The maxFeePerGas parameter to use when calling the callback.
    /// @param  callbackGasLimit The gasLimit parameter to use when calling the callback.
    /// @param  overrideAxiomQueryFee If larger than `axiomQueryFee`, the value to be used for the query fee.
    function _sendQuery(uint256 queryId, uint64 maxFeePerGas, uint32 callbackGasLimit, uint256 overrideAxiomQueryFee)
        internal
    {
        if (queries[queryId].state != AXIOM_QUERY_STATE_INACTIVE) {
            revert QueryIsNotInactive();
        }

        if (maxFeePerGas < minMaxFeePerGas) {
            revert MaxFeePerGasIsTooLow();
        }

        uint256 _axiomQueryFee = axiomQueryFee;
        if (overrideAxiomQueryFee > _axiomQueryFee) {
            _axiomQueryFee = overrideAxiomQueryFee;
        }

        uint256 maxQueryPri = _getMaxQueryPri(maxFeePerGas, callbackGasLimit, _axiomQueryFee);
        if (msg.value != maxQueryPri) {
            if (msg.value > 0) {
                _recordDeposit(msg.sender, msg.value);
            }

            uint256 _callerBalance = balances[msg.sender];
            if (maxQueryPri > _callerBalance) {
                revert EscrowAmountExceedsBalance();
            }
            unchecked {
                // in this branch, we know that maxQueryPri <= balances[caller] (i.e. _callerBalance)
                balances[msg.sender] = _callerBalance - maxQueryPri;
            }
        } else {
            if (msg.value > MAX_DEPOSIT_SIZE) {
                revert DepositTooLarge();
            }
        }

        uint32 _queryDeadlineInterval = queryDeadlineInterval;
        queries[queryId] = AxiomQueryMetadata({
            state: AXIOM_QUERY_STATE_ACTIVE,
            deadlineBlockNumber: uint32(block.number) + _queryDeadlineInterval,
            callbackGasLimit: callbackGasLimit,
            payee: address(0),
            payment: maxQueryPri
        });
        emit QueryFeeInfoRecorded(
            queryId,
            msg.sender,
            uint32(block.number) + _queryDeadlineInterval,
            maxFeePerGas,
            callbackGasLimit,
            maxQueryPri
        );
    }

    /// @notice Verify a query result on-chain.
    /// @param  mmrWitness Witness data allowing verification of the proof against our cache of block hashes.
    /// @param  proof The ZK proof data.
    /// @param  target The callback address.
    /// @param  computeResultsHash The hash of the compute results.
    function _verifyResult(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes calldata proof,
        address target,
        bytes32 computeResultsHash
    ) internal returns (AxiomProofData memory proofData) {
        //  The public instances are laid out in the proof calldata as follows:
        //    ** First 4 * 3 * 32 = 384 bytes are reserved for proof verification data used with the pairing precompile
        //    ** The next blocks of 11 groups of 32 bytes each are:
        //    ** `sourceChainId`                as a field element
        //    ** `computeResultsHash`           as 2 field elements, in hi-lo form
        //    ** `queryHash`                    as 2 field elements, in hi-lo form
        //    ** `querySchema`                  as 2 field elements, in hi-lo form
        //    ** `blockhashMmrKeccak` which is `keccak256(abi.encodePacked(mmr))` as 2 field elements in hi-lo form.
        //    ** `aggregateVkeyHash`            as a field element
        //    ** `payee`                        as a field element
        proofData.sourceChainId = uint64(uint256(bytes32(proof[384:384 + 32])));
        bytes32 proofComputeResultsHash = bytes32(
            (uint256(bytes32(proof[384 + 32:384 + 2 * 32])) << 128) | uint256(bytes32(proof[384 + 2 * 32:384 + 3 * 32]))
        );
        proofData.queryHash = bytes32(
            (uint256(bytes32(proof[384 + 3 * 32:384 + 4 * 32])) << 128)
                | uint256(bytes32(proof[384 + 4 * 32:384 + 5 * 32]))
        );
        proofData.querySchema = bytes32(
            (uint256(bytes32(proof[384 + 5 * 32:384 + 6 * 32])) << 128)
                | uint256(bytes32(proof[384 + 6 * 32:384 + 7 * 32]))
        );
        bytes32 blockhashMmrKeccak = bytes32(
            (uint256(bytes32(proof[384 + 7 * 32:384 + 8 * 32])) << 128)
                | uint256(bytes32(proof[384 + 8 * 32:384 + 9 * 32]))
        );
        bytes32 aggregateVkeyHash = bytes32(proof[384 + 9 * 32:384 + 10 * 32]);
        proofData.payee = address(uint160(uint256(bytes32(proof[384 + 10 * 32:384 + 11 * 32]))));

        address _axiomHeaderVerifierAddress = axiomHeaderVerifierAddress;

        // verify against on-chain data
        IAxiomV2HeaderVerifier(_axiomHeaderVerifierAddress).verifyQueryHeaders(blockhashMmrKeccak, mmrWitness);

        if (proofData.sourceChainId != IAxiomV2HeaderVerifier(_axiomHeaderVerifierAddress).getSourceChainId()) {
            revert SourceChainIdDoesNotMatch();
        }

        if (proofComputeResultsHash != computeResultsHash) {
            revert ComputeResultsHashDoesNotMatch();
        }

        if (
            !(
                hasRole(PROVER_ROLE, msg.sender) || hasRole(PROVER_ROLE, address(0))
                    || perQueryProvers[proofData.querySchema][target][msg.sender]
            )
        ) {
            revert ProverNotAuthorized();
        }

        if (
            !(
                aggregateVkeyHashes[aggregateVkeyHash]
                    || perQueryAggregateVkeyHashes[proofData.querySchema][target][aggregateVkeyHash]
            )
        ) {
            revert AggregateVkeyHashIsNotValid();
        }

        // verify the ZKP itself
        (bool success,) = verifierAddress.call(proof);
        if (!success) {
            revert ProofVerificationFailed();
        }
    }

    /// @notice Compute the price in ETH to escrow for each query.
    /// @param  maxFeePerGas The maxFeePerGas requested for the callback.
    /// @param  callbackGasLimit The gasLimit requested for the callback.
    /// @param  _axiomQueryFee The query fee for Axiom
    /// @return maxQueryPri The maximum amount of wei to escrow for the query.
    function _getMaxQueryPri(uint64 maxFeePerGas, uint32 callbackGasLimit, uint256 _axiomQueryFee)
        internal
        view
        returns (uint256 maxQueryPri)
    {
        maxQueryPri = maxFeePerGas * (callbackGasLimit + proofVerificationGas) + _axiomQueryFee;
    }

    /// @notice Record a deposit for fees to be paid by an account
    /// @param  payor The account receiving the deposit.
    /// @param  amount The amount of the deposit, in wei.
    function _recordDeposit(address payor, uint256 amount) internal {
        if (amount > MAX_DEPOSIT_SIZE) {
            revert DepositTooLarge();
        }

        unchecked {
            // balance cannot overflow
            balances[payor] += amount;
        }
        emit Deposit(payor, amount);
    }

    /// @notice Call a contract with no return value.
    /// @dev    Adapted from https://github.com/nomad-xyz/ExcessivelySafeCall/blob/main/src/ExcessivelySafeCall.sol
    ///         for the case that no return value is allowed.
    /// @param  _target The address of the contract to call.
    /// @param  _gas The gas to provide for the call.
    /// @param  _calldata The calldata to provide for the call.
    /// @return success True if the call succeeded, false otherwise.
    function _callWithNoReturn(address _target, uint256 _gas, bytes memory _calldata) internal returns (bool success) {
        assembly {
            success :=
                call(
                    _gas, // gas
                    _target, // recipient
                    0, // ether value
                    add(_calldata, 0x20), // inloc
                    mload(_calldata), // inlen
                    0, // outloc
                    0 // outlen
                )
        }
    }

    /// @inheritdoc AccessControlUpgradeable
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(IAxiomV2Query).interfaceId || super.supportsInterface(interfaceId);
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
