// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import { IAxiomV2HeaderVerifier } from "../../contracts/interfaces/query/IAxiomV2HeaderVerifier.sol";
import { PaddedMerkleMountainRange } from "../../contracts/libraries/PaddedMerkleMountainRange.sol";

import {
    AxiomTestBase, AxiomTestSendInputs, AxiomTestMetadata, AxiomTestFulfillInputs
} from "../base/AxiomTestBase.sol";

contract AxiomV2HeaderVerifierGas15Test is AxiomTestBase {
    using PaddedMerkleMountainRange for PaddedMerkleMountainRange.PMMR;

    AxiomTestSendInputs public sendInputs;
    AxiomTestMetadata public metadata;
    AxiomTestFulfillInputs public fulfillInputs;
    uint32 public forkBlockNumber;
    uint64 public sourceChainId;
    uint256 public maxQueryPri;

    bytes32 public proofMmrKeccak;
    IAxiomV2HeaderVerifier.MmrWitness public mmrWitness;

    bytes32 public snapshotPmmrHash;

    function setUp() public {
        (
            AxiomTestSendInputs memory _sendInputs,
            AxiomTestMetadata memory _metadata,
            AxiomTestFulfillInputs memory _fulfillInputs,
            uint32 _forkBlockNumber,
            uint64 _sourceChainId
        ) = _readFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        sendInputs = _sendInputs;
        metadata = _metadata;
        fulfillInputs = _fulfillInputs;
        forkBlockNumber = _forkBlockNumber;
        sourceChainId = _sourceChainId;

        string memory filename = "test/data/query/mock/header_verifier_15_3799143_3799020_3798139_3799260.json";
        _loadHeaderVerifierWitnesses(filename);
        _forkAndDeploy("sepolia", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);

        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile(filename);
        axiom.setBlockhashPmmr(pmmr);
        axiom.setPmmrSnapshot(pmmr.size, pmmr.commit());
    }

    function _loadHeaderVerifierWitnesses(string memory filename) internal {
        (
            bytes32 _proofMmrKeccak,
            IAxiomV2HeaderVerifier.MmrWitness memory _mmrWitness,
            uint32 _forkBlockNumber,
            bytes32 _snapshotPmmrHash
        ) = _readHeaderVerifierWitnessFromFile(filename);
        proofMmrKeccak = _proofMmrKeccak;
        mmrWitness = _mmrWitness;
        forkBlockNumber = _forkBlockNumber;
        snapshotPmmrHash = _snapshotPmmrHash;
    }

    function test_gas_headerVerify15() public {
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }
}
