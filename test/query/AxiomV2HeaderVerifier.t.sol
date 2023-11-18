// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {
    AxiomTestBase,
    BASE_FILE_PATH,
    TimelockAddressIsZero,
    GuardianAddressIsZero,
    UnfreezeAddressIsZero,
    AxiomQueryAddressIsZero,
    AxiomCoreAddressIsZero,
    ContractIsFrozen,
    ProofMmrKeccakDoesNotMatch
} from "../base/AxiomTestBase.sol";
import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { IAxiomV2HeaderVerifier } from "../../contracts/interfaces/query/IAxiomV2HeaderVerifier.sol";
import { AxiomV2HeaderVerifier } from "../../contracts/query/AxiomV2HeaderVerifier.sol";
import { GOERLI_CHAIN_ID } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";
import "../../contracts/libraries/PaddedMerkleMountainRange.sol";

error BlockhashMmrKeccakDoesNotMatchProof();
error MmrEndBlockNotRecent();
error ClaimedMmrDoesNotMatchRecent();
error BlockHashWitnessNotRecent();
error NoMoreRecentBlockhashPmmr();

contract AxiomV2HeaderVerifierTest is AxiomTestBase {
    event FreezeAll();
    event UnfreezeAll();
    event AxiomResultHashWritten(bytes32 queryHash, bytes32 resultHash);

    bytes32 public proofMmrKeccak;
    IAxiomV2HeaderVerifier.MmrWitness public mmrWitness;
    uint32 public forkBlockNumber;
    bytes32 public snapshotPmmrHash;

    function setUp() public { }

    function test_init_zeroAxiomCoreAddress_fail() public {
        AxiomV2HeaderVerifier impl = new AxiomV2HeaderVerifier(GOERLI_CHAIN_ID);
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", address(0), timelock, guardian, unfreeze
        );
        vm.expectRevert(AxiomCoreAddressIsZero.selector);
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
    }

    function test_init_zeroTimelock_fail() public {
        deployAxiomCore();
        AxiomV2HeaderVerifier impl = new AxiomV2HeaderVerifier(GOERLI_CHAIN_ID);
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", address(axiom), address(0), guardian, unfreeze
        );
        vm.expectRevert(TimelockAddressIsZero.selector);
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
    }

    function test_init_zeroGuardian_fail() public {
        deployAxiomCore();
        AxiomV2HeaderVerifier impl = new AxiomV2HeaderVerifier(GOERLI_CHAIN_ID);
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", address(axiom), timelock, address(0), unfreeze
        );
        vm.expectRevert(GuardianAddressIsZero.selector);
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
    }

    function test_init_zeroUnfreeze_fail() public {
        deployAxiomCore();
        AxiomV2HeaderVerifier impl = new AxiomV2HeaderVerifier(GOERLI_CHAIN_ID);
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", address(axiom), timelock, guardian, address(0)
        );
        vm.expectRevert(UnfreezeAddressIsZero.selector);
        AxiomProxy proxy = new AxiomProxy(address(impl), data);
    }

    function test_supportsInterface() public {
        deploy(GOERLI_CHAIN_ID);
        assert(axiomHeaderVerifier.supportsInterface(type(IAxiomV2HeaderVerifier).interfaceId));
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

    function test_verifyQueryHeadersProofBeforeSnapshot_1() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_1.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_1_proofMmrMismatch_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_1.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        mmrWitness.proofMmrPeaks[2] = bytes32(0xbf98020b06f95144932f804bb8df0290c762d56a83add2c76efb0ed8035818f6);

        vm.expectRevert(ProofMmrKeccakDoesNotMatch.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_1_completePmmrMismatch_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_1.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        mmrWitness.mmrComplementOrPeaks[4] = bytes32(0xbf98020b06f95144932f804bb8df0290c762d56a83add2c76efb0ed8035818f6);

        vm.expectRevert(BlockhashMmrKeccakDoesNotMatchProof.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_2() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_2.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_3() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_3.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_3_mmrEndBlockNotRecent_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_3.json");
        _forkAndDeploy("goerli", 9_700_200);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);

        vm.expectRevert(MmrEndBlockNotRecent.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_3_snapshotMismatch_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_3.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        mmrWitness.mmrComplementOrPeaks[6] = bytes32(0xbf98020b06f95144932f804bb8df0290c762d56a83add2c76efb0ed8035818f3);

        vm.expectRevert(BlockhashMmrKeccakDoesNotMatchProof.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_3_snapshotEndMismatch_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_3.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        mmrWitness.proofMmrPeaks[0] = bytes32(0xbf98020b06f95144932f804bb8df0290c762d56a83add2c76efb0ed8035818f3);
        proofMmrKeccak = keccak256(abi.encodePacked(mmrWitness.proofMmrPeaks));

        vm.expectRevert(ClaimedMmrDoesNotMatchRecent.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_3_tooOld_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_3.json");
        _forkAndDeploy("goerli", 9_802_200);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);

        vm.expectRevert(BlockHashWitnessNotRecent.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_4() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_4.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_5() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_5.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_6() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_6.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofBeforeSnapshot_7() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_7.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_8() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_8.json");
        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile("test/data/query/header_verify_8.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiom.setBlockhashPmmr(pmmr);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_8_2() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_8.json");
        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile("test/data/query/header_verify_8.json");
        _forkAndDeploy("goerli", 9_801_000);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiom.setBlockhashPmmr(pmmr);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_8_2_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_8.json");
        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile("test/data/query/header_verify_8.json");
        _forkAndDeploy("goerli", 9_801_000);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiom.setBlockhashPmmr(pmmr);
        mmrWitness.proofMmrPeaks[0] = bytes32(0xbf98020b06f95144932f804bb8df0290c762d56a83add2c76efb0ed8035818f3);
        proofMmrKeccak = keccak256(abi.encodePacked(mmrWitness.proofMmrPeaks));

        vm.expectRevert(ClaimedMmrDoesNotMatchRecent.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_8_3_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_8.json");
        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile("test/data/query/header_verify_8.json");
        _forkAndDeploy("goerli", 9_801_000);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiom.setBlockhashPmmr(pmmr);
        axiom.setBlockhashPmmrLeaf(bytes32(0xbf98020b06f95144932f804bb8df0290c762d56a83add2c76efb0ed8035818f3));

        vm.expectRevert(ClaimedMmrDoesNotMatchRecent.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function test_verifyQueryHeadersProofAfterSnapshot_9_fail() public {
        _loadHeaderVerifierWitnesses("test/data/query/header_verify_9.json");
        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile("test/data/query/header_verify_8.json");
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiom.setBlockhashPmmr(pmmr);

        vm.expectRevert(NoMoreRecentBlockhashPmmr.selector);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    function _verifyQueryHeadersPass(string memory filename) internal {
        _loadHeaderVerifierWitnesses(filename);
        PaddedMerkleMountainRange.PMMR memory pmmr = _readBlockhashPmmrFromFile(filename);
        _forkAndDeploy("goerli", forkBlockNumber);
        axiom.setPmmrSnapshot(mmrWitness.snapshotPmmrSize, snapshotPmmrHash);
        axiom.setBlockhashPmmr(pmmr);
        axiomHeaderVerifier.verifyQueryHeaders(proofMmrKeccak, mmrWitness);
    }

    // format of the filename: header_verifier_{test_case}_{proofMmrSize}_{snapshotPmmrSize}_{blockhashPmmrSize}_{forkBlockNumber}.json

    // 1: proofMmrSize == snapshotPmmrSize, proofMmrSize % 1024 != 0
    function test_verifyQueryHeaders_1() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_1_9799700_9799700_9800180_9800581.json");
    }

    // 2: proofMmrSize == snapshotPmmrSize, proofMmrSize % 1024 == 0
    function test_verifyQueryHeaders_2() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_2_9799680_9799680_9800180_9800581.json");
    }

    // 3: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 == snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0
    function test_verifyQueryHeaders_3() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_3_9799700_9799783_9800180_9800581.json");
    }

    // 4: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 == snapshotPmmrSize / 1024, proofMmrSize % 1024 == 0
    function test_verifyQueryHeaders_4() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_4_9799680_9799783_9800180_9800581.json");
    }

    // 5: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 = snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0, snapshotPmmrSize % 1024 != 0
    function test_verifyQueryHeaders_5() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_5_9799660_9799783_9800180_9800581.json");
    }

    // 6: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 = snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0, snapshotPmmrSize % 1024 == 0
    function test_verifyQueryHeaders_6() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_6_9799660_9799680_9800180_9800581.json");
    }

    // 7: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 = snapshotPmmrSize / 1024, proofMmrSize % 1024 == 0, snapshotPmmrSize % 1024 != 0
    function test_verifyQueryHeaders_7() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_7_9798656_9799783_9800180_9800581.json");
    }

    // 8: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 = snapshotPmmrSize / 1024, proofMmrSize % 1024 == 0, snapshotPmmrSize % 1024 == 0
    function test_verifyQueryHeaders_8() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_8_9798656_9799680_9800180_9800581.json");
    }

    // 9: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 < snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0, snapshotPmmrSize % 1024 != 0
    function test_verifyQueryHeaders_9() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_9_9798636_9799783_9800180_9800581.json");
    }

    // 10: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 < snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0, snapshotPmmrSize % 1024 == 0
    function test_verifyQueryHeaders_10() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_10_9798636_9799680_9800180_9800581.json");
    }

    // 11: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 < snapshotPmmrSize / 1024, proofMmrSize % 1024 == 0, snapshotPmmrSize % 1024 != 0
    function test_verifyQueryHeaders_11() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_11_9797632_9799783_9800180_9800581.json");
    }

    // 12: proofMmrSize < snapshotPmmrSize, proofMmrSize / 1024 + 1 < snapshotPmmrSize / 1024, proofMmrSize % 1024 == 0, snapshotPmmrSize % 1024 == 0
    function test_verifyQueryHeaders_12() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_12_9797632_9799680_9800180_9800581.json");
    }

    // for the following cases 13-16, we assume that:
    // proofMmrSize > snapshotPmmrSize, snapshotPmmrSize >= block.number - 256, proofMmrSize > corePmmrSize

    // 13: proofMmrSize / 1024 == snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0, snapshotPmmrSize % 1024 != 0
    function test_verifyQueryHeaders_13() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_13_9799783_9799700_9798779_9799900.json");
    }

    // 14: proofMmrSize / 1024 == snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0, snapshotPmmrSize % 1024 == 0
    function test_verifyQueryHeaders_14() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_14_9799783_9799680_9798779_9799900.json");
    }

    // 15: proofMmrSize / 1024 > snapshotPmmrSize / 1024, proofMmrSize % 1024 != 0, snapshotPmmrSize % 1024 != 0
    function test_verifyQueryHeaders_15() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_15_9799783_9799660_9798779_9799900.json");
    }

    // 16: proofMmrSize / 1024 > snapshotPmmrSize / 1024, proofMmrSize % 1024 == 0, snapshotPmmrSize % 1024 != 0
    function test_verifyQueryHeaders_16() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_16_9799680_9799660_9798779_9799900.json");
    }

    // for the following cases 17-22, we assume that:
    // proofMmrSize <= corePmmrSize, snapshotPmmrSize < block.number - 256, proofMmrSize >= block.number - 256

    // 17: proofMmrSize == corePmmrSize, proofMmrSize % 1024 != 0
    function test_verifyQueryHeaders_17() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_17_9799700_9798656_9799700_9799783.json");
    }

    // 18: proofMmrSize == corePmmrSize, proofMmrSize % 1024 == 0
    function test_verifyQueryHeaders_18() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_18_9799680_9798656_9799680_9799783.json");
    }

    // 19: proofMmrSize < corePmmrSize, proofMmrSize / 1024 == corePmmrSize / 1024, corePmmrSize % 1024 != 0, proofMmrSize % 1024 != 0
    function test_verifyQueryHeaders_19() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_19_9799700_9798656_9799783_9799900.json");
    }

    // 20: proofMmrSize < corePmmrSize, proofMmrSize / 1024 == corePmmrSize / 1024, corePmmrSize % 1024 != 0, proofMmrSize % 1024 == 0
    function test_verifyQueryHeaders_20() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_20_9799680_9798656_9799783_9799900.json");
    }

    // 21: proofMmrSize < corePmmrSize, proofMmrSize / 1024 < corePmmrSize / 1024, corePmmrSize % 1024 != 0, proofMmrSize % 1024 != 0
    function test_verifyQueryHeaders_21() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_21_9799660_9798656_9799783_9799900.json");
    }

    // 22: proofMmrSize < corePmmrSize, proofMmrSize / 1024 < corePmmrSize / 1024, corePmmrSize % 1024 == 0, proofMmrSize % 1024 != 0
    function test_verifyQueryHeaders_22() public {
        _verifyQueryHeadersPass("test/data/query/header_verifier_22_9799660_9798656_9799680_9799900.json");
    }
}
