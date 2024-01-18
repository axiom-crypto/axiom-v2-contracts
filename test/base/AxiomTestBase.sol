// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "forge-std/StdJson.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";
import { IAxiomV2HeaderVerifier } from "../../contracts/interfaces/query/IAxiomV2HeaderVerifier.sol";

import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { AxiomV2HeaderVerifier } from "../../contracts/query/AxiomV2HeaderVerifier.sol";
import { AxiomV2Core } from "../../contracts/core/AxiomV2Core.sol";
import { AxiomV2CoreMock } from "../../contracts/mock/AxiomV2CoreMock.sol";
import { AxiomV2Query } from "../../contracts/query/AxiomV2Query.sol";
import { ExampleV2Client } from "../../contracts/client/ExampleV2Client.sol";
import { MerkleMountainRange } from "../../contracts/libraries/MerkleMountainRange.sol";
import { PaddedMerkleMountainRange } from "../../contracts/libraries/PaddedMerkleMountainRange.sol";
import {
    GOERLI_CHAIN_ID,
    MAINNET_CHAIN_ID,
    SEPOLIA_CHAIN_ID
} from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";

import {
    AxiomV2CoreVerifier,
    AxiomV2CoreHistoricalVerifier,
    AxiomV2QueryVerifier
} from "../../snark-verifiers/AxiomVerifierImports.sol";

string constant CORE_CONFIG_FILE = "test/data/core/config.json";
string constant QUERY_CONFIG_FILE = "test/data/query/config.json";

error NotProverRole();
error ContractIsFrozen();

error SNARKVerificationFailed();
error AxiomBlockVerificationFailed();
error IncorrectNumberOfBlocks();
error StartingBlockNotValid();
error NotRecentEndBlock();
error BlockHashIncorrect();
error MerkleProofFailed();

error VerifierAddressIsZero();
error HistoricalVerifierAddressIsZero();
error TimelockAddressIsZero();
error GuardianAddressIsZero();
error UnfreezeAddressIsZero();
error ProverAddressIsZero();
error AxiomCoreAddressIsZero();
error AxiomQueryAddressIsZero();
error DepositAmountIsZero();
error WithdrawalAmountIsZero();
error MinMaxFeePerGasIsZero();
error QueryDeadlineIntervalIsTooLarge();
error ProofVerificationGasIsTooLarge();
error AxiomQueryFeeIsTooLarge();
error ProofMmrKeccakDoesNotMatch();
error OnlyPayeeCanFulfillOffchainQuery();
error InsufficientGasForCallback();
error MaxFeePerGasIsTooLow();

error ProverNotAuthorized();

error PayeeAddressIsZero();
error PayorAddressIsZero();

struct AxiomTestSendInputs {
    bytes32 dataQueryHash;
    IAxiomV2Query.AxiomV2ComputeQuery computeQuery;
    IAxiomV2Query.AxiomV2Callback callback;
    IAxiomV2Query.AxiomV2FeeData feeData;
    bytes32 userSalt;
    address refund;
    bytes dataQuery;
    bytes32 ipfsHash;
    bool isIpfs;
}

struct AxiomTestMetadata {
    bytes32 queryHash;
    bytes32 querySchema;
    uint256 queryId;
    IAxiomV2Query.AxiomV2QueryWitness queryWitness;
    bytes32 callbackHash;
}

struct AxiomTestFulfillInputs {
    IAxiomV2HeaderVerifier.MmrWitness mmrWitness;
    bytes32[] computeResults;
    bytes proof;
    bytes dataOnlyProof;
    bytes32 snapshotPmmrHash;
    bool isOffchain;
    address caller;
    address payee;
}

contract AxiomV2CoreCheat is AxiomV2Core {
    function setHistoricalRoot(uint32 startBlockNumber, bytes32 root) public {
        AxiomV2Core.historicalRoots[startBlockNumber] = root;
    }

    function setBlockhashPmmrLen(uint32 itemsSize) public {
        AxiomV2Core.blockhashPmmr.size = itemsSize;
    }

    function setBlockhashPmmrLeaf(bytes32 leaf) public {
        AxiomV2Core.blockhashPmmr.paddedLeaf = leaf;
    }

    function setBlockhashPmmr(PaddedMerkleMountainRange.PMMR calldata pmmr) public {
        AxiomV2Core.blockhashPmmr = pmmr;
    }

    function setPmmrSnapshot(uint32 endBlockNumber, bytes32 snapshotHash) external {
        AxiomV2Core.pmmrSnapshots[endBlockNumber] = snapshotHash;
    }
}

contract AxiomV2CoreMockCheat is AxiomV2CoreMock {
    function setHistoricalRoot(uint32 startBlockNumber, bytes32 root) public {
        AxiomV2CoreMock.historicalRoots[startBlockNumber] = root;
    }

    function setBlockhashPmmrLen(uint32 itemsSize) public {
        AxiomV2CoreMock.blockhashPmmr.size = itemsSize;
    }

    function setBlockhashPmmrLeaf(bytes32 leaf) public {
        AxiomV2CoreMock.blockhashPmmr.paddedLeaf = leaf;
    }

    function setBlockhashPmmr(PaddedMerkleMountainRange.PMMR calldata pmmr) public {
        AxiomV2CoreMock.blockhashPmmr = pmmr;
    }

    function setPmmrSnapshot(uint32 endBlockNumber, bytes32 snapshotHash) external {
        AxiomV2CoreMock.pmmrSnapshots[endBlockNumber] = snapshotHash;
    }
}

abstract contract AxiomTestBase is Test {
    string public QUERY_TEST_FILE_PATH;

    // Valid SNARK for blocks in `[0xf99000, 0xf993ff]`
    string public CORE_UPDATE_OLD1_FILE_PATH;

    // Valid SNARK for blocks in `[0xf99000, 0xf9907f]`
    string public CORE_UPDATE_OLD2_FILE_PATH;

    // Valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
    string public CORE_UPDATE_HISTORICAL_FILE_PATH;

    // CREATE3 related
    CREATE3Factory public create3;
    bytes32 constant SALT = hex"1234";

    // role addresses
    address public prover;
    address public timelock;
    address public guardian;
    address public unfreeze;
    address public caller;
    address public refund;
    address public query;

    address public constant WRONG_ADDRESS = address(66);
    address public constant NEW_ADDRESS = address(77);
    address public constant PAYOR_ADDRESS = address(88);

    // AxiomV2Query settings
    bytes32[] public aggregateVkeyHashes;
    uint32 public queryDeadlineInterval;
    uint32 public proofVerificationGas;
    uint256 public axiomQueryFee;
    uint64 public minMaxFeePerGas;
    uint32 public maxQueryDeadlineInterval;

    IAxiomV2Query.AxiomV2QueryInit public init;

    // Deployed verifiers for AxiomV2Core
    AxiomV2CoreVerifier public axiomVerifierAddress;
    AxiomV2CoreHistoricalVerifier public axiomHistoricalVerifierAddress;

    // Deployed verifier for AxiomV2Query
    AxiomV2QueryVerifier public verifier;

    // AxiomV2Core and AxiomV2Query contracts
    AxiomV2CoreCheat public axiom;
    AxiomV2CoreMockCheat public axiomMock;
    AxiomV2HeaderVerifier public axiomHeaderVerifier;
    AxiomV2Query public axiomQuery;
    ExampleV2Client public client;

    // storage for AxiomV2CoreMock bootstrapping
    string public file;

    bytes32[] public rootsJson;
    bytes32[][] public endHashProofsJson;
    bytes32[128] public roots;
    bytes32[11][127] public endHashProofs;
    bytes public proofData;
    bytes32[] public prevHashes;

    constructor() {
        _readCoreConfigs();
        _readQueryConfigs();

        create3 = new CREATE3Factory();

        prover = address(1);
        timelock = address(2);
        guardian = address(3);
        unfreeze = address(4);
        caller = address(5);
        refund = address(6);
        query = address(9);

        queryDeadlineInterval = 7200;
        maxQueryDeadlineInterval = 50_400;
        proofVerificationGas = 500_000;
        axiomQueryFee = 0.003 ether;
        minMaxFeePerGas = 5 gwei;

        vm.makePersistent(address(create3));
    }

    function _readCoreConfigs() internal {
        string memory coreFile = vm.readFile(CORE_CONFIG_FILE);
        CORE_UPDATE_OLD1_FILE_PATH =
            abi.decode(vm.parseJson(coreFile, ".core_update_f99000_f993ff_file_path"), (string));
        CORE_UPDATE_OLD2_FILE_PATH =
            abi.decode(vm.parseJson(coreFile, ".core_update_f99000_f9907f_file_path"), (string));
        CORE_UPDATE_HISTORICAL_FILE_PATH =
            abi.decode(vm.parseJson(coreFile, ".core_update_000000_01ffff_file_path"), (string));
    }

    function _readQueryConfigs() internal {
        string memory queryFile = vm.readFile(QUERY_CONFIG_FILE);
        QUERY_TEST_FILE_PATH = abi.decode(vm.parseJson(queryFile, ".query_test_file_path"), (string));
        string memory metadataPath =
            abi.decode(vm.parseJson(queryFile, ".axiom_v2_query_verifier_metadata_path"), (string));
        string memory metadataFile = vm.readFile(metadataPath);
        aggregateVkeyHashes = abi.decode(vm.parseJson(metadataFile, ".circuit_data.aggregate_vkey_hashes"), (bytes32[]));
    }

    function deployAxiomCore() public {
        AxiomV2CoreCheat impl = new AxiomV2CoreCheat();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            axiomVerifierAddress,
            axiomHistoricalVerifierAddress,
            timelock,
            guardian,
            unfreeze,
            prover
        );
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
        axiom = AxiomV2CoreCheat(payable(address(proxy)));
        vm.makePersistent(address(impl));
        vm.makePersistent(address(axiom));
    }

    function deployAxiomCoreMock() public {
        AxiomV2CoreMockCheat impl = new AxiomV2CoreMockCheat();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            axiomVerifierAddress,
            axiomHistoricalVerifierAddress,
            timelock,
            guardian,
            unfreeze,
            prover
        );
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
        axiomMock = AxiomV2CoreMockCheat(payable(address(proxy)));
        vm.makePersistent(address(impl));
        vm.makePersistent(address(axiomMock));
    }

    function deployAxiomHeaderVerifier(uint64 sourceChainId) public {
        axiomHeaderVerifier = new AxiomV2HeaderVerifier(sourceChainId, address(axiom));
        vm.makePersistent(address(axiomHeaderVerifier));
    }

    function deployAxiomVerifier() public {
        verifier = new AxiomV2QueryVerifier();
        vm.makePersistent(address(verifier));
    }

    function deployCoreVerifiers() public {
        axiomVerifierAddress = new AxiomV2CoreVerifier();
        axiomHistoricalVerifierAddress = new AxiomV2CoreHistoricalVerifier();
        vm.makePersistent(address(axiomVerifierAddress));
        vm.makePersistent(address(axiomHistoricalVerifierAddress));
    }

    function deployQuery() public {
        queryDeadlineInterval = 7200;
        proofVerificationGas = 500_000;
        axiomQueryFee = 0.003 ether;
        minMaxFeePerGas = 5 gwei;
        maxQueryDeadlineInterval = 50_400;

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
            unfreeze: unfreeze
        });
        AxiomV2Query impl = new AxiomV2Query();
        bytes memory data = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        AxiomProxy queryProxy = AxiomProxy(
            payable(
                create3.deploy(SALT, abi.encodePacked(type(AxiomProxy).creationCode, abi.encode(address(impl), data)))
            )
        );
        axiomQuery = AxiomV2Query(payable(address(queryProxy)));
        vm.makePersistent(address(axiomQuery));
    }

    function deployClient(uint64 sourceChainId) public {
        client = new ExampleV2Client(address(axiomQuery), sourceChainId);
        vm.makePersistent(address(client));
    }

    function deploy(uint64 sourceChainId) public {
        deployCoreVerifiers();
        deployAxiomCore();
        deployAxiomCoreMock();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomVerifier();
        deployQuery();
        deployClient(sourceChainId);
    }

    function _forkAndDeploy(string memory network, uint64 blockNumber) internal {
        vm.createSelectFork(network, blockNumber);
        uint64 sourceChainId;
        if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("mainnet"))) {
            sourceChainId = MAINNET_CHAIN_ID;
        } else if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("goerli"))) {
            sourceChainId = GOERLI_CHAIN_ID;
        } else if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("sepolia"))) {
            sourceChainId = SEPOLIA_CHAIN_ID;
        } else {
            revert("Network is not supported.");
        }
        deploy(sourceChainId);
    }

    // Valid SNARK for blocks in `[0xf99000, 0xf993ff]`
    function _readCoreUpdateOld1ProofData() internal view returns (bytes memory proofData) {
        string memory fileStr = vm.readFile(CORE_UPDATE_OLD1_FILE_PATH);
        proofData = vm.parseBytes(fileStr);
    }

    // Valid SNARK for blocks in `[0xf99000, 0xf9907f]`
    function _readCoreUpdateOld2ProofData() internal view returns (bytes memory proofData) {
        string memory fileStr = vm.readFile(CORE_UPDATE_OLD2_FILE_PATH);
        proofData = vm.parseBytes(fileStr);
    }

    // Valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
    function _readCoreUpdateHistoricalProofData() internal view returns (bytes memory proofData) {
        string memory fileStr = vm.readFile(CORE_UPDATE_HISTORICAL_FILE_PATH);
        proofData = vm.parseBytes(fileStr);
    }

    function _readFromFile(
        string memory filename,
        bool isIpfs,
        bool isEmptyComputeQuery,
        bool isEmptyCallback,
        bool isOffchainFulfill
    )
        internal
        returns (
            AxiomTestSendInputs memory sendInputs,
            AxiomTestMetadata memory metadata,
            AxiomTestFulfillInputs memory fulfillInputs,
            uint32 forkBlockNumber,
            uint64 sourceChainId
        )
    {
        string memory file = vm.readFile(filename);

        sendInputs.dataQueryHash = abi.decode(vm.parseJson(file, ".send.dataQueryHash"), (bytes32));
        bytes32[] memory vkey = abi.decode(vm.parseJson(file, ".send.computeQuery.vkey"), (bytes32[]));
        sendInputs.computeQuery = IAxiomV2Query.AxiomV2ComputeQuery({
            k: abi.decode(vm.parseJson(file, ".send.computeQuery.k"), (uint8)),
            resultLen: abi.decode(vm.parseJson(file, ".send.computeQuery.resultLen"), (uint16)),
            vkey: vkey,
            computeProof: abi.decode(vm.parseJson(file, ".send.computeQuery.computeProof"), (bytes))
        });
        sendInputs.callback = IAxiomV2Query.AxiomV2Callback({
            target: address(client),
            extraData: vm.parseJsonBytes(file, ".send.callback.extraData")
        });
        sendInputs.feeData = IAxiomV2Query.AxiomV2FeeData({
            maxFeePerGas: abi.decode(vm.parseJson(file, ".send.feeData.maxFeePerGas"), (uint64)),
            callbackGasLimit: abi.decode(vm.parseJson(file, ".send.feeData.callbackGasLimit"), (uint32)),
            overrideAxiomQueryFee: abi.decode(vm.parseJson(file, ".send.feeData.overrideAxiomQueryFee"), (uint256))
        });
        sendInputs.userSalt = abi.decode(vm.parseJson(file, ".send.userSalt"), (bytes32));
        if (!isOffchainFulfill) {
            sendInputs.refund = refund;
        } else {
            sendInputs.refund = address(0);
        }
        sendInputs.dataQuery = vm.parseJsonBytes(file, ".send.dataQuery");
        sendInputs.ipfsHash = abi.decode(vm.parseJson(file, ".send.ipfsHash"), (bytes32));
        sendInputs.isIpfs = isIpfs;

        if (isEmptyComputeQuery) {
            sendInputs.computeQuery = IAxiomV2Query.AxiomV2ComputeQuery({
                k: uint8(0),
                resultLen: abi.decode(vm.parseJson(file, ".send.computeQuery.resultLen"), (uint16)),
                vkey: vkey,
                computeProof: hex""
            });
        }
        if (isEmptyCallback) {
            sendInputs.callback = IAxiomV2Query.AxiomV2Callback({ target: address(0), extraData: hex"" });
        }

        bytes32[] memory proofMmrPeaks =
            abi.decode(vm.parseJson(file, ".fulfill.mmrWitness.proofMmrPeaks"), (bytes32[]));
        bytes32[] memory mmrComplementOrPeaks =
            abi.decode(vm.parseJson(file, ".fulfill.mmrWitness.mmrComplementOrPeaks"), (bytes32[]));
        bytes32[] memory computeResults = abi.decode(vm.parseJson(file, ".fulfill.computeResults"), (bytes32[]));

        fulfillInputs.mmrWitness = IAxiomV2HeaderVerifier.MmrWitness({
            snapshotPmmrSize: abi.decode(vm.parseJson(file, ".fulfill.mmrWitness.snapshotPmmrSize"), (uint32)),
            proofMmrPeaks: proofMmrPeaks,
            mmrComplementOrPeaks: mmrComplementOrPeaks
        });
        fulfillInputs.computeResults = computeResults;
        fulfillInputs.proof = abi.decode(vm.parseJson(file, ".fulfill.proof"), (bytes));
        fulfillInputs.dataOnlyProof = abi.decode(vm.parseJson(file, ".fulfill.dataOnlyProof"), (bytes));
        fulfillInputs.snapshotPmmrHash = abi.decode(vm.parseJson(file, ".fulfill.snapshotPmmrHash"), (bytes32));
        fulfillInputs.payee = abi.decode(vm.parseJson(file, ".fulfill.payee"), (address));
        if (!isOffchainFulfill) {
            fulfillInputs.caller = address(caller);
        } else {
            fulfillInputs.caller = address(0);
        }
        fulfillInputs.isOffchain = isOffchainFulfill;

        metadata.queryHash = abi.decode(vm.parseJson(file, ".metadata.queryHash"), (bytes32));
        metadata.querySchema = abi.decode(vm.parseJson(file, ".metadata.querySchema"), (bytes32));
        metadata.callbackHash = keccak256(abi.encodePacked(sendInputs.callback.target, sendInputs.callback.extraData));
        sourceChainId = abi.decode(vm.parseJson(file, ".sourceChainId"), (uint64));
        if (isEmptyComputeQuery) {
            metadata.queryHash = keccak256(
                abi.encodePacked(
                    uint8(2),
                    sourceChainId,
                    sendInputs.dataQueryHash,
                    sendInputs.computeQuery.k,
                    sendInputs.computeQuery.resultLen
                )
            );
        }
        if (!isOffchainFulfill) {
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
            metadata.queryWitness = IAxiomV2Query.AxiomV2QueryWitness({
                caller: address(caller),
                userSalt: sendInputs.userSalt,
                queryHash: metadata.queryHash,
                callbackHash: metadata.callbackHash,
                refundee: refund
            });
        } else {
            metadata.queryId = uint256(
                keccak256(
                    abi.encodePacked(
                        uint64(block.chainid),
                        fulfillInputs.payee,
                        sendInputs.userSalt,
                        metadata.queryHash,
                        metadata.callbackHash,
                        address(0)
                    )
                )
            );
            metadata.queryWitness = IAxiomV2Query.AxiomV2QueryWitness({
                caller: address(prover),
                userSalt: sendInputs.userSalt,
                queryHash: metadata.queryHash,
                callbackHash: metadata.callbackHash,
                refundee: address(0)
            });
        }

        forkBlockNumber = abi.decode(vm.parseJson(file, ".forkBlockNumber"), (uint32));
    }

    function _readHeaderVerifierWitnessFromFile(string memory filename)
        internal
        returns (
            bytes32 proofMmrKeccak,
            IAxiomV2HeaderVerifier.MmrWitness memory mmrWitness,
            uint32 forkBlockNumber,
            bytes32 snapshotPmmrHash
        )
    {
        string memory file = vm.readFile(filename);
        proofMmrKeccak = abi.decode(vm.parseJson(file, ".fulfill.proofMmrKeccak"), (bytes32));
        mmrWitness = IAxiomV2HeaderVerifier.MmrWitness({
            snapshotPmmrSize: abi.decode(vm.parseJson(file, ".fulfill.mmrWitness.snapshotPmmrSize"), (uint32)),
            proofMmrPeaks: abi.decode(vm.parseJson(file, ".fulfill.mmrWitness.proofMmrPeaks"), (bytes32[])),
            mmrComplementOrPeaks: abi.decode(vm.parseJson(file, ".fulfill.mmrWitness.mmrComplementOrPeaks"), (bytes32[]))
        });
        forkBlockNumber = abi.decode(vm.parseJson(file, ".forkBlockNumber"), (uint32));
        snapshotPmmrHash = abi.decode(vm.parseJson(file, ".fulfill.snapshotPmmrHash"), (bytes32));
    }

    function _readBlockhashPmmrFromFile(string memory filename)
        internal
        returns (PaddedMerkleMountainRange.PMMR memory pmmr)
    {
        string memory file = vm.readFile(filename);
        bytes32[32] memory peaks;
        bytes32[] memory peaksRaw = abi.decode(vm.parseJson(file, ".blockhashPmmr.completeLeaves.peaks"), (bytes32[]));
        for (uint256 i = 0; i < peaksRaw.length; i++) {
            peaks[i] = peaksRaw[i];
        }
        pmmr = PaddedMerkleMountainRange.PMMR({
            paddedLeaf: abi.decode(vm.parseJson(file, ".blockhashPmmr.paddedLeaf"), (bytes32)),
            size: abi.decode(vm.parseJson(file, ".blockhashPmmr.size"), (uint32)),
            completeLeaves: MerkleMountainRange.MMR({
                peaks: peaks,
                peaksLength: abi.decode(vm.parseJson(file, ".blockhashPmmr.completeLeaves.peaksLength"), (uint32))
            })
        });
    }

    function _updateHistorical(string memory filename) internal {
        file = vm.readFile(filename);

        bytes32 nextRoot = abi.decode(vm.parseJson(file, ".nextRoot"), (bytes32));
        uint32 nextNumFinal = uint32(vm.parseUint(abi.decode(vm.parseJson(file, ".nextNumFinal"), (string))));
        rootsJson = abi.decode(vm.parseJson(file, ".roots"), (bytes32[]));
        for (uint256 i = 0; i < rootsJson.length; i++) {
            roots[i] = rootsJson[i];
        }

        endHashProofsJson = abi.decode(vm.parseJson(file, ".endHashProofs"), (bytes32[][]));
        for (uint256 i = 0; i < endHashProofsJson.length; i++) {
            for (uint256 j = 0; j < endHashProofsJson[i].length; j++) {
                endHashProofs[i][j] = endHashProofsJson[i][j];
            }
        }
        proofData = abi.decode(vm.parseJson(file, ".proofData"), (bytes));

        vm.prank(prover);
        axiomMock.updateHistorical(nextRoot, nextNumFinal, roots, endHashProofs, proofData);
    }

    function _appendHistoricalPmmr(string memory filename) internal {
        file = vm.readFile(filename);
        uint32 startBlockNumber = uint32(vm.parseUint(abi.decode(vm.parseJson(file, ".startBlockNumber"), (string))));
        rootsJson = abi.decode(vm.parseJson(file, ".roots"), (bytes32[]));
        prevHashes = abi.decode(vm.parseJson(file, ".prevHashes"), (bytes32[]));
        uint32 lastNumFinal = uint32(vm.parseUint(abi.decode(vm.parseJson(file, ".lastNumFinal"), (string))));

        axiomMock.appendHistoricalPMMR(startBlockNumber, rootsJson, prevHashes, lastNumFinal);
    }

    function _runBackfillTest(string memory filename) internal {
        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile(filename);
        axiomMock.setBlockhashPmmr(pmmr);

        file = vm.readFile(filename);
        uint32 updateRecent_startBlockNumber =
            abi.decode(vm.parseJson(file, ".updateRecent.startBlockNumber"), (uint32));
        bytes memory updateRecent_proofData = abi.decode(vm.parseJson(file, ".updateRecent.proofData"), (bytes));

        bytes32 updateOld1_nextRoot = abi.decode(vm.parseJson(file, ".updateOld1.nextRoot"), (bytes32));
        uint32 updateOld1_nextNumFinal = abi.decode(vm.parseJson(file, ".updateOld1.nextNumFinal"), (uint32));
        bytes memory updateOld1_proofData = abi.decode(vm.parseJson(file, ".updateOld1.proofData"), (bytes));

        bytes32 updateOld2_nextRoot = abi.decode(vm.parseJson(file, ".updateOld2.nextRoot"), (bytes32));
        uint32 updateOld2_nextNumFinal = abi.decode(vm.parseJson(file, ".updateOld2.nextNumFinal"), (uint32));
        bytes memory updateOld2_proofData = abi.decode(vm.parseJson(file, ".updateOld2.proofData"), (bytes));

        uint32 appendHistoricalPmmr_startBlockNumber =
            abi.decode(vm.parseJson(file, ".appendHistoricalPmmr.startBlockNumber"), (uint32));
        bytes32[] memory appendHistoricalPmmr_roots =
            abi.decode(vm.parseJson(file, ".appendHistoricalPmmr.roots"), (bytes32[]));
        bytes32[] memory appendHistoricalPmmr_prevHashes =
            abi.decode(vm.parseJson(file, ".appendHistoricalPmmr.prevHashes"), (bytes32[]));
        uint32 appendHistoricalPmmr_lastNumFinal =
            abi.decode(vm.parseJson(file, ".appendHistoricalPmmr.lastNumFinal"), (uint32));

        vm.prank(prover);
        axiomMock.updateRecent(updateRecent_proofData);
        vm.prank(prover);
        axiomMock.updateOld(updateOld1_nextRoot, updateOld1_nextNumFinal, updateOld1_proofData);
        vm.prank(prover);
        axiomMock.updateOld(updateOld2_nextRoot, updateOld2_nextNumFinal, updateOld2_proofData);

        vm.expectRevert(AxiomBlockVerificationFailed.selector);
        axiomMock.appendHistoricalPMMR(
            appendHistoricalPmmr_startBlockNumber,
            appendHistoricalPmmr_roots,
            appendHistoricalPmmr_prevHashes,
            appendHistoricalPmmr_lastNumFinal + 1
        );

        axiomMock.appendHistoricalPMMR(
            appendHistoricalPmmr_startBlockNumber,
            appendHistoricalPmmr_roots,
            appendHistoricalPmmr_prevHashes,
            appendHistoricalPmmr_lastNumFinal
        );
    }

    function _runBootstrap() internal {
        file = vm.readFile("test/data/core/mock/core_initial_updateRecent.json");
        proofData = abi.decode(vm.parseJson(file, ".proofData"), (bytes));

        vm.prank(prover);
        axiomMock.updateRecent(proofData);

        for (uint256 i = 0; i < 39; i++) {
            _updateHistorical(string.concat("test/data/core/mock/core_updateHistorical_", vm.toString(i), ".json"));
        }

        for (uint256 i = 0; i < 20; i++) {
            _appendHistoricalPmmr(
                string.concat("test/data/core/mock/core_appendHistoricalPmmr_", vm.toString(i), ".json")
            );
        }
    }
}
