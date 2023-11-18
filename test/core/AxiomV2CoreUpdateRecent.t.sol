// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import { MerkleMountainRange } from "../../contracts/libraries/MerkleMountainRange.sol";
import { PaddedMerkleMountainRange } from "../../contracts/libraries/PaddedMerkleMountainRange.sol";
import { IAxiomV2Verifier } from "../../contracts/interfaces/core/IAxiomV2Verifier.sol";

import {
    AxiomTestBase,
    AxiomTestSendInputs,
    AxiomTestMetadata,
    AxiomTestFulfillInputs,
    AxiomV2CoreCheat,
    BASE_FILE_PATH,
    NotProverRole,
    ContractIsFrozen,
    SNARKVerificationFailed,
    AxiomBlockVerificationFailed,
    IncorrectNumberOfBlocks,
    StartingBlockNotValid,
    NotRecentEndBlock,
    BlockHashIncorrect,
    MerkleProofFailed
} from "../base/AxiomTestBase.sol";

contract AxiomV2CoreUpdateRecent is AxiomTestBase {
    using PaddedMerkleMountainRange for PaddedMerkleMountainRange.PMMR;

    uint256 mainnetForkId1;
    uint256 mainnetForkId2;
    uint256 mainnetForkId3;
    uint256 mainnetForkId4;

    event FreezeAll();
    event UnfreezeAll();

    event HistoricalRootUpdated(uint32 indexed startBlockNumber, bytes32 prevHash, bytes32 root, uint32 numFinal);
    event PaddedMerkleMountainRangeUpdated(bytes32 commitment, uint32 pmmrSize);

    function setUp() public {
        mainnetForkId1 = vm.createFork("mainnet", 16_356_351 + 199);
        mainnetForkId2 = vm.createFork("mainnet", 16_355_455 + 7);
        mainnetForkId3 = vm.createFork("mainnet", 16_356_351 + 300);
        mainnetForkId4 = vm.createFork("mainnet", 16_356_351 - 10);
    }

    function test_updateRecent_1024() public {
        _forkAndDeploy("mainnet", 16_356_351 + 199);

        require(block.number - 256 <= 0xf993ff && 0xf993ff < block.number, "try a different block number");
        // Valid SNARK for blocks in `[0xf99000, 0xf993ff]`
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);

        vm.prank(prover);
        axiom.updateRecent(proofData);
        PaddedMerkleMountainRange.PMMR memory pmmr = axiom.fullBlockhashPmmr();
        assert(pmmr.completeLeaves.peaksLength == 0);
        assert(pmmr.size == 0);
        assert(pmmr.paddedLeaf == bytes32(0x0));
    }

    function test_updateRecent_1024_mmrUpdate() public {
        _forkAndDeploy("mainnet", 16_356_351 + 199);

        axiom.setBlockhashPmmrLen(0xf99000);
        require(block.number - 256 <= 0xf993ff && 0xf993ff < block.number, "try a different block number");
        // Valid SNARK for blocks in `[0xf99000, 0xf993ff]`
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);

        vm.prank(prover);
        vm.expectEmit();
        emit HistoricalRootUpdated(
            0xf99000,
            0x1ad14c91097b536665fe63885be0e7437f286236695557a94a8ca39758a5ea13,
            0x15bf3ddb2f8030fc6efeb51cf6cad5cf034bc6bc1a610b1d6f575911d0ada0bd,
            1024
        );
        // forge can't handle several events
        // vm.expectEmit();
        // emit PaddedMerkleMountainRangeUpdated(0x7f5ca28257443fa02fe96bf7c794914c789a25b4d8c539ad68dad94571cfadc6, 0xf993ff);
        axiom.updateRecent(proofData);

        MerkleMountainRange.MMR memory mmr = axiom.blockhashPmmrPeaks();
        assert(axiom.blockhashPmmrLeaf() == bytes32(0));
        assert(mmr.peaks[0] == 0x15bf3ddb2f8030fc6efeb51cf6cad5cf034bc6bc1a610b1d6f575911d0ada0bd);
        assert(axiom.blockhashPmmrSize() == 0xf99400);

        PaddedMerkleMountainRange.PMMR memory pmmr = axiom.fullBlockhashPmmr();
        assert(pmmr.paddedLeaf == bytes32(0));
        assert(pmmr.completeLeaves.peaksLength == 1);
        assert(pmmr.size == 0xf99400);
    }

    function test_updateRecent_128() public {
        _forkAndDeploy("mainnet", 16_355_455 + 7);

        require(block.number - 256 <= 0xf9907f && 0xf9907f < block.number, "try a different block number");
        // Valid SNARK for blocks in `[0xf99000, 0xf993ff]`
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f9907f.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);

        vm.prank(prover);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_1024_proof_fail() public {
        _forkAndDeploy("mainnet", 16_356_351 + 199);

        require(block.number - 256 <= 0xf993ff && 0xf993ff < block.number, "try a different block number");
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The first 32 bytes of the proof represent a field element that should be at most 88 bits (11 bytes).
        // The first 21 bytes are 0s.
        // We prank the 22nd byte to be 0x53
        require(proofData[21] != bytes1(0x53), "choose a different random byte");
        proofData[21] = bytes1(0x53);
        // This is now an invalid SNARK for blocks in `[0xf99000, 0xf993ff]`

        vm.prank(prover);
        vm.expectRevert(SNARKVerificationFailed.selector);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_1024_proof_malformed_uint256() public {
        _forkAndDeploy("mainnet", 16_356_351 + 199);

        require(block.number - 256 <= 0xf993ff && 0xf993ff < block.number, "try a different block number");
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The first 32 bytes of the proof represent a field element that should be at most 88 bits (11 bytes).
        // The first 21 bytes are 0s.
        // We prank the 5th byte to 0x10
        proofData[4] = bytes1(0x10);
        // This is now an invalid SNARK for blocks in `[0xf99000, 0xf993ff]` with malformed uint256

        vm.prank(prover);
        vm.expectRevert(SNARKVerificationFailed.selector);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_1024_numFinal_fail() public {
        _forkAndDeploy("mainnet", 16_356_351 + 199);

        require(block.number - 256 <= 0xf993ff && 0xf993ff < block.number, "try a different block number");
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The endBlockNumber is in bytes 540:544 (see getBoundaryBlockData in AxiomV2Configuration.sol)
        // The endBlockNumber should be 0x00f993ff; we prank it to 0x00f99400
        proofData[542] = bytes1(0x94);
        proofData[543] = bytes1(0x00);
        // This is now an invalid SNARK for blocks in `[0xf99000, 0xf993ff]` with `numFinal` modified

        vm.prank(prover);
        vm.expectRevert(IncorrectNumberOfBlocks.selector);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_1024_startBlockNumber_fail() public {
        _forkAndDeploy("mainnet", 16_356_351 + 199);

        require(block.number - 256 <= 0xf993ff && 0xf993ff < block.number, "try a different block number");
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The startBlockNumber is in bytes 536:540 (see getBoundaryBlockData in AxiomV2Configuration.sol)
        // The startBlockNumber should be 0x00f99000; we prank it to 0x00f99001
        proofData[539] = bytes1(0x01);
        // This is now an invalid SNARK for blocks in `[0xf99000, 0xf993ff]` with `startBlockNumber` modified

        vm.prank(prover);
        vm.expectRevert(StartingBlockNotValid.selector);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_1024_notRecentEndBlock_fail() public {
        _forkAndDeploy("mainnet", 16_356_351 + 300);

        // Valid SNARK for blocks in `[0xf99000, 0xf993ff]`
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);

        vm.prank(prover);
        vm.expectRevert(NotRecentEndBlock.selector);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_1024_notRecentEndBlock2_fail() public {
        _forkAndDeploy("mainnet", 16_356_351 - 10);

        // Valid SNARK for blocks in `[0xf99000, 0xf993ff]`
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);

        vm.prank(prover);
        vm.expectRevert(NotRecentEndBlock.selector);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_1024_endhash_fail() public {
        _forkAndDeploy("mainnet", 16_356_351 + 199);

        require(block.number - 256 <= 0xf993ff && 0xf993ff < block.number, "try a different block number");
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The endHash (bytes32) is split as two uint128 words in bytes 448+16:480 and 480+16:512 (see getBoundaryBlockData in AxiomV2Configuration.sol)
        // We prank the 512th byte to 0x0e (from 0x0d)
        proofData[511] = bytes1(0x0e);
        // This is now an invalid SNARK for blocks in `[0xf99000, 0xf993ff]` with `endHash` modified

        vm.prank(prover);
        vm.expectRevert(BlockHashIncorrect.selector);
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_128_notProver_fail() public {
        _forkAndDeploy("mainnet", 16_355_455 + 7);

        require(block.number - 256 <= 0xf9907f && 0xf9907f < block.number, "try a different block number");
        // Valid SNARK for blocks in `[0xf99000, 0xf9907f]`
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f9907f.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);

        vm.prank(WRONG_ADDRESS); // not sender = prover
        vm.expectRevert(NotProverRole.selector); // NotProver
        axiom.updateRecent(proofData);
    }

    function test_updateRecent_128_freezeUnfreeze() public {
        _forkAndDeploy("mainnet", 16_355_455 + 7);

        require(block.number - 256 <= 0xf9907f && 0xf9907f < block.number, "try a different block number");
        // Valid SNARK for blocks in `[0xf99000, 0xf9907f]`
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f9907f.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);

        vm.prank(guardian);
        vm.expectEmit();
        emit FreezeAll();
        axiom.freezeAll();

        vm.prank(prover);
        vm.expectRevert(ContractIsFrozen.selector); // ContractIsFrozen
        axiom.updateRecent(proofData);

        vm.prank(unfreeze);
        vm.expectEmit();
        emit UnfreezeAll();
        axiom.unfreezeAll();

        vm.prank(prover);
        axiom.updateRecent(proofData);
    }

    function test_isBlockHashValid() public {
        uint32 start = 0xf99000;
        uint32 end = 0xf9907f;
        test_updateRecent_128();
        require(start > block.number - 256, "start number is not recent");
        require(end < block.number, "end number in not recent");
        bytes32 prevHash = blockhash(start - 1);

        bytes32[][] memory merkleRoots = new bytes32[][](11);
        merkleRoots[0] = new bytes32[](1024);

        for (uint256 i = 0; i < 1024; i++) {
            if (i <= end - start) {
                merkleRoots[0][i] = blockhash(start + i);
            } else {
                merkleRoots[0][i] = bytes32(0);
            }
        }
        for (uint256 depth = 0; depth < 10; depth++) {
            merkleRoots[depth + 1] = new bytes32[](2 ** (10 - depth - 1));
            for (uint256 i = 0; i < 2 ** (10 - depth - 1); i++) {
                merkleRoots[depth + 1][i] =
                    keccak256(abi.encodePacked(merkleRoots[depth][2 * i], merkleRoots[depth][2 * i + 1]));
            }
        }

        bytes32[] memory merkleProof = new bytes32[](10);
        for (uint32 side = 0; side < 128; side++) {
            bytes32 blockHash = blockhash(start + side);
            for (uint256 depth = 0; depth < 10; depth++) {
                merkleProof[depth] = merkleRoots[depth][(side >> depth) ^ 1];
            }
            assert(
                axiom.isBlockHashValid(
                    IAxiomV2Verifier.BlockHashWitness(start + side, blockHash, prevHash, end - start + 1, merkleProof)
                )
            );
        }
    }

    function test_isBlockHashValid_notStored_fail() public {
        uint32 start = 0xf99000;
        uint32 end = 0xf9907f;

        _forkAndDeploy("mainnet", 16_355_455 + 7);

        require(start > block.number - 256, "start number is not recent");
        require(end < block.number, "end number in not recent");
        bytes32 prevHash = blockhash(start - 1);
        bytes32[][] memory merkleRoots = new bytes32[][](11);
        merkleRoots[0] = new bytes32[](1024);

        for (uint256 i = 0; i < 1024; i++) {
            if (i <= end - start) {
                merkleRoots[0][i] = blockhash(start + i);
            } else {
                merkleRoots[0][i] = bytes32(0);
            }
        }
        for (uint256 depth = 0; depth < 10; depth++) {
            merkleRoots[depth + 1] = new bytes32[](2 ** (10 - depth - 1));
            for (uint256 i = 0; i < 2 ** (10 - depth - 1); i++) {
                merkleRoots[depth + 1][i] =
                    keccak256(abi.encodePacked(merkleRoots[depth][2 * i], merkleRoots[depth][2 * i + 1]));
            }
        }

        bytes32[] memory merkleProof = new bytes32[](10);
        bytes32 blockHash = blockhash(start);
        for (uint256 depth = 0; depth < 10; depth++) {
            merkleProof[depth] = merkleRoots[depth][0];
        }

        vm.expectRevert(MerkleProofFailed.selector);
        axiom.isBlockHashValid(
            IAxiomV2Verifier.BlockHashWitness(start, blockHash, prevHash, end - start + 1, merkleProof)
        );
    }

    function test_isBlockHashValid_zeroBlockHash_fail() public {
        uint32 start = 0xf99000;
        uint32 end = 0xf9907f;
        test_updateRecent_128();
        require(start > block.number - 256, "start number is not recent");
        require(end < block.number, "end number in not recent");

        bytes32 prevHash = blockhash(start - 1);
        bytes32[][] memory merkleRoots = new bytes32[][](11);
        merkleRoots[0] = new bytes32[](1024);

        for (uint256 i = 0; i < 1024; i++) {
            if (i <= end - start) {
                merkleRoots[0][i] = blockhash(start + i);
            } else {
                merkleRoots[0][i] = bytes32(0);
            }
        }
        for (uint256 depth = 0; depth < 10; depth++) {
            merkleRoots[depth + 1] = new bytes32[](2 ** (10 - depth - 1));
            for (uint256 i = 0; i < 2 ** (10 - depth - 1); i++) {
                merkleRoots[depth + 1][i] =
                    keccak256(abi.encodePacked(merkleRoots[depth][2 * i], merkleRoots[depth][2 * i + 1]));
            }
        }

        bytes32[] memory merkleProof = new bytes32[](10);
        for (uint256 depth; depth < 10; depth++) {
            merkleProof[depth] = merkleRoots[depth][(1 >> depth) ^ 1];
        }

        vm.expectRevert(BlockHashIncorrect.selector);
        axiom.isBlockHashValid(
            IAxiomV2Verifier.BlockHashWitness(start + 1, 0x0, prevHash, end - start + 1, merkleProof)
        );
    }
}
