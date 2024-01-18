// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAxiomV2HeaderVerifier } from "./IAxiomV2HeaderVerifier.sol";

/// @dev States of an query.
///         We call a query on-chain if it is requested on-chain with `sendQuery` or `sendQueryWithIpfs`.
///         We also allow a query to be fulfilled on-chain without an on-chain request (which we call off-chain),
///         but to make sure the off-chain queries don't interfere with on-chain queries, we require that they are
///         in state `Inactive`.
/// @dev  Inactive The query has not been made or was refunded.
/// @dev  Active The query has been requested, but not fulfilled.
/// @dev  Fulfilled The query was successfully fulfilled.
/// @dev  Paid The query was successfully fulfilled and the payee has claimed the escrow amount.
uint8 constant AXIOM_QUERY_STATE_INACTIVE = 0;
uint8 constant AXIOM_QUERY_STATE_ACTIVE = 1;
uint8 constant AXIOM_QUERY_STATE_FULFILLED = 2;
uint8 constant AXIOM_QUERY_STATE_PAID = 3;

interface IAxiomV2Query {
    /// @notice Stores metadata about a query
    /// @param  state The state of the query.
    /// @param  deadlineBlockNumber The deadline (in block number) after which a refund may be granted.
    /// @param  callbackGasLimit The gasLimit the payee wishes the callback to be called with.
    /// @param  payee The address of the account that will receive payment.
    /// @param  payment The amount of the payment, in wei.
    struct AxiomQueryMetadata {
        uint8 state;
        uint32 deadlineBlockNumber;
        uint32 callbackGasLimit;
        address payee;
        uint256 payment;
    }

    /// @notice Stores data for initialization of AxiomV2Query
    /// @param  axiomHeaderVerifierAddress The address of the IAxiomV2HeaderVerifier.
    /// @param  verifierAddress The address of the ZK verifier for queries.
    /// @param  proverAddresses A list of allowed provers for all queries.
    /// @param  aggregateVkeyHashes A list of allowed aggregateVkeyHashes for query verification
    /// @param  queryDeadlineInterval The number of blocks after which a query may be refunded.
    /// @param  proofVerificationGas The amount of gas allotted for ZK proof verification.
    /// @param  axiomQueryFee The fee, in gwei, paid to Axiom for query fulfillment.
    /// @param  minMaxFeePerGas The minimum `maxFeePerGas` allowed in a query.
    /// @param  maxQueryDeadlineInterval The maximum `queryDeadlineInterval` allowed.
    /// @param  timelock The address of the timelock contract.
    /// @param  guardian The address of the guardian contract.
    /// @param  unfreeze The address of the unfreeze contract.
    struct AxiomV2QueryInit {
        address axiomHeaderVerifierAddress;
        address verifierAddress;
        address[] proverAddresses;
        bytes32[] aggregateVkeyHashes;
        uint32 queryDeadlineInterval;
        uint32 proofVerificationGas;
        uint256 axiomQueryFee;
        uint64 minMaxFeePerGas;
        uint32 maxQueryDeadlineInterval;
        address timelock;
        address guardian;
        address unfreeze;
    }

    /// @notice Stores witness data associated to a queryId.
    /// @param  caller The address of the account that initiated the query.
    /// @param  userSalt The salt used to generate the queryId.
    /// @param  queryHash Hash of the query data.
    /// @param  callbackHash Hash of the callback data.
    /// @param  refundee The address to send any refunds to.
    struct AxiomV2QueryWitness {
        address caller;
        bytes32 userSalt;
        bytes32 queryHash;
        bytes32 callbackHash;
        address refundee;
    }

    /// @notice Stores public instances of the query fulfillment proof
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  queryHash The unique hash identifier of the query.
    /// @param  querySchema The schema of the query, defined as `keccak(k . resultLen . vkeyLen . vkey)`
    /// @param  payee The address of the account that will receive payment.
    struct AxiomProofData {
        uint64 sourceChainId;
        bytes32 queryHash;
        bytes32 querySchema;
        address payee;
    }

    /// @notice Stores data associated to the compute query circuit.
    /// @param  k The degree of the circuit.
    /// @param  resultLen The number of meaningful public outputs of the circuit.  If no compute query
    ///         is defined, this is the number of data subqueries which should be passed to a callback.
    /// @param  vkey The verification key of the circuit.
    /// @param  computeProof The proof data of the circuit.
    struct AxiomV2ComputeQuery {
        uint8 k;
        uint16 resultLen;
        bytes32[] vkey;
        bytes computeProof;
    }

    /// @notice Stores data associated to the callback to be called after query fulfillment.
    ///         The callback will correspond to the function signature of `axiomV2Callback` or
    ///         `axiomV2OffchainCallback` in `IAxiomV2Client`.  It is not payable, and no ETH will
    ///         be forwarded.
    /// @param  target The address of the contract to call with the query results.
    /// @param  extraData Extra data to be passed to the callback function.
    struct AxiomV2Callback {
        address target;
        bytes extraData;
    }

    /// @notice Stores data associated to the fees to be paid for the query.
    /// @param  maxFeePerGas The maximum fee per gas the payee wishes the callback to be called with.
    /// @param  callbackGasLimit The gasLimit the payee wishes the callback to be called with.
    /// @param  overrideAxiomQueryFee If larger than `axiomQueryFee`, the value to be used for the query fee.
    struct AxiomV2FeeData {
        uint64 maxFeePerGas;
        uint32 callbackGasLimit;
        uint256 overrideAxiomQueryFee;
    }

    /// @dev Error returned if the AxiomV2HeaderVerifier address is 0.
    error AxiomHeaderVerifierAddressIsZero();

    /// @dev Error returned if the ZK proof verifier address is 0.
    error VerifierAddressIsZero();

    /// @dev Error returned if the AxiomV2Prover address is 0.
    error AxiomProverAddressIsZero();

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

    /// @dev Error returned if the payor address deposited to is 0
    error PayorAddressIsZero();

    /// @dev Error returned if the payee address withdrawn to is 0
    error PayeeAddressIsZero();

    /// @dev Error returned if deposit is 0
    error DepositAmountIsZero();

    /// @dev Error returned if withdrawal is 0
    error WithdrawalAmountIsZero();

    /// @dev Error returned if minMaxFeePerGas is 0
    error MinMaxFeePerGasIsZero();

    /// @dev Error returned if the query deadline interval is too large
    error QueryDeadlineIntervalIsTooLarge();

    /// @dev Error returned if the proofVerificationGas exceeds a conservative bound
    error ProofVerificationGasIsTooLarge();

    /// @dev Error returned if the axiomQueryFee exceeds a conservative bound
    error AxiomQueryFeeIsTooLarge();

    /// @dev Error returned if a deposit exceeds `MAX_DEPOSIT_SIZE`.
    error DepositTooLarge();

    /// @dev Error returned if an on-chain query is not in state `Active` upon fulfillment.
    error CannotFulfillIfNotActive();

    /// @dev Error returned if an off-chain query is not in state `Inactive` upon fulfillment.
    error CannotFulfillFromOffchainIfNotInactive();

    /// @dev Error returned if an on-chain query is attempted to be refunded by an address that is not the `refundee`.
    error CannotRefundIfNotRefundee();

    /// @dev Error returned if an on-chain query is not in state `Active` upon refund.
    error CannotRefundIfNotActive();

    /// @dev Error returned if a refund is requested for an on-chain query before `queryDeadlineInterval`.
    error CannotRefundBeforeDeadline();

    /// @dev Error returned if the `queryHash` does not match the value in the ZK proof.
    error QueryHashDoesNotMatchProof();

    /// @dev Error returned if ZK proof verification failed.
    error ProofVerificationFailed();

    /// @dev Error returned the compute results hash does not match.
    error ComputeResultsHashDoesNotMatch();

    /// @dev Error returned if the `sourceChainId` does not match.
    error SourceChainIdDoesNotMatch();

    /// @dev Error returned if the `aggregateVkeyHash` in the proof is not allowed.
    error AggregateVkeyHashIsNotValid();

    /// @dev Error returned if the new `maxQueryPri` is not larger.
    error NewMaxQueryPriMustBeLargerThanPrevious();

    /// @dev Error returned if the query requestor does not have sufficient funds.
    error InsufficientFunds();

    /// @dev Error returned if there is insufficient gas for the requested callback gas limit
    ///      when fulfilling an on-chain query.
    error InsufficientGasForCallback();

    /// @dev Error returned if `callbackHash` does not match the `queryWitness`
    error CallbackHashDoesNotMatchQueryWitness();

    /// @dev Error returned if a requested escrow amount exceeds a user balance.
    error EscrowAmountExceedsBalance();

    /// @dev Error returned if a gas increase is requested on a query which is not active.
    error CanOnlyIncreaseGasOnActiveQuery();

    /// @dev Error returned if a query is not in state `Fulfilled`.
    error QueryIsNotFulfilled();

    /// @dev Error returned if a query is not in state `Inactive`.
    error QueryIsNotInactive();

    /// @dev Error returned if the requested unescrow amount exceeds the escrow.
    error UnescrowAmountExceedsEscrowedAmount();

    /// @dev Error returned if the unescrow request is not from the payee.
    error OnlyPayeeCanUnescrow();

    /// @dev Error returned if caller of an offchain fulfillment is not the payee.
    error OnlyPayeeCanFulfillOffchainQuery();

    /// @dev Error returned if the withdrawal amount exceeds a user's balance.
    error WithdrawalAmountExceedsFreeBalance();

    /// @dev Error returned if the `maxFeePerGas` is too low.
    error MaxFeePerGasIsTooLow();

    /// @notice Emitted when the `IAxiomV2HeaderVerifier` address is updated.
    /// @param  newAddress The updated address.
    event UpdateAxiomHeaderVerifierAddress(address newAddress);

    /// @notice Emitted when the query verifier address is updated.
    /// @param  newAddress The updated address.
    event UpdateVerifierAddress(address newAddress);

    /// @notice Emitted when the prover address is updated.
    /// @param  newAddress The updated address.
    event UpdateAxiomProverAddress(address newAddress);

    /// @notice Emitted when an aggregateVkeyHash is added for a given query schema and callback
    /// @param  querySchema The query schema
    /// @param  target The callback address
    /// @param  aggregateVkeyHash The aggregateVkeyHash
    event AddPerQueryAggregateVkeyHash(bytes32 indexed querySchema, address target, bytes32 aggregateVkeyHash);

    /// @notice Emitted when an aggregateVkeyHash is removed for a given query schema and callback
    /// @param  querySchema The query schema
    /// @param  target The callback address
    /// @param  aggregateVkeyHash The aggregateVkeyHash
    event RemovePerQueryAggregateVkeyHash(bytes32 indexed querySchema, address target, bytes32 aggregateVkeyHash);

    /// @notice Emitted when a new aggregateVkeyHash is added which applies to all queries
    /// @param  aggregateVkeyHash The `aggregateVkeyHash` which was added.
    event AddAggregateVkeyHash(bytes32 indexed aggregateVkeyHash);

    /// @notice Emitted when an aggregateVkeyHash is removed which applies to all queries
    /// @param  aggregateVkeyHash The `aggregateVkeyHash` which was removed.
    event RemoveAggregateVkeyHash(bytes32 indexed aggregateVkeyHash);

    /// @notice Emitted when the query deadline interval is updated
    /// @param  newQueryDeadlineInterval The updated query deadline interval.
    event UpdateQueryDeadlineInterval(uint32 newQueryDeadlineInterval);

    /// @notice Emitted when the proof gas is updated
    /// @param  newProofVerificationGas The updated proof gas.
    event UpdateProofVerificationGas(uint32 newProofVerificationGas);

    /// @notice Emitted when the query fee is updated
    /// @param  newAxiomQueryFee The updated query fee.
    event UpdateAxiomQueryFee(uint256 newAxiomQueryFee);

    /// @notice Emitted when the mininum value of maxFeePerGas is updated
    /// @param  newMinMaxFeePerGas The updated maxFeePerGas.
    event UpdateMinMaxFeePerGas(uint64 newMinMaxFeePerGas);

    /// @notice Emitted when a query is initiated on-chain.
    /// @param  caller The address of the account that initiated the query.
    /// @param  queryHash The unique hash identifying the query.
    /// @param  queryId The unique ID identifying the query.
    /// @param  userSalt The salt used to generate the query hash.
    /// @param  refundee The address to send any refunds to.
    /// @param  target The address of the contract to call with the query results.
    /// @param  extraData Extra data to be passed to the callback function.
    event QueryInitiatedOnchain(
        address indexed caller,
        bytes32 indexed queryHash,
        uint256 indexed queryId,
        bytes32 userSalt,
        address refundee,
        address target,
        bytes extraData
    );

    /// @notice Emitted when a query is initiated with data availability on IPFS.
    /// @param  caller The address of the account that initiated the query.
    /// @param  queryHash The unique hash identifying the query.
    /// @param  queryId The unique ID identifying the query.
    /// @param  userSalt The salt used to generate the query hash.
    /// @param  ipfsHash The IPFS hash with the query.
    /// @param  refundee The address to send any refunds to.
    /// @param  target The address of the contract to call with the query results.
    /// @param  extraData Extra data to be passed to the callback function.
    event QueryInitiatedWithIpfsData(
        address indexed caller,
        bytes32 indexed queryHash,
        uint256 indexed queryId,
        bytes32 userSalt,
        bytes32 ipfsHash,
        address refundee,
        address target,
        bytes extraData
    );

    /// @notice Emitted when a query is initiated.
    /// @param  queryId The unique ID identifying the query.
    /// @param  payor The account paying for the query.
    /// @param  deadlineBlockNumber The deadline (in block number) after which a refund may be granted.
    /// @param  maxFeePerGas The maximum fee per gas the payee wishes the callback to be called with.
    /// @param  callbackGasLimit The gasLimit the payee wishes the callback to be called with.
    /// @param  amount The amount of the payment, in wei.
    event QueryFeeInfoRecorded(
        uint256 indexed queryId,
        address indexed payor,
        uint32 deadlineBlockNumber,
        uint64 maxFeePerGas,
        uint32 callbackGasLimit,
        uint256 amount
    );

    /// @notice Emitted when the gas allowance for a query is increased.
    /// @param  queryId The unique ID of the query.
    /// @param  maxFeePerGas The maximum fee per gas the payee wishes the callback to be called with.
    /// @param  callbackGasLimit The gasLimit the payee wishes the callback to be called with.
    /// @param  overrideAxiomQueryFee If larger than `axiomQueryFee`, the value to be used for the query fee.
    event QueryGasIncreased(
        uint256 indexed queryId, uint64 maxFeePerGas, uint32 callbackGasLimit, uint256 overrideAxiomQueryFee
    );

    /// @notice Emitted when a query requested on-chain is fulfilled.
    /// @param  queryId The unique ID identifying the query.
    /// @param  payee The address of the account that will receive payment.
    /// @param  callbackSucceeded Whether the callback succeeded.  This will be `false` if no callback was requested.
    event QueryFulfilled(uint256 indexed queryId, address payee, bool callbackSucceeded);

    /// @notice Emitted when a query requested off-chain is fulfilled.
    /// @param  queryId The unique ID identifying the query.
    /// @param  callbackSucceeded Whether the callback succeeded.  This will be `false` if no callback was requested.
    event OffchainQueryFulfilled(uint256 indexed queryId, bool callbackSucceeded);

    /// @notice Emitted when a query is refunded.
    /// @param  queryId The unique ID identifying the query.
    /// @param  refundee The address the refund is sent to.
    event QueryRefunded(uint256 indexed queryId, address indexed refundee);

    /// @notice Emitted when a deposit is made for fees to be paid by an account
    /// @param  payor The account receiving the deposit.
    /// @param  amount The amount of the deposit, in wei.
    event Deposit(address indexed payor, uint256 amount);

    /// @notice Emitted when payment is claimed by the payee
    /// @param  payor The account paying for the query.
    /// @param  queryId The unique ID identifying the query.
    /// @param  payee The account receiving payment.
    /// @param  refundee The account receiving a partial refund.
    /// @param  amountUsed The amount of the escrow used, in wei.
    event Unescrow(
        address indexed payor, uint256 indexed queryId, address indexed payee, address refundee, uint256 amountUsed
    );

    /// @notice Emitted when a withdrawal is made of unused funds.
    /// @param  payor The account to withdraw from.
    /// @param  amount The amount of the withdrawal, in wei.
    /// @param  payee The address receiving the withdrawal.
    event Withdraw(address indexed payor, uint256 amount, address payee);

    /// @notice Emitted when a prover is added for a given query schema and callback
    /// @param  querySchema The query schema
    /// @param  target The callback address
    /// @param  prover The prover address
    event AddPerQueryProver(bytes32 indexed querySchema, address target, address prover);

    /// @notice Emitted when a prover is removed for a given query schema and callback
    /// @param  querySchema The query schema
    /// @param  target The callback address
    /// @param  prover The prover address
    event RemovePerQueryProver(bytes32 indexed querySchema, address target, address prover);

    /// @notice Send a query to Axiom. See `AxiomV2ComputeQuery` for documentation on the compute query and
    ///         `AxiomV2Callback` for documentation on the callback format.
    /// @param  sourceChainId The ID of the chain the query reads from.
    /// @param  dataQueryHash The hash of the data query.
    /// @param  computeQuery The data associated to the compute query circuit.
    /// @param  callback The data associated to the callback to be called after query fulfillment.
    /// @param  feeData The data associated to the fees to be paid for the query.
    /// @param  userSalt The salt used to generate the queryId.
    /// @param  refundee The address to send any refunds to.
    /// @param  dataQuery The raw data query.
    /// @return queryId The unique ID identifying the query.
    function sendQuery(
        uint64 sourceChainId,
        bytes32 dataQueryHash,
        AxiomV2ComputeQuery calldata computeQuery,
        AxiomV2Callback calldata callback,
        AxiomV2FeeData calldata feeData,
        bytes32 userSalt,
        address refundee,
        bytes calldata dataQuery
    ) external payable returns (uint256 queryId);

    /// @notice Send a query to Axiom with data availability on IPFS. See `AxiomV2ComputeQuery` for documentation
    ///         on the compute query and `AxiomV2Callback` for documentation on the callback format.
    /// @param  queryHash The unique hash identifying the query.
    /// @param  ipfsHash The IPFS hash with the query.
    /// @param  callback The data associated to the callback to be called after query fulfillment.
    /// @param  feeData The data associated to the fees to be paid for the query.
    /// @param  userSalt The salt used to generate the queryId.
    /// @param  refundee The address to send any refunds to.
    /// @return queryId The unique ID identifying the query.
    function sendQueryWithIpfsData(
        bytes32 queryHash,
        bytes32 ipfsHash,
        AxiomV2Callback calldata callback,
        AxiomV2FeeData calldata feeData,
        bytes32 userSalt,
        address refundee
    ) external payable returns (uint256 queryId);

    /// @notice Increase the fees allocated for a query while paying additional fees. Anyone can call this.
    ///         Excess funds are allocated to the account of the sender.
    /// @param  queryId The unique ID identifying the query.
    /// @param  newMaxFeePerGas The new maximum fee per gas the payee wishes the callback to be called with.
    /// @param  newCallbackGasLimit The new gasLimit the payee wishes the callback to be called with.
    /// @param  overrideAxiomQueryFee If larger than `axiomQueryFee`, the value to be used for the query fee.
    function increaseQueryGas(
        uint256 queryId,
        uint64 newMaxFeePerGas,
        uint32 newCallbackGasLimit,
        uint256 overrideAxiomQueryFee
    ) external payable;

    /// @notice Fulfill an Axiom query made on-chain.
    /// @param  mmrWitness Witness data allowing verification of the proof against the MMR of block
    ///         hashes in AxiomV2Core.
    /// @param  computeResults The query results to be passed to the callback.
    /// @param  proof The ZK proof data.
    /// @param  callback Callback to be called after.
    /// @param  queryWitness Witness data identifying the query.
    function fulfillQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        AxiomV2Callback calldata callback,
        AxiomV2QueryWitness calldata queryWitness
    ) external;

    /// @notice Fulfill an Axiom query made off-chain. See `AxiomV2Callback` for documentation on the callback format.
    /// @param  mmrWitness Witness data allowing verification of the proof against the MMR of block
    ///         hashes in AxiomV2Core.
    /// @param  computeResults The query results to be passed to the callback.
    /// @param  proof The ZK proof data.
    /// @param  callback The callback to be called with the query results.
    /// @param  userSalt The salt used to generate the queryId
    function fulfillOffchainQuery(
        IAxiomV2HeaderVerifier.MmrWitness calldata mmrWitness,
        bytes32[] calldata computeResults,
        bytes calldata proof,
        AxiomV2Callback calldata callback,
        bytes32 userSalt
    ) external;

    /// @notice Refund a query.
    /// @param  queryWitness Witness data identifying the query.
    function refundQuery(AxiomV2QueryWitness calldata queryWitness) external;

    /// @notice Deposit funds to be used for query fees
    /// @param  payor The account receiving the deposit.
    function deposit(address payor) external payable;

    /// @notice Claim payment for a query
    /// @param  queryWitness Witness data identifying the query.
    /// @param  amountUsed The amount of the escrow used, in wei.
    function unescrow(AxiomV2QueryWitness calldata queryWitness, uint256 amountUsed) external;

    /// @notice Withdraw unused funds.
    /// @param  amount The amount of the withdrawal, in wei.
    /// @param  payee The address receiving the withdrawal.
    function withdraw(uint256 amount, address payable payee) external;
}
