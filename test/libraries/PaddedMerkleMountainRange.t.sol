// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../contracts/libraries/PaddedMerkleMountainRange.sol";

error PmmrLeafIsTooBig();
error PmmrLeafIsNotEmpty();

contract PaddedMerkleMountainRangeTest is Test {
    using PaddedMerkleMountainRange for PaddedMerkleMountainRange.PMMR;

    bytes32[] leaves;
    uint32 paddingSize = 1024;

    function setUp() public {
        leaves = new bytes32[](2**17);
        for (uint32 i = 0; i < leaves.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(i));
        }
    }

    function test_updatePaddedLeaf() public {
        PaddedMerkleMountainRange.PMMR memory pmmr;
        bytes32 leaf = keccak256(abi.encodePacked("1"));
        uint32 leafSize = 1;

        pmmr.updatePaddedLeaf(paddingSize, leaf, leafSize);

        assert(pmmr.paddedLeaf == leaf);
        assert(pmmr.size == leafSize);
    }

    function test_appendCompleteLeaves() public {
        PaddedMerkleMountainRange.PMMR memory pmmr;

        pmmr.appendCompleteLeaves(paddingSize, leaves);

        assert(pmmr.size == leaves.length * paddingSize);
        assert(pmmr.completeLeaves.peaksLength > 0);
    }

    function test_commit() public {
        PaddedMerkleMountainRange.PMMR memory pmmr;
        bytes32 leaf = keccak256(abi.encodePacked("1"));
        uint32 leafSize = 1;

        pmmr.appendCompleteLeaves(paddingSize, leaves);
        pmmr.updatePaddedLeaf(paddingSize, leaf, leafSize);

        bytes32[] memory peaks = new bytes32[](pmmr.completeLeaves.peaksLength);

        for (uint32 i; i < pmmr.completeLeaves.peaksLength; ++i) {
            peaks[i] = pmmr.completeLeaves.peaks[i];
        }

        bytes32 commitHash = pmmr.commit();
        assert(commitHash == keccak256(abi.encodePacked(pmmr.paddedLeaf, peaks)));
    }

    function test_updatePaddedLeaf_LeafTooBig() public {
        PaddedMerkleMountainRange.PMMR memory pmmr;
        uint32 paddingSize = 32;
        bytes32 leaf = keccak256(abi.encodePacked("1"));
        uint32 leafSize = 33;

        vm.expectRevert(PmmrLeafIsTooBig.selector);
        pmmr.updatePaddedLeaf(paddingSize, leaf, leafSize);
    }

    function test_appendCompleteLeaves_PaddedLeafNotEmpty() public {
        PaddedMerkleMountainRange.PMMR memory pmmr;
        uint32 paddingSize = 32;
        bytes32 leaf = keccak256(abi.encodePacked("1"));
        uint32 leafSize = 1;

        pmmr.updatePaddedLeaf(paddingSize, leaf, leafSize);

        vm.expectRevert(PmmrLeafIsNotEmpty.selector);
        pmmr.appendCompleteLeaves(paddingSize, leaves);
    }
}
