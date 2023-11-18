// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../contracts/libraries/MerkleTree.sol";
import { BLOCK_BATCH_DEPTH } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";

contract MerkleTreeTest is Test {
    using { MerkleTree.merkleRoot } for bytes32[128];

    function test_emptyMerkleRoots() public {
        vm.pauseGasMetering();
        bytes32 currHash = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        assert(BLOCK_BATCH_DEPTH == 10);
        for (uint256 depth = 0; depth < 10; depth++) {
            assert(currHash == MerkleTree.getEmptyHash(depth));
            currHash = keccak256(abi.encodePacked(currHash, currHash));
        }

        vm.expectRevert();
        MerkleTree.getEmptyHash(10);
        vm.resumeGasMetering();
    }

    function test_merkleRootValue() public pure {
        bytes32[128] memory leaves;
        for (uint256 i = 0; i < leaves.length; i++) {
            leaves[i] = bytes32(0x0);
        }
        bytes32 root = leaves.merkleRoot();
        assert(root == MerkleTree.getEmptyHash(7));
        assert(leaves[0] == bytes32(0x0));
    }
}
