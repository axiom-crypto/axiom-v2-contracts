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
import { AxiomResultStore } from "../../contracts/query/AxiomResultStore.sol";
import { AxiomV2HeaderVerifier } from "../../contracts/query/AxiomV2HeaderVerifier.sol";
import { AxiomV2Core } from "../../contracts/core/AxiomV2Core.sol";
import { AxiomV2CoreMock } from "../../contracts/mock/AxiomV2CoreMock.sol";
import { AxiomV2Prover } from "../../contracts/query/AxiomV2Prover.sol";
import { AxiomV2Query } from "../../contracts/query/AxiomV2Query.sol";
import { ExampleV2Client } from "../../contracts/client/ExampleV2Client.sol";
import { MerkleMountainRange } from "../../contracts/libraries/MerkleMountainRange.sol";
import { PaddedMerkleMountainRange } from "../../contracts/libraries/PaddedMerkleMountainRange.sol";
import { GOERLI_CHAIN_ID, MAINNET_CHAIN_ID } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";

import { YulDeployer } from "../../lib/YulDeployer.sol";
import { AxiomV2QueryVerifier } from "../../snark-verifiers/query/AxiomV2QueryVerifier.v0.9.sol";

string constant BASE_FILE_PATH = "test/data/query/base-v0.9.json";

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
error OnlyAxiomV2ProverCanFulfillQuery();

error PayeeAddressIsZero();
error PayorAddressIsZero();

struct AxiomTestSendInputs {
    bytes32 dataQueryHash;
    IAxiomV2Query.AxiomV2ComputeQuery computeQuery;
    IAxiomV2Query.AxiomV2Callback callback;
    bytes32 userSalt;
    uint64 maxFeePerGas;
    uint32 callbackGasLimit;
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
    bytes32 snapshotPmmrHash;
    bool isOffchain;
    address caller;
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
    YulDeployer public yulDeployer;
    address public axiomVerifierAddress;
    address public axiomHistoricalVerifierAddress;

    // Deployed verifier for AxiomV2Query
    AxiomV2QueryVerifier public verifier;

    // AxiomV2Core and AxiomV2Query contracts
    AxiomV2CoreCheat public axiom;
    AxiomV2CoreMockCheat public axiomMock;
    AxiomV2HeaderVerifier public axiomHeaderVerifier;
    AxiomV2Prover public axiomProver;
    AxiomResultStore public axiomResultStore;
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
        create3 = new CREATE3Factory();

        prover = address(1);
        timelock = address(2);
        guardian = address(3);
        unfreeze = address(4);
        caller = address(5);
        refund = address(6);
        query = address(9);

        yulDeployer = new YulDeployer();
        axiomVerifierAddress = address(yulDeployer.deployContract("core/mainnet_10_7.v1"));
        axiomHistoricalVerifierAddress = address(yulDeployer.deployContract("core/mainnet_17_7.v1"));

        vm.makePersistent(axiomVerifierAddress);
        vm.makePersistent(axiomHistoricalVerifierAddress);
        vm.makePersistent(address(create3));
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
        AxiomV2HeaderVerifier impl = new AxiomV2HeaderVerifier(sourceChainId);
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", address(axiom), timelock, guardian, unfreeze
        );
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
        axiomHeaderVerifier = AxiomV2HeaderVerifier(payable(address(proxy)));
        vm.makePersistent(address(axiomHeaderVerifier));
    }

    function deployAxiomProver(address axQuery) public {
        AxiomV2Prover impl = new AxiomV2Prover();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address)", axQuery, prover, timelock, guardian, unfreeze
        );
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
        axiomProver = AxiomV2Prover(payable(address(proxy)));
        vm.makePersistent(address(axiomProver));
    }

    function deployResultStore(address axQuery) public {
        AxiomResultStore impl = new AxiomResultStore();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", axQuery, timelock, guardian, unfreeze
        );
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
        axiomResultStore = AxiomResultStore(payable(address(proxy)));
        vm.makePersistent(address(axiomResultStore));
    }

    function deployAxiomVerifier() public {
        verifier = new AxiomV2QueryVerifier();
        vm.makePersistent(address(verifier));
    }

    function deployQuery() public {
        aggregateVkeyHashes = new bytes32[](2);
        // config 1
        aggregateVkeyHashes[0] = bytes32(0x0088c85dd433925fd2c5f083fc523be447fa7c5046a93425f0ef3df3523768f5);
        // config 2
        aggregateVkeyHashes[1] = bytes32(0x1b46de31e41b181c8f38639a52ee6af6936f2cf067d628fda6ee768f217f565a);

        queryDeadlineInterval = 7200;
        proofVerificationGas = 500_000;
        axiomQueryFee = 0.003 ether;
        minMaxFeePerGas = 5 gwei;
        maxQueryDeadlineInterval = 50_400;

        init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: address(axiomHeaderVerifier),
            verifierAddress: address(verifier),
            axiomProverAddress: address(axiomProver),
            axiomResultStoreAddress: address(axiomResultStore),
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
            "initialize((address,address,address,address,bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
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
        client = new ExampleV2Client(
            address(axiomQuery),
            sourceChainId
        );
        vm.makePersistent(address(client));
    }

    function deploy(uint64 sourceChainId) public {
        address axQuery = create3.getDeployed(address(this), SALT);
        deployAxiomCore();
        deployAxiomCoreMock();
        deployAxiomHeaderVerifier(sourceChainId);
        deployAxiomProver(axQuery);
        deployResultStore(axQuery);
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
        } else {
            revert("Network is not supported.");
        }
        deploy(sourceChainId);
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
        sendInputs.userSalt = abi.decode(vm.parseJson(file, ".send.userSalt"), (bytes32));
        sendInputs.maxFeePerGas = abi.decode(vm.parseJson(file, ".send.maxFeePerGas"), (uint64));
        sendInputs.callbackGasLimit = abi.decode(vm.parseJson(file, ".send.callbackGasLimit"), (uint32));
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
                        sourceChainId,
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
                        sourceChainId,
                        address(prover),
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
        fulfillInputs.snapshotPmmrHash = abi.decode(vm.parseJson(file, ".fulfill.snapshotPmmrHash"), (bytes32));
        if (!isOffchainFulfill) {
            fulfillInputs.caller = address(caller);
        } else {
            fulfillInputs.caller = address(0);
        }
        fulfillInputs.isOffchain = isOffchainFulfill;

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

        axiomMock.appendHistoricalPMMR(startBlockNumber, rootsJson, prevHashes, 1024);
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
        file = vm.readFile("test/data/core/core_initial_updateRecent.json");
        proofData = abi.decode(vm.parseJson(file, ".proofData"), (bytes));

        vm.prank(prover);
        axiomMock.updateRecent(proofData);

        for (uint256 i = 0; i < 77; i++) {
            _updateHistorical(string.concat("test/data/core/core_updateHistorical_", vm.toString(i), ".json"));
        }

        for (uint256 i = 0; i < 38; i++) {
            _appendHistoricalPmmr(string.concat("test/data/core/core_appendHistoricalPmmr_", vm.toString(i), ".json"));
        }
    }
}
