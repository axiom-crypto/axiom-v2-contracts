// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { IAxiomV2Client } from "../../contracts/interfaces/client/IAxiomV2Client.sol";
import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";
import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { AxiomV2Query } from "../../contracts/query/AxiomV2Query.sol";
import {
    MAINNET_CHAIN_ID,
    MAX_DEPOSIT_SIZE,
    MAX_PROOF_VERIFICATION_GAS
} from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";
import {
    AxiomTestBase,
    AxiomTestSendInputs,
    AxiomTestMetadata,
    AxiomTestFulfillInputs,
    PayeeAddressIsZero,
    PayorAddressIsZero,
    QueryDeadlineIntervalIsTooLarge,
    ProofVerificationGasIsTooLarge,
    AxiomQueryFeeIsTooLarge,
    InsufficientGasForCallback,
    DepositAmountIsZero,
    WithdrawalAmountIsZero,
    MaxFeePerGasIsTooLow,
    MinMaxFeePerGasIsZero,
    OnlyPayeeCanFulfillOffchainQuery
} from "../base/AxiomTestBase.sol";

error ContractIsFrozen();

error AxiomHeaderVerifierAddressIsZero();
error VerifierAddressIsZero();
error ProverAddressIsZero();
error TimelockAddressIsZero();
error GuardianAddressIsZero();
error UnfreezeAddressIsZero();
error DepositTooLarge();
error CannotFulfillIfNotActive();
error CannotFulfillFromOffchainIfNotInactive();
error CannotRefundIfNotRefundee();
error CannotRefundIfNotActive();
error CannotRefundBeforeDeadline();
error QueryHashDoesNotMatchProof();
error ProofVerificationFailed();
error ComputeResultsHashDoesNotMatch();
error CallbackExtraDataHashDoesNotMatch();
error SourceChainIdDoesNotMatch();
error AggregateVkeyHashIsNotValid();
error NewMaxQueryPriMustBeLargerThanPrevious();
error InsufficientFunds();
error CallbackHashDoesNotMatchQueryWitness();
error EscrowIsNotActive();
error EscrowAmountExceedsBalance();
error OnlyCallerCanIncreaseGas();
error CanOnlyIncreaseGasOnActiveQuery();
error QueryIsNotFulfilled();
error QueryIsNotInactive();
error QueryIsNotActive();
error UnescrowAmountExceedsEscrowedAmount();
error OnlyPayeeCanUnescrow();
error WithdrawalAmountExceedsFreeBalance();
error ProverNotAuthorized();

contract AxiomV2QueryTest is AxiomTestBase {
    event FreezeAll();
    event UnfreezeAll();

    event UpdateAxiomHeaderVerifierAddress(address newAddress);
    event UpdateVerifierAddress(address newAddress);
    event UpdateAxiomProverAddress(address newAddress);
    event AddAggregateVkeyHash(bytes32 indexed newAggregateVkeyHash);
    event RemoveAggregateVkeyHash(bytes32 indexed aggregateVkeyHash);
    event UpdateQueryDeadlineInterval(uint32 newQueryDeadlineInterval);
    event UpdateProofVerificationGas(uint32 newProofVerificationGas);
    event UpdateAxiomQueryFee(uint256 newAxiomQueryFee);
    event UpdateMinMaxFeePerGas(uint64 newMinMaxFeePerGas);
    event AddPerQueryProver(bytes32 indexed querySchema, address target, address prover);
    event RemovePerQueryProver(bytes32 indexed querySchema, address target, address prover);
    event AddPerQueryAggregateVkeyHash(bytes32 indexed querySchema, address target, bytes32 aggregateVkeyHash);
    event RemovePerQueryAggregateVkeyHash(bytes32 indexed querySchema, address target, bytes32 aggregateVkeyHash);

    event QueryInitiatedOnchain(
        address indexed caller,
        bytes32 indexed queryHash,
        uint256 indexed queryId,
        bytes32 userSalt,
        address refundee,
        address target,
        bytes extraData
    );
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
    event QueryFeeInfoRecorded(
        uint256 indexed queryId,
        address indexed payor,
        uint32 deadlineBlockNumber,
        uint64 maxFeePerGas,
        uint32 callbackGasLimit,
        uint256 amount
    );
    event QueryFulfilled(uint256 indexed queryId, address payee, bool callbackSucceeded);
    event OffchainQueryFulfilled(uint256 indexed queryId, bool callbackSucceeded);
    event QueryRefunded(uint256 indexed queryId, address indexed refundee);
    event QueryGasIncreased(
        uint256 indexed queryId, uint64 maxFeePerGas, uint32 callbackGasLimit, uint256 overrideAxiomQueryFee
    );

    event Deposit(address indexed payor, uint256 amount);
    event Escrow(address indexed payor, uint256 indexed queryId, uint256 amount);
    event IncreaseEscrow(address indexed payor, uint256 indexed queryId, uint256 amount);
    event Unescrow(
        address indexed payor, uint256 indexed queryId, address indexed payee, address refundee, uint256 amountUsed
    );
    event Withdraw(address indexed payor, uint256 amount, address payee);

    AxiomTestSendInputs public sendInputs;
    AxiomTestMetadata public metadata;
    AxiomTestFulfillInputs public fulfillInputs;
    uint32 public forkBlockNumber;
    uint64 public sourceChainId;

    function setUp() public { }

    function assignFromFile(
        string memory filename,
        bool isIpfs,
        bool isEmptyComputeQuery,
        bool isEmptyCallback,
        bool isOffchainFulfill
    ) public {
        (
            AxiomTestSendInputs memory _sendInputs,
            AxiomTestMetadata memory _metadata,
            AxiomTestFulfillInputs memory _fulfillInputs,
            uint32 _forkBlockNumber,
            uint64 _sourceChainId
        ) = _readFromFile(filename, isIpfs, isEmptyComputeQuery, isEmptyCallback, isOffchainFulfill);

        sendInputs = _sendInputs;
        metadata = _metadata;
        fulfillInputs = _fulfillInputs;
        forkBlockNumber = _forkBlockNumber;
        sourceChainId = _sourceChainId;
    }

    function test_init() public {
        deploy(uint64(sourceChainId));
    }

    function test_init_zeroAxiomHeaderVerifierAddress_fail() public {
        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(0),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(AxiomHeaderVerifierAddressIsZero.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_zeroVerifierAddress_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(0),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(VerifierAddressIsZero.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_zeroAxiomProverAddress_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = address(0);
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(ProverAddressIsZero.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_zeroTimelockAddress_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: address(0),
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(TimelockAddressIsZero.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_zeroGuardianAddress_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: address(0),
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(GuardianAddressIsZero.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_zeroUnfreezeAddress_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: address(0)
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(UnfreezeAddressIsZero.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_queryDeadlineIntervalTooLarge_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: 50_401,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(QueryDeadlineIntervalIsTooLarge.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_proofVerificationGasTooLarge_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: 600_001,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(ProofVerificationGasIsTooLarge.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_axiomQueryFeeTooLarge_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: 0.05 ether + 1,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(AxiomQueryFeeIsTooLarge.selector);
        new AxiomProxy(address(impl), data);
    }

    function test_init_minMaxFeePerGasIsZero_fail() public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();

        address[] memory proverAddresses = new address[](1);
        proverAddresses[0] = prover;
        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            proverAddresses: proverAddresses,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            minMaxFeePerGas: 0,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        vm.expectRevert(MinMaxFeePerGasIsZero.selector);
        new AxiomProxy(address(impl), data);
    }

    function sendQuery() public returns (uint256 queryId) {
        uint256 _axiomQueryFee = axiomQueryFee;
        if (sendInputs.feeData.overrideAxiomQueryFee > axiomQueryFee) {
            _axiomQueryFee = sendInputs.feeData.overrideAxiomQueryFee;
        }

        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectEmit();
        emit QueryFeeInfoRecorded(
            metadata.queryId,
            caller,
            uint32(block.number) + queryDeadlineInterval,
            sendInputs.feeData.maxFeePerGas,
            sendInputs.feeData.callbackGasLimit,
            sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                + _axiomQueryFee
        );
        vm.expectEmit();
        emit QueryInitiatedOnchain(
            caller,
            metadata.queryHash,
            metadata.queryId,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.callback.target,
            sendInputs.callback.extraData
        );
        queryId = axiomQuery.sendQuery{ value: 0.1 ether }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
        assertEq(
            axiomQuery.balances(caller),
            0.1 ether
                - sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                - _axiomQueryFee
        );
    }

    function sendQueryWithIpfsData() public returns (uint256 queryId) {
        uint256 _axiomQueryFee = axiomQueryFee;
        if (sendInputs.feeData.overrideAxiomQueryFee > axiomQueryFee) {
            _axiomQueryFee = sendInputs.feeData.overrideAxiomQueryFee;
        }

        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectEmit();
        emit QueryFeeInfoRecorded(
            metadata.queryId,
            caller,
            uint32(block.number) + queryDeadlineInterval,
            sendInputs.feeData.maxFeePerGas,
            sendInputs.feeData.callbackGasLimit,
            sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                + _axiomQueryFee
        );
        vm.expectEmit();
        emit QueryInitiatedWithIpfsData(
            caller,
            metadata.queryHash,
            metadata.queryId,
            sendInputs.userSalt,
            bytes32(0x0),
            sendInputs.refund,
            sendInputs.callback.target,
            sendInputs.callback.extraData
        );
        queryId = axiomQuery.sendQueryWithIpfsData{ value: 0.1 ether }(
            metadata.queryHash,
            bytes32(0x0),
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund
        );
        assertEq(
            axiomQuery.balances(caller),
            0.1 ether
                - sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                - _axiomQueryFee
        );
    }

    function sendQueryWithIpfsDataZeroRefundee() public returns (uint256 queryId) {
        uint256 _axiomQueryFee = axiomQueryFee;
        if (sendInputs.feeData.overrideAxiomQueryFee > axiomQueryFee) {
            _axiomQueryFee = sendInputs.feeData.overrideAxiomQueryFee;
        }

        uint256 queryIdAnswer = uint256(
            keccak256(
                abi.encodePacked(
                    uint64(block.chainid),
                    caller,
                    sendInputs.userSalt,
                    metadata.queryHash,
                    keccak256(abi.encodePacked(sendInputs.callback.target, sendInputs.callback.extraData)),
                    caller
                )
            )
        );
        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectEmit();
        emit QueryFeeInfoRecorded(
            queryIdAnswer,
            caller,
            uint32(block.number) + queryDeadlineInterval,
            sendInputs.feeData.maxFeePerGas,
            sendInputs.feeData.callbackGasLimit,
            sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                + _axiomQueryFee
        );
        vm.expectEmit();
        emit QueryInitiatedWithIpfsData(
            caller,
            metadata.queryHash,
            queryIdAnswer,
            sendInputs.userSalt,
            bytes32(0x0),
            caller,
            sendInputs.callback.target,
            sendInputs.callback.extraData
        );
        queryId = axiomQuery.sendQueryWithIpfsData{ value: 0.1 ether }(
            metadata.queryHash, bytes32(0x0), sendInputs.callback, sendInputs.feeData, sendInputs.userSalt, address(0)
        );
        assertEq(
            axiomQuery.balances(caller),
            0.1 ether
                - sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                - _axiomQueryFee
        );
    }

    function sendQueryNoDeposit() public returns (uint256 queryId) {
        uint256 _axiomQueryFee = axiomQueryFee;
        if (sendInputs.feeData.overrideAxiomQueryFee > axiomQueryFee) {
            _axiomQueryFee = sendInputs.feeData.overrideAxiomQueryFee;
        }

        vm.deal(caller, 1 ether);
        axiomQuery.deposit{ value: 0.2 ether }(caller);

        vm.prank(caller);
        vm.expectEmit();
        emit QueryFeeInfoRecorded(
            metadata.queryId,
            caller,
            uint32(block.number) + queryDeadlineInterval,
            sendInputs.feeData.maxFeePerGas,
            sendInputs.feeData.callbackGasLimit,
            sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                + _axiomQueryFee
        );
        vm.expectEmit();
        emit QueryInitiatedOnchain(
            caller,
            metadata.queryHash,
            metadata.queryId,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.callback.target,
            sendInputs.callback.extraData
        );
        queryId = axiomQuery.sendQuery(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
        assertEq(
            axiomQuery.balances(caller),
            0.2 ether
                - sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                - _axiomQueryFee
        );
    }

    function sendQueryZeroRefundee() public returns (uint256 queryId) {
        uint256 _axiomQueryFee = axiomQueryFee;
        if (sendInputs.feeData.overrideAxiomQueryFee > axiomQueryFee) {
            _axiomQueryFee = sendInputs.feeData.overrideAxiomQueryFee;
        }

        uint256 queryIdAnswer = uint256(
            keccak256(
                abi.encodePacked(
                    uint64(block.chainid),
                    caller,
                    sendInputs.userSalt,
                    metadata.queryHash,
                    keccak256(abi.encodePacked(sendInputs.callback.target, sendInputs.callback.extraData)),
                    caller
                )
            )
        );
        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectEmit();
        emit QueryFeeInfoRecorded(
            queryIdAnswer,
            caller,
            uint32(block.number) + queryDeadlineInterval,
            sendInputs.feeData.maxFeePerGas,
            sendInputs.feeData.callbackGasLimit,
            sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                + _axiomQueryFee
        );
        vm.expectEmit();
        emit QueryInitiatedOnchain(
            caller,
            metadata.queryHash,
            queryIdAnswer,
            sendInputs.userSalt,
            caller,
            sendInputs.callback.target,
            sendInputs.callback.extraData
        );
        queryId = axiomQuery.sendQuery{ value: 0.1 ether }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            address(0),
            sendInputs.dataQuery
        );
        assertEq(
            axiomQuery.balances(caller),
            0.1 ether
                - sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                - _axiomQueryFee
        );
    }

    function test_sendQuery() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        sendQuery();
    }

    function test_sendQueryWithIpfsData() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, true, false, false, false);
        sendQueryWithIpfsData();
    }

    function test_sendQueryZeroRefundee() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        sendQueryZeroRefundee();
    }

    function test_sendQueryWithIpfsDataZeroRefundee() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, true, false, false, false);
        sendQueryWithIpfsDataZeroRefundee();
    }

    function test_sendQueryNoDeposit() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        sendQueryNoDeposit();
    }

    function test_fulfillQuery() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        sendQuery();

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        vm.expectCall(
            address(client),
            0,
            sendInputs.feeData.callbackGasLimit,
            abi.encodeWithSelector(
                IAxiomV2Client.axiomV2Callback.selector,
                sourceChainId,
                caller,
                metadata.querySchema,
                metadata.queryId,
                fulfillInputs.computeResults,
                sendInputs.callback.extraData
            )
        );
        vm.expectEmit();
        emit QueryFulfilled(metadata.queryId, fulfillInputs.payee, true);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_gasLeft_pass() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        sendQuery();

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        vm.expectCall(
            address(client),
            0,
            sendInputs.feeData.callbackGasLimit,
            abi.encodeWithSelector(
                IAxiomV2Client.axiomV2Callback.selector,
                sourceChainId,
                caller,
                metadata.querySchema,
                metadata.queryId,
                fulfillInputs.computeResults,
                sendInputs.callback.extraData
            )
        );
        vm.expectEmit();
        emit QueryFulfilled(metadata.queryId, fulfillInputs.payee, true);
        axiomQuery.fulfillQuery{ gas: 605_000 }(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_gasLeft_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        sendQuery();

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        vm.expectRevert(InsufficientGasForCallback.selector);
        axiomQuery.fulfillQuery{ gas: 505_000 }(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_no_permissions() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        sendQuery();

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(query);
        vm.expectRevert(ProverNotAuthorized.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        sendQuery();
        fulfillInputs.proof[200] = bytes1(0xaa);

        vm.prank(prover);
        vm.expectRevert(ProofVerificationFailed.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_queryHash_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        sendQuery();
        metadata.queryWitness.queryHash = bytes32(0x0);

        vm.prank(prover);
        vm.expectRevert(QueryHashDoesNotMatchProof.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_sendQueryNoCallback() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, true, false);

        sendQuery();
    }

    function test_fulfillQueryNoCallback() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, true, false);

        sendQuery();

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        vm.expectEmit();
        emit QueryFulfilled(metadata.queryId, fulfillInputs.payee, false);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_sendDataQuery() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, true, false, false);

        metadata.queryId = uint256(
            keccak256(
                abi.encodePacked(
                    uint64(block.chainid),
                    address(caller),
                    sendInputs.userSalt,
                    metadata.queryHash,
                    metadata.callbackHash,
                    refund
                )
            )
        );

        sendQuery();
    }

    function test_fulfillDataQuery() public {
        test_sendDataQuery();
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        vm.expectEmit();
        emit QueryFulfilled(metadata.queryId, fulfillInputs.payee, true);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.dataOnlyProof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_sendQuery_overrideFee() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        sendInputs.feeData.overrideAxiomQueryFee = 0.005 ether;
        uint256 _axiomQueryFee = 0.005 ether;

        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectEmit();
        emit QueryFeeInfoRecorded(
            metadata.queryId,
            caller,
            uint32(block.number) + queryDeadlineInterval,
            sendInputs.feeData.maxFeePerGas,
            sendInputs.feeData.callbackGasLimit,
            sendInputs.feeData.maxFeePerGas * uint256(sendInputs.feeData.callbackGasLimit + proofVerificationGas)
                + _axiomQueryFee
        );
        vm.expectEmit();
        emit QueryInitiatedOnchain(
            caller,
            metadata.queryHash,
            metadata.queryId,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.callback.target,
            sendInputs.callback.extraData
        );
        axiomQuery.sendQuery{ value: 0.03 ether }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );

        vm.deal(caller, 200 ether);
        sendInputs.userSalt = 0x0;
        sendInputs.feeData.overrideAxiomQueryFee = MAX_DEPOSIT_SIZE + 1 ether;

        uint256 value = MAX_DEPOSIT_SIZE + 1 ether
            + sendInputs.feeData.maxFeePerGas * (sendInputs.feeData.callbackGasLimit + MAX_PROOF_VERIFICATION_GAS);
        vm.prank(caller);
        vm.expectRevert(DepositTooLarge.selector);
        axiomQuery.sendQuery{ value: value }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );

        value = MAX_DEPOSIT_SIZE + 1 ether
            + sendInputs.feeData.maxFeePerGas * (sendInputs.feeData.callbackGasLimit + proofVerificationGas);
        vm.prank(caller);
        vm.expectRevert(DepositTooLarge.selector);
        axiomQuery.sendQuery{ value: value }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_sendQuery_minMaxFeePerGasTooLow_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        sendInputs.feeData.maxFeePerGas = 5 gwei - 1;

        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectRevert(MaxFeePerGasIsTooLow.selector);
        axiomQuery.sendQuery{ value: 0.001 ether }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_sendQuery_notInactive_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        sendQuery();

        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectRevert(QueryIsNotInactive.selector);
        axiomQuery.sendQuery{ value: 0.1 ether }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_sendQuery_insufficientFunds_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectRevert(EscrowAmountExceedsBalance.selector);
        axiomQuery.sendQuery{ value: 0.001 ether }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_sendQuery_wrongSourceChainId_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        vm.deal(caller, 1 ether);
        vm.prank(caller);
        vm.expectRevert(SourceChainIdDoesNotMatch.selector);
        axiomQuery.sendQuery{ value: 0.02 ether }(
            MAINNET_CHAIN_ID,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_fulfillQuery_notActive() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.deal(prover, 1 ether);
        vm.prank(prover);
        vm.expectRevert(CannotFulfillIfNotActive.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_computeResultsMismatch() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        uint256 queryId = sendQuery();

        fulfillInputs.computeResults[2] = bytes32(0x0);
        vm.deal(prover, 1 ether);
        vm.prank(prover);
        vm.expectRevert(ComputeResultsHashDoesNotMatch.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_callbackMismatch() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        uint256 queryId = sendQuery();

        sendInputs.callback.extraData = hex"aa";
        vm.deal(prover, 1 ether);
        vm.prank(prover);
        vm.expectRevert(CallbackHashDoesNotMatchQueryWitness.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_sourceChainIdMismatch() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        uint256 queryId = sendQuery();

        fulfillInputs.proof[384 + 31] = bytes1(0xaa);
        vm.deal(prover, 1 ether);
        vm.prank(prover);
        vm.expectRevert(SourceChainIdDoesNotMatch.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillQuery_aggregateVkeyHashMismatch() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        uint256 queryId = sendQuery();

        bytes32 aggregateVkeyHash = aggregateVkeyHashes[0];
        vm.prank(timelock);
        vm.expectEmit();
        emit RemoveAggregateVkeyHash(aggregateVkeyHash);
        axiomQuery.removeAggregateVkeyHash(aggregateVkeyHashes[0]);

        vm.deal(prover, 1 ether);
        vm.prank(prover);
        vm.expectRevert(AggregateVkeyHashIsNotValid.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );

        vm.prank(timelock);
        vm.expectEmit();
        emit AddPerQueryAggregateVkeyHash(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash);
        axiomQuery.addPerQueryAggregateVkeyHash(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash);
        assertTrue(
            axiomQuery.perQueryAggregateVkeyHashes(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash)
        );

        vm.prank(timelock);
        vm.expectEmit();
        emit RemovePerQueryAggregateVkeyHash(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash);
        axiomQuery.removePerQueryAggregateVkeyHash(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash);
        assertFalse(
            axiomQuery.perQueryAggregateVkeyHashes(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash)
        );
        vm.prank(prover);
        vm.expectRevert(AggregateVkeyHashIsNotValid.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );

        vm.prank(timelock);
        vm.expectEmit();
        emit AddPerQueryAggregateVkeyHash(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash);
        axiomQuery.addPerQueryAggregateVkeyHash(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash);
        assertTrue(
            axiomQuery.perQueryAggregateVkeyHashes(metadata.querySchema, sendInputs.callback.target, aggregateVkeyHash)
        );

        vm.prank(prover);
        vm.expectEmit();
        emit QueryFulfilled(metadata.queryId, fulfillInputs.payee, true);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillOffchainQuery() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, true);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(timelock);
        axiomQuery.grantRole(keccak256("PROVER_ROLE"), fulfillInputs.payee);

        vm.prank(fulfillInputs.payee);
        vm.expectEmit();
        emit OffchainQueryFulfilled(metadata.queryId, true);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );

        vm.prank(fulfillInputs.payee);
        vm.expectRevert(CannotFulfillFromOffchainIfNotInactive.selector);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );

        vm.prank(query);
        vm.expectRevert(ProverNotAuthorized.selector);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );

        vm.prank(timelock);
        axiomQuery.addPerQueryProver(metadata.querySchema, sendInputs.callback.target, query);

        vm.prank(query);
        vm.expectRevert(OnlyPayeeCanFulfillOffchainQuery.selector);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );
    }

    function test_fulfillOffchainQueryNoCallback() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, true, true);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(timelock);
        axiomQuery.grantRole(keccak256("PROVER_ROLE"), fulfillInputs.payee);

        vm.prank(fulfillInputs.payee);
        vm.expectEmit();
        emit OffchainQueryFulfilled(metadata.queryId, false);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );
    }

    function test_fulfillOffchainQuery_freeze() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, true);

        vm.prank(guardian);
        axiomQuery.freezeAll();

        vm.prank(prover);
        vm.expectRevert(ContractIsFrozen.selector);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );
    }

    function test_fulfillOffchainQuery_wrongCaller_fail() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, true);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        vm.expectRevert(OnlyPayeeCanFulfillOffchainQuery.selector);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );
    }

    function test_fulfillOffchainQuery_computeResultsMismatch() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, true);
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        fulfillInputs.computeResults[0] = bytes32(0x0);

        vm.prank(prover);
        vm.expectRevert(ComputeResultsHashDoesNotMatch.selector);
        axiomQuery.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );
    }

    function test_freeze() public {
        deploy(sourceChainId);

        vm.prank(WRONG_ADDRESS); // any address not guardian
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0x55435dd261a4b9b3364963f7738a7a662ad9c84396d64be3365284bb7f0a5041"
        );
        axiomQuery.freezeAll();
        assertFalse(axiomQuery.frozen());

        vm.prank(guardian); // guardian
        vm.expectEmit();
        emit FreezeAll();

        axiomQuery.freezeAll();
        assertTrue(axiomQuery.frozen());

        vm.prank(WRONG_ADDRESS); // any address not unfreeze
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf4e710c64967f31ba1090db2a7dd9e704155d00947ce853da47446cb68ee65da"
        );
        axiomQuery.unfreezeAll();
        assertTrue(axiomQuery.frozen());

        vm.prank(unfreeze); // unfreeze
        vm.expectEmit();
        emit UnfreezeAll();

        axiomQuery.unfreezeAll();
        assertFalse(axiomQuery.frozen());
    }

    function test_updateAxiomHeaderVerifierAddress() public {
        deploy(sourceChainId);

        vm.prank(WRONG_ADDRESS); // any address not timelock
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        );
        axiomQuery.updateAxiomHeaderVerifierAddress(NEW_ADDRESS);
        assertEq(axiomQuery.axiomHeaderVerifierAddress(), address(axiomHeaderVerifier));

        vm.prank(timelock); // timelock
        vm.expectEmit();
        emit UpdateAxiomHeaderVerifierAddress(NEW_ADDRESS);
        axiomQuery.updateAxiomHeaderVerifierAddress(NEW_ADDRESS);
        assertEq(axiomQuery.axiomHeaderVerifierAddress(), NEW_ADDRESS);

        vm.prank(timelock);
        vm.expectRevert(AxiomHeaderVerifierAddressIsZero.selector);
        axiomQuery.updateAxiomHeaderVerifierAddress(address(0));
    }

    function test_updateVerifierAddress() public {
        deploy(sourceChainId);

        vm.prank(WRONG_ADDRESS); // any address not timelock
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        );
        axiomQuery.updateVerifierAddress(NEW_ADDRESS);
        assertEq(axiomQuery.verifierAddress(), address(verifier));

        vm.prank(timelock); // timelock
        vm.expectEmit();
        emit UpdateVerifierAddress(NEW_ADDRESS);
        axiomQuery.updateVerifierAddress(NEW_ADDRESS);
        assertEq(axiomQuery.verifierAddress(), NEW_ADDRESS);

        vm.prank(timelock);
        vm.expectRevert(VerifierAddressIsZero.selector);
        axiomQuery.updateVerifierAddress(address(0));
    }

    function test_updateQueryDeadlineInterval() public {
        deploy(sourceChainId);

        vm.prank(WRONG_ADDRESS); // any address not timelock
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        );
        axiomQuery.updateQueryDeadlineInterval(7000);
        assertEq(axiomQuery.queryDeadlineInterval(), queryDeadlineInterval);

        vm.prank(timelock); // timelock
        vm.expectEmit();
        emit UpdateQueryDeadlineInterval(7000);
        axiomQuery.updateQueryDeadlineInterval(7000);
        assertEq(axiomQuery.queryDeadlineInterval(), 7000);

        vm.prank(timelock); // timelock
        vm.expectRevert(QueryDeadlineIntervalIsTooLarge.selector);
        axiomQuery.updateQueryDeadlineInterval(60_000);
    }

    function test_updateProofVerificationGas() public {
        deploy(sourceChainId);

        vm.prank(WRONG_ADDRESS); // any address not timelock
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        );
        axiomQuery.updateProofVerificationGas(400_000);
        assertEq(axiomQuery.proofVerificationGas(), proofVerificationGas);

        vm.prank(timelock); // timelock
        vm.expectEmit();
        emit UpdateProofVerificationGas(400_000);
        axiomQuery.updateProofVerificationGas(400_000);
        assertEq(axiomQuery.proofVerificationGas(), 400_000);

        vm.prank(timelock);
        vm.expectRevert(ProofVerificationGasIsTooLarge.selector);
        axiomQuery.updateProofVerificationGas(600_001);
    }

    function test_updateAxiomQueryFee() public {
        deploy(sourceChainId);

        vm.prank(WRONG_ADDRESS); // any address not timelock
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        );
        axiomQuery.updateAxiomQueryFee(0.002 ether);
        assertEq(axiomQuery.axiomQueryFee(), axiomQueryFee);

        vm.prank(timelock); // timelock
        vm.expectEmit();
        emit UpdateAxiomQueryFee(0.002 ether);
        axiomQuery.updateAxiomQueryFee(0.002 ether);
        assertEq(axiomQuery.axiomQueryFee(), 0.002 ether);

        vm.prank(timelock);
        vm.expectRevert(AxiomQueryFeeIsTooLarge.selector);
        axiomQuery.updateAxiomQueryFee(0.1 ether);
    }

    function test_updateMinMaxFeePerGas() public {
        deploy(sourceChainId);

        vm.prank(WRONG_ADDRESS); // any address not timelock
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        );
        axiomQuery.updateMinMaxFeePerGas(4 gwei);
        assertEq(axiomQuery.minMaxFeePerGas(), minMaxFeePerGas);

        vm.prank(timelock); // timelock
        vm.expectEmit();
        emit UpdateMinMaxFeePerGas(4 gwei);
        axiomQuery.updateMinMaxFeePerGas(4 gwei);
        assertEq(axiomQuery.minMaxFeePerGas(), 4 gwei);

        vm.prank(timelock);
        vm.expectRevert(MinMaxFeePerGasIsZero.selector);
        axiomQuery.updateMinMaxFeePerGas(0 gwei);
    }

    function test_increaseQueryGas() public {
        deploy(sourceChainId);

        // Initiate a query
        bytes32 queryHash = keccak256("test");
        sendInputs.feeData.maxFeePerGas = 10 gwei;
        sendInputs.feeData.callbackGasLimit = 2;
        vm.deal(caller, 20 ether);

        metadata.queryWitness.queryHash = queryHash;
        metadata.queryWitness.caller = caller;
        // fail to increase if query is inactive
        vm.prank(caller);
        vm.expectRevert(CanOnlyIncreaseGasOnActiveQuery.selector);
        axiomQuery.increaseQueryGas{ value: 1 ether }(uint256(1), 10 gwei, 3, sendInputs.feeData.overrideAxiomQueryFee);

        vm.prank(caller);
        uint256 queryId = axiomQuery.sendQueryWithIpfsData{ value: 1 ether }(
            queryHash,
            keccak256("ipfs"),
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund
        );

        // increase the query gas
        vm.prank(caller);
        vm.expectEmit();
        emit QueryGasIncreased(queryId, 10 gwei, 3, sendInputs.feeData.overrideAxiomQueryFee);
        vm.expectEmit();
        emit Deposit(caller, 99_999_990_000_000_000);
        axiomQuery.increaseQueryGas{ value: 0.1 ether }(queryId, 10 gwei, 3, sendInputs.feeData.overrideAxiomQueryFee);

        // increase the query gas
        vm.prank(caller);
        vm.expectEmit();
        emit QueryGasIncreased(queryId, 10 gwei, 4, sendInputs.feeData.overrideAxiomQueryFee);
        axiomQuery.increaseQueryGas{ value: 0.1 ether }(queryId, 10 gwei, 4, sendInputs.feeData.overrideAxiomQueryFee);

        // increase from wrong address is OK
        vm.deal(WRONG_ADDRESS, 1 ether);
        vm.prank(WRONG_ADDRESS);
        vm.expectEmit();
        emit QueryGasIncreased(queryId, 10 gwei, 5, sendInputs.feeData.overrideAxiomQueryFee);
        axiomQuery.increaseQueryGas{ value: 0.1 ether }(queryId, 10 gwei, 5, sendInputs.feeData.overrideAxiomQueryFee);

        // fail to increase with smaller amount
        vm.prank(caller);
        vm.expectRevert(NewMaxQueryPriMustBeLargerThanPrevious.selector);
        axiomQuery.increaseQueryGas(queryId, 10 gwei, 2, sendInputs.feeData.overrideAxiomQueryFee);

        // fail to increase if new maxFeePerGas is too low
        vm.prank(caller);
        vm.expectRevert(MaxFeePerGasIsTooLow.selector);
        axiomQuery.increaseQueryGas(queryId, 1 gwei, 100, sendInputs.feeData.overrideAxiomQueryFee);

        // fail to increase without payment
        vm.prank(caller);
        vm.expectRevert(InsufficientFunds.selector);
        axiomQuery.increaseQueryGas(queryId, 10 gwei, 6, sendInputs.feeData.overrideAxiomQueryFee);

        // fail to increase if frozen
        vm.prank(guardian);
        axiomQuery.freezeAll();
        vm.prank(caller);
        vm.expectRevert(ContractIsFrozen.selector);
        axiomQuery.increaseQueryGas{ value: 0.1 ether }(queryId, 10 gwei, 6, sendInputs.feeData.overrideAxiomQueryFee);

        vm.prank(unfreeze);
        axiomQuery.unfreezeAll();

        // increase the query gas and fee
        sendInputs.feeData.overrideAxiomQueryFee = 0.005 ether;
        vm.prank(caller);
        vm.expectEmit();
        emit QueryGasIncreased(queryId, 10 gwei, 4, sendInputs.feeData.overrideAxiomQueryFee);
        axiomQuery.increaseQueryGas{ value: 0.1 ether }(queryId, 10 gwei, 4, sendInputs.feeData.overrideAxiomQueryFee);
    }

    function test_refundQuery() public {
        deploy(sourceChainId);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        // Initiate a query
        bytes32 queryHash = keccak256("test");
        uint64 maxFeePerGas = 6 gwei;
        uint32 callbackGasLimit = 1;
        vm.deal(caller, 1 ether);
        vm.prank(caller);
        uint256 queryId = axiomQuery.sendQueryWithIpfsData{ value: 1 ether }(
            queryHash, keccak256("ipfs"), sendInputs.callback, sendInputs.feeData, sendInputs.userSalt, caller
        );

        // Advance the block number to exceed the deadline
        vm.roll(block.number + queryDeadlineInterval + 1);
        assertEq(caller.balance, 0 ether);

        // Refund the query
        metadata.queryWitness.caller = caller;
        metadata.queryWitness.queryHash = queryHash;
        metadata.queryWitness.refundee = caller;
        vm.prank(caller);
        vm.expectEmit(address(axiomQuery));
        emit QueryRefunded(queryId, caller);
        axiomQuery.refundQuery(metadata.queryWitness);

        // Withdraw the refund
        vm.prank(caller);
        vm.expectEmit(address(axiomQuery));
        emit Withdraw(caller, 1 ether, caller);
        axiomQuery.withdraw(1 ether, payable(caller));
        assertEq(caller.balance, 1 ether);
    }

    function test_refundQuery_notActive_fail() public {
        deploy(sourceChainId);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        // Try to refund a query that has not been initiated
        bytes32 queryHash = keccak256("test");
        vm.prank(refund);
        vm.expectRevert(CannotRefundIfNotActive.selector);
        axiomQuery.refundQuery(metadata.queryWitness);
    }

    function test_refundQuery_wrongCaller_fail() public {
        deploy(sourceChainId);

        // Try to refund a query that has not been initiated
        bytes32 queryHash = keccak256("test");
        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(CannotRefundIfNotRefundee.selector);
        axiomQuery.refundQuery(metadata.queryWitness);
    }

    function test_refundQuery_beforeDeadline_fail() public {
        deploy(sourceChainId);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        // Initiate a query
        bytes32 queryHash = keccak256("test");
        uint64 maxFeePerGas = 6 gwei;
        uint32 callbackGasLimit = 1;
        vm.deal(caller, 1 ether);
        vm.prank(caller);
        axiomQuery.sendQueryWithIpfsData{ value: 1 ether }(
            queryHash,
            keccak256("ipfs"),
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund
        );

        metadata.queryWitness.queryHash = queryHash;
        vm.prank(refund);
        // Try to refund the query before the deadline
        vm.expectRevert(CannotRefundBeforeDeadline.selector);
        axiomQuery.refundQuery(metadata.queryWitness);
    }

    function test_deposit() public {
        deploy(sourceChainId);
        vm.deal(PAYOR_ADDRESS, 200 ether);
        vm.prank(PAYOR_ADDRESS);
        vm.expectEmit();
        emit Deposit(PAYOR_ADDRESS, 10 ether);

        axiomQuery.deposit{ value: 10 ether }(PAYOR_ADDRESS);
        assertEq(axiomQuery.balances(PAYOR_ADDRESS), 10 ether);

        vm.expectRevert(PayorAddressIsZero.selector);
        axiomQuery.deposit{ value: 10 ether }(address(0));

        vm.expectRevert(DepositAmountIsZero.selector);
        axiomQuery.deposit{ value: 0 ether }(PAYOR_ADDRESS);
    }

    function test_withdraw() public {
        deploy(sourceChainId);

        vm.deal(PAYOR_ADDRESS, 200 ether);
        vm.prank(PAYOR_ADDRESS);
        axiomQuery.deposit{ value: 10 ether }(PAYOR_ADDRESS);

        vm.prank(PAYOR_ADDRESS);
        vm.expectRevert(PayeeAddressIsZero.selector);
        axiomQuery.withdraw(5 ether, payable(address(0)));

        vm.prank(PAYOR_ADDRESS);
        vm.expectEmit();
        emit Withdraw(PAYOR_ADDRESS, 5 ether, NEW_ADDRESS);
        axiomQuery.withdraw(5 ether, payable(NEW_ADDRESS));
        assertEq(axiomQuery.balances(PAYOR_ADDRESS), 5 ether);
        assertEq(NEW_ADDRESS.balance, 5 ether);

        vm.expectRevert(WithdrawalAmountIsZero.selector);
        axiomQuery.withdraw(0 ether, payable(NEW_ADDRESS));

        vm.prank(guardian);
        axiomQuery.freezeAll();
        vm.prank(PAYOR_ADDRESS);
        vm.expectEmit();
        emit Withdraw(PAYOR_ADDRESS, 1 ether, NEW_ADDRESS);
        axiomQuery.withdraw(1 ether, payable(NEW_ADDRESS));
        assertEq(axiomQuery.balances(PAYOR_ADDRESS), 4 ether);
        assertEq(NEW_ADDRESS.balance, 6 ether);
    }

    function test_withdraw_exceedsBalance_fail() public {
        deploy(sourceChainId);

        vm.deal(PAYOR_ADDRESS, 200 ether);
        vm.prank(PAYOR_ADDRESS);
        axiomQuery.deposit{ value: 10 ether }(PAYOR_ADDRESS);

        vm.prank(PAYOR_ADDRESS);
        vm.expectRevert(WithdrawalAmountExceedsFreeBalance.selector);
        axiomQuery.withdraw(15 ether, payable(NEW_ADDRESS));
    }

    function test_deposit_tooLarge_fail() public {
        deploy(sourceChainId);
        vm.deal(PAYOR_ADDRESS, 200 ether);
        vm.prank(PAYOR_ADDRESS);
        vm.expectRevert(DepositTooLarge.selector);
        axiomQuery.deposit{ value: 101 ether }(PAYOR_ADDRESS);
    }

    function test_unescrow() public {
        test_fulfillQuery();
        vm.prank(fulfillInputs.payee);
        vm.expectEmit();
        emit Unescrow(caller, metadata.queryId, fulfillInputs.payee, sendInputs.refund, 0.01 ether);
        axiomQuery.unescrow(metadata.queryWitness, 0.01 ether);
    }

    function test_unescrow_tooLarge_fail() public {
        test_fulfillQuery();
        vm.prank(prover);
        vm.expectRevert(UnescrowAmountExceedsEscrowedAmount.selector);
        axiomQuery.unescrow(metadata.queryWitness, 0.2 ether);
    }

    function test_unescrow_wrongPayee_fail() public {
        test_fulfillQuery();
        vm.prank(NEW_ADDRESS);
        vm.expectRevert(OnlyPayeeCanUnescrow.selector);
        axiomQuery.unescrow(metadata.queryWitness, 0.01 ether);
    }

    function test_unescrow_notReleased_fail() public {
        deploy(sourceChainId);
        vm.deal(PAYOR_ADDRESS, 200 ether);
        vm.prank(PAYOR_ADDRESS);
        axiomQuery.deposit{ value: 10 ether }(PAYOR_ADDRESS);
        vm.prank(prover);
        vm.expectRevert(QueryIsNotFulfilled.selector);
        axiomQuery.unescrow(metadata.queryWitness, 3 ether);
    }

    function test_supportsInterface() public {
        console.log(uint64(block.chainid));
        deploy(uint64(1));
        assert(axiomQuery.supportsInterface(type(IAxiomV2Query).interfaceId));
    }

    function test_addRemoveAggregateVkeyHash() public {
        deploy(sourceChainId);
        bytes32 testHash = keccak256("test hash");

        vm.prank(timelock);
        vm.expectEmit();
        emit AddAggregateVkeyHash(testHash);
        axiomQuery.addAggregateVkeyHash(testHash);
        assertTrue(axiomQuery.aggregateVkeyHashes(testHash));

        vm.prank(timelock);
        vm.expectEmit();
        emit RemoveAggregateVkeyHash(testHash);
        axiomQuery.removeAggregateVkeyHash(testHash);
        assertFalse(axiomQuery.aggregateVkeyHashes(testHash));
    }

    function test_addPerQueryProver() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        vm.prank(timelock);
        vm.expectEmit();
        emit AddPerQueryProver(metadata.querySchema, address(client), WRONG_ADDRESS);
        axiomQuery.addPerQueryProver(metadata.querySchema, address(client), WRONG_ADDRESS);

        sendQuery();
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(WRONG_ADDRESS);
        vm.expectEmit();
        emit QueryFulfilled(metadata.queryId, fulfillInputs.payee, true);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_removePerQueryProver() public {
        _forkAndDeploy("sepolia", forkBlockNumber);
        assignFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        vm.prank(timelock);
        vm.expectEmit();
        emit AddPerQueryProver(metadata.querySchema, address(client), WRONG_ADDRESS);
        axiomQuery.addPerQueryProver(metadata.querySchema, address(client), WRONG_ADDRESS);

        vm.prank(timelock);
        vm.expectEmit();
        emit RemovePerQueryProver(metadata.querySchema, address(client), WRONG_ADDRESS);
        axiomQuery.removePerQueryProver(metadata.querySchema, address(client), WRONG_ADDRESS);

        sendQuery();
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(ProverNotAuthorized.selector);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }
}
