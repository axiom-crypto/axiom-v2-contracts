// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { AxiomV2Core } from "../../contracts/core/AxiomV2Core.sol";
import { IAxiomV2Core } from "../../contracts/interfaces/core/IAxiomV2Core.sol";
import { MerkleTree } from "../../contracts/libraries/MerkleTree.sol";

import {
    AxiomTestBase,
    BASE_FILE_PATH,
    NotProverRole,
    ContractIsFrozen,
    SNARKVerificationFailed,
    AxiomBlockVerificationFailed,
    IncorrectNumberOfBlocks,
    StartingBlockNotValid,
    NotRecentEndBlock,
    BlockHashIncorrect,
    MerkleProofFailed,
    TimelockAddressIsZero,
    GuardianAddressIsZero,
    UnfreezeAddressIsZero,
    ProverAddressIsZero,
    VerifierAddressIsZero,
    HistoricalVerifierAddressIsZero
} from "../base/AxiomTestBase.sol";

contract AxiomV2CoreTest is AxiomTestBase {
    event FreezeAll();
    event UnfreezeAll();

    function setUp() public virtual {
        deployAxiomCore();
    }

    function test_init_zeroVerifier_fail() public {
        AxiomV2Core implementation = new AxiomV2Core();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            address(0),
            axiomHistoricalVerifierAddress,
            timelock,
            guardian,
            unfreeze,
            prover
        );
        vm.expectRevert(VerifierAddressIsZero.selector);
        new AxiomProxy(address(implementation), data);
    }

    function test_init_zeroHistoricalVerifier_fail() public {
        AxiomV2Core implementation = new AxiomV2Core();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            axiomVerifierAddress,
            address(0),
            timelock,
            guardian,
            unfreeze,
            prover
        );
        vm.expectRevert(HistoricalVerifierAddressIsZero.selector);
        new AxiomProxy(address(implementation), data);
    }

    function test_init_zeroTimelock_fail() public {
        AxiomV2Core implementation = new AxiomV2Core();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            axiomVerifierAddress,
            axiomHistoricalVerifierAddress,
            address(0),
            guardian,
            unfreeze,
            prover
        );
        vm.expectRevert(TimelockAddressIsZero.selector);
        new AxiomProxy(address(implementation), data);
    }

    function test_init_zeroGuardian_fail() public {
        AxiomV2Core implementation = new AxiomV2Core();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            axiomVerifierAddress,
            axiomHistoricalVerifierAddress,
            timelock,
            address(0),
            unfreeze,
            prover
        );
        vm.expectRevert(GuardianAddressIsZero.selector);
        new AxiomProxy(address(implementation), data);
    }

    function test_init_zeroUnfreeze_fail() public {
        AxiomV2Core implementation = new AxiomV2Core();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            axiomVerifierAddress,
            axiomHistoricalVerifierAddress,
            timelock,
            guardian,
            address(0),
            prover
        );
        vm.expectRevert(UnfreezeAddressIsZero.selector);
        new AxiomProxy(address(implementation), data);
    }

    function test_init_zeroProver_fail() public {
        AxiomV2Core implementation = new AxiomV2Core();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            axiomVerifierAddress,
            axiomHistoricalVerifierAddress,
            timelock,
            guardian,
            unfreeze,
            address(0)
        );
        vm.expectRevert(ProverAddressIsZero.selector);
        new AxiomProxy(address(implementation), data);
    }

    function test_guardianFreeze() public {
        vm.prank(WRONG_ADDRESS); // any address not guardian
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0x55435dd261a4b9b3364963f7738a7a662ad9c84396d64be3365284bb7f0a5041"
        );
        axiom.freezeAll();
        assertFalse(axiom.frozen());

        vm.prank(guardian); // guardian
        vm.expectEmit();
        emit FreezeAll();

        axiom.freezeAll();
        assertTrue(axiom.frozen());

        vm.prank(WRONG_ADDRESS); // any address not unfreeze
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf4e710c64967f31ba1090db2a7dd9e704155d00947ce853da47446cb68ee65da"
        );
        axiom.unfreezeAll();
        assertTrue(axiom.frozen());

        vm.prank(unfreeze); // unfreeze
        vm.expectEmit();
        emit UnfreezeAll();

        axiom.unfreezeAll();
        assertFalse(axiom.frozen());
    }

    function test_upgradeSnarkVerifier() public {
        vm.prank(timelock);
        axiom.upgradeSnarkVerifier(NEW_ADDRESS);

        assertEq(address(axiom.verifierAddress()), NEW_ADDRESS);
    }

    function test_upgradeSnarkVerifier_fail() public {
        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        ); // "Not timelock"

        axiom.upgradeSnarkVerifier(NEW_ADDRESS);
    }

    function test_upgradeSnarkVerifier_zeroAddress_fail() public {
        vm.prank(timelock);
        vm.expectRevert(VerifierAddressIsZero.selector);
        axiom.upgradeSnarkVerifier(address(0));
    }

    function test_upgradeHistoricalSnarkVerifier() public {
        vm.prank(timelock);
        axiom.upgradeHistoricalSnarkVerifier(NEW_ADDRESS);

        assertEq(address(axiom.historicalVerifierAddress()), NEW_ADDRESS);
    }

    function test_upgradeHistoricalSnarkVerifier_fail() public {
        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf66846415d2bf9eabda9e84793ff9c0ea96d87f50fc41e66aa16469c6a442f05"
        ); // "Not timelock"

        axiom.upgradeHistoricalSnarkVerifier(NEW_ADDRESS);
    }

    function test_upgradeHistoricalSnarkVerifier_zeroAddress_fail() public {
        vm.prank(timelock);
        vm.expectRevert(HistoricalVerifierAddressIsZero.selector);
        axiom.upgradeHistoricalSnarkVerifier(address(0));
    }

    function test_updateOld() public {
        vm.pauseGasMetering();
        // Valid SNARK proof of the chain of block headers between blocks in range `[0xf99000, 0x993ff]`.
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);
        axiom.setHistoricalRoot(
            16_356_352,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"87445763da0b6836b89b8189c4fe71861987aa9af5a715bfb222a7978d98630d"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        vm.resumeGasMetering();
        vm.prank(prover);

        axiom.updateOld(bytes32(hex"00"), uint32(0), proofData);
    }

    function test_updateOld_blockhash_fail() public {
        vm.pauseGasMetering();
        // Valid SNARK proof of the chain of block headers between blocks in range `[0xf99000, 0x993ff]`.
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);
        axiom.setHistoricalRoot(
            16_356_352,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"87445763da0b6836b89b8189c4fe71861987aa9af5a715bfb222a7978d98630d"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(BlockHashIncorrect.selector);
        axiom.updateOld(bytes32(hex"00"), uint32(1), proofData);
    }

    function test_updateOld_proof_fail() public {
        vm.pauseGasMetering();
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The first 32 bytes of the proof represent a field element that should be at most 88 bits (11 bytes).
        // The first 21 bytes are 0s.
        // We prank the 22nd byte to 0x53
        proofData[21] = bytes1(0x53);
        // This is now an invalid proof modified from a valid proof of the chain of block headers between blocks in range `[0xf99000, 0x993ff]`.
        axiom.setHistoricalRoot(
            16_356_352,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"87445763da0b6836b89b8189c4fe71861987aa9af5a715bfb222a7978d98630d"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(SNARKVerificationFailed.selector);
        axiom.updateOld(bytes32(hex"00"), uint32(0), proofData);
    }

    function test_updateOld_startBlockNumber_fail() public {
        vm.pauseGasMetering();
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The startBlockNumber is in bytes 536:540 (see getBoundaryBlockData in AxiomV2Configuration.sol)
        // The startBlockNumber should be 0x00f99000; we prank it to 0x00f99001
        proofData[539] = bytes1(0x01);
        // This is now an invalid proof with modified `startBlockNumber` from a valid proof of the chain of block headers between blocks in range `[0xf99000, 0x993ff]`.
        axiom.setHistoricalRoot(
            16_356_352,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"87445763da0b6836b89b8189c4fe71861987aa9af5a715bfb222a7978d98630d"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(StartingBlockNotValid.selector);
        axiom.updateOld(bytes32(hex"00"), uint32(0), proofData);
    }

    function test_updateOld_numFinal_fail() public {
        vm.pauseGasMetering();
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The endBlockNumber is in bytes 540:544 (see getBoundaryBlockData in AxiomV2Configuration.sol)
        // The endBlockNumber should be 0x00f993ff; we prank it to 0x00f99400
        proofData[542] = bytes1(0x94);
        proofData[543] = bytes1(0x00);
        // This is now an invalid proof with modified `numFinal` from a valid proof of the chain of block headers between blocks in range `[0xf99000, 0x993ff]`.
        axiom.setHistoricalRoot(
            16_356_352,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"87445763da0b6836b89b8189c4fe71861987aa9af5a715bfb222a7978d98630d"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(IncorrectNumberOfBlocks.selector);
        axiom.updateOld(bytes32(hex"00"), uint32(0), proofData);
    }

    function test_updateOld_notProver_fail() public {
        // Valid SNARK proof of the chain of block headers between blocks in range `[0xf99000, 0x993ff]`.
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);
        axiom.setHistoricalRoot(
            16_356_352,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"87445763da0b6836b89b8189c4fe71861987aa9af5a715bfb222a7978d98630d"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        // any address not the sender
        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(NotProverRole.selector);
        axiom.updateOld(bytes32(hex"00"), uint32(0), proofData);
    }

    function test_updateOld_freezeUnfreeze() public {
        vm.prank(guardian); // guardian
        axiom.freezeAll();

        // Valid SNARK proof of the chain of block headers between blocks in range `[0xf99000, 0x993ff]`.
        string memory proofStr = vm.readFile("test/data/core/mainnet_10_7_f99000_f993ff.v1.calldata");
        bytes memory proofData = vm.parseBytes(proofStr);
        axiom.setHistoricalRoot(
            16_356_352,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"87445763da0b6836b89b8189c4fe71861987aa9af5a715bfb222a7978d98630d"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        vm.prank(prover);
        vm.expectRevert(ContractIsFrozen.selector); // "Contract is Frozen"
        axiom.updateOld(bytes32(hex"00"), uint32(0), proofData);

        vm.prank(unfreeze); // unfreeze
        axiom.unfreezeAll();

        vm.prank(prover);
        axiom.updateOld(bytes32(hex"00"), uint32(0), proofData);
    }

    function test_updateHistorical() public {
        vm.pauseGasMetering();
        axiom.setHistoricalRoot(
            0x20000,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"45211a1571c1c9e7fdcd25525d065303adb4c7c17c2dd7db11042fcd94ca97d4"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        // Valid witness data for an update for blocks in range `[0x000000, 0x01ffff]`.
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        // Valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        bytes memory proofData = vm.parseBytes(vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata"));
        vm.resumeGasMetering();

        vm.prank(prover);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_updateHistorical_proof_fail() public {
        vm.pauseGasMetering();
        axiom.setHistoricalRoot(
            0x20000,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"45211a1571c1c9e7fdcd25525d065303adb4c7c17c2dd7db11042fcd94ca97d4"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // We prank the 3064th byte to equal 0xec
        proofData[3063] = bytes1(0xec);
        // This is now an invalid proof modified from a valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(SNARKVerificationFailed.selector);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_updateHistorical_startBlockNumber_fail() public {
        vm.pauseGasMetering();
        axiom.setHistoricalRoot(
            0x20000,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"45211a1571c1c9e7fdcd25525d065303adb4c7c17c2dd7db11042fcd94ca97d4"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The startBlockNumber is in bytes 536:540 (see getBoundaryBlockData in AxiomV2Configuration.sol)
        // The startBlockNumber should be 0x00000000; we prank it to 0x00000001
        proofData[539] = bytes1(0x01);
        // This is now an invalid proof with `startBlockNumber` modified from a valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(StartingBlockNotValid.selector);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_updateHistorical_numFinal_fail() public {
        vm.pauseGasMetering();
        axiom.setHistoricalRoot(
            0x20000,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"45211a1571c1c9e7fdcd25525d065303adb4c7c17c2dd7db11042fcd94ca97d4"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        // We first load a correct proof
        string memory correctProofStr = vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata");
        bytes memory proofData = vm.parseBytes(correctProofStr);
        // The endBlockNumber is in bytes 540:544 (see getBoundaryBlockData in AxiomV2Configuration.sol)
        // The endBlockNumber should be 0x0001ffff; we prank it to 0x0001efff
        proofData[542] = bytes1(0xef);
        // This is now an invalid proof with `numFinal` modified from a valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(IncorrectNumberOfBlocks.selector);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_updateHistorical_blockhash_fail() public {
        vm.pauseGasMetering();
        axiom.setHistoricalRoot(
            0x20000,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"45211a1571c1c9e7fdcd25525d065303adb4c7c17c2dd7db11042fcd94ca97d4"),
                    bytes32(hex"01"),
                    uint32(0)
                )
            )
        );
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        // Valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        bytes memory proofData = vm.parseBytes(vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata"));
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(BlockHashIncorrect.selector);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_updateHistorical_noendhash_fail() public {
        vm.pauseGasMetering();
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        // Valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        bytes memory proofData = vm.parseBytes(vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata"));
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(BlockHashIncorrect.selector);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_updateHistorical_merkleRoot_fail() public {
        vm.pauseGasMetering();
        axiom.setHistoricalRoot(
            0x20000,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"45211a1571c1c9e7fdcd25525d065303adb4c7c17c2dd7db11042fcd94ca97d4"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        roots[0] = bytes32(0x0);
        // Valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        bytes memory proofData = vm.parseBytes(vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata"));
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(MerkleProofFailed.selector);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_updateHistorical_merkleProof_fail() public {
        vm.pauseGasMetering();
        axiom.setHistoricalRoot(
            0x20000,
            keccak256(
                abi.encodePacked(
                    bytes32(hex"45211a1571c1c9e7fdcd25525d065303adb4c7c17c2dd7db11042fcd94ca97d4"),
                    bytes32(hex"00"),
                    uint32(0)
                )
            )
        );
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        endHashProofs[10][10] = bytes32(0x0);
        // Valid SNARK proof of the chain of block headers between blocks in range `[0x000000, 0x01ffff]`.
        bytes memory proofData = vm.parseBytes(vm.readFile("test/data/core/mainnet_17_7_000000_01ffff.v1.calldata"));
        vm.resumeGasMetering();
        vm.prank(prover);
        vm.expectRevert(MerkleProofFailed.selector);
        axiom.updateHistorical(bytes32(hex"00"), uint32(0), roots, endHashProofs, proofData);
    }

    function test_appendHistoricalMMR() public {
        vm.pauseGasMetering();
        test_updateHistorical();
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        vm.resumeGasMetering();

        bytes32[] memory _roots = new bytes32[](128);
        for (uint256 i = 0; i < 128; i++) {
            _roots[i] = roots[i];
        }
        bytes32[] memory prevHashes = new bytes32[](128);
        prevHashes[0] = bytes32(0x0);
        for (uint256 i = 1; i < 128; i++) {
            prevHashes[i] = endHashProofs[i - 1][10];
        }

        vm.expectRevert(AxiomBlockVerificationFailed.selector);
        axiom.appendHistoricalPMMR(0, _roots, prevHashes, 1023);

        axiom.appendHistoricalPMMR(0, _roots, prevHashes, 1024);
    }

    function test_appendHistoricalMMR_startBlockNumber_fail() public {
        vm.pauseGasMetering();
        test_updateHistorical();
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        vm.resumeGasMetering();

        bytes32[] memory _roots = new bytes32[](128);
        for (uint256 i = 0; i < 128; i++) {
            _roots[i] = roots[i];
        }
        bytes32[] memory prevHashes = new bytes32[](128);
        prevHashes[0] = bytes32(0x0);
        for (uint256 i = 1; i < 128; i++) {
            prevHashes[i] = endHashProofs[i - 1][10];
        }

        vm.expectRevert(IncorrectNumberOfBlocks.selector);
        axiom.appendHistoricalPMMR(1024, _roots, prevHashes, 1024);
    }

    function test_appendHistoricalMMR_length0_fail() public {
        vm.pauseGasMetering();
        test_updateHistorical();
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (, bytes32[11][127] memory endHashProofs) = abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        vm.resumeGasMetering();

        bytes32[] memory _roots = new bytes32[](0);
        bytes32[] memory prevHashes = new bytes32[](128);
        prevHashes[0] = bytes32(0x0);
        for (uint256 i = 1; i < 128; i++) {
            prevHashes[i] = endHashProofs[i - 1][10];
        }

        vm.expectRevert(IncorrectNumberOfBlocks.selector);
        axiom.appendHistoricalPMMR(0, _roots, prevHashes, 1024);
    }

    function test_appendHistoricalMMR_update_fail() public {
        vm.pauseGasMetering();
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        vm.resumeGasMetering();

        bytes32[] memory _roots = new bytes32[](128);
        for (uint256 i = 0; i < 128; i++) {
            _roots[i] = roots[i];
        }
        bytes32[] memory prevHashes = new bytes32[](128);
        prevHashes[0] = bytes32(0x0);
        for (uint256 i = 1; i < 128; i++) {
            prevHashes[i] = endHashProofs[i - 1][10];
        }

        vm.expectRevert(AxiomBlockVerificationFailed.selector);
        axiom.appendHistoricalPMMR(0, _roots, prevHashes, 1024);
    }

    function test_appendHistoricalMMR_rootLength_fail() public {
        vm.pauseGasMetering();
        test_updateHistorical();
        string memory data = vm.readFile("test/data/core/updateHistorical_0.dat");
        (bytes32[128] memory roots, bytes32[11][127] memory endHashProofs) =
            abi.decode(vm.parseBytes(data), (bytes32[128], bytes32[11][127]));
        vm.resumeGasMetering();

        bytes32[] memory _roots = new bytes32[](127);
        for (uint256 i = 0; i < 127; i++) {
            _roots[i] = roots[i];
        }
        bytes32[] memory prevHashes = new bytes32[](128);
        prevHashes[0] = bytes32(0x0);
        for (uint256 i = 1; i < 128; i++) {
            prevHashes[i] = endHashProofs[i - 1][10];
        }

        vm.expectRevert(IncorrectNumberOfBlocks.selector);
        axiom.appendHistoricalPMMR(0, _roots, prevHashes, 1024);
    }

    function test_isRecentBlockHashValid() public {
        vm.roll(1024);

        uint32 blockNumber = uint32(block.number) - 100;
        bytes32 claimedBlockHash = blockhash(blockNumber);

        assert(axiom.isRecentBlockHashValid(blockNumber, claimedBlockHash));
    }

    function test_isRecentBlockHashValid_notRecentBlockHash_fail() public {
        vm.roll(1024);

        uint32 blockNumber = uint32(block.number) - 500;
        bytes32 claimedBlockHash = blockhash(blockNumber);

        vm.expectRevert(BlockHashIncorrect.selector);
        axiom.isRecentBlockHashValid(blockNumber, claimedBlockHash);
    }

    function test_isRecentBlockHashValid_invalidBlockHash_fail() public {
        vm.roll(1024);

        uint32 blockNumber = uint32(block.number) - 100;
        bytes32 claimedBlockHash = bytes32(0);

        assertFalse(axiom.isRecentBlockHashValid(blockNumber, claimedBlockHash));
    }

    function test_blockHash() public {
        vm.roll(16_356_352);
        emit log_uint(uint256(blockhash(block.number - 256)));
    }

    function test_emptyHashes() public pure {
        bytes32 empty = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        for (uint256 i = 0; i < 10 - 1; i++) {
            empty = keccak256(abi.encodePacked(empty, empty));
            assert(MerkleTree.getEmptyHash(i + 1) == empty);
        }
    }

    function test_supportsInterface() public view {
        assert(axiom.supportsInterface(type(IAxiomV2Core).interfaceId));
    }
}
