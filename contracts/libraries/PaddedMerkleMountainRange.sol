// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { MerkleMountainRange } from "./MerkleMountainRange.sol";

/// @title  Padded Merkle Mountain Range
/// @author Axiom
/// @notice Library for Merkle Mountain Range data structure
library PaddedMerkleMountainRange {
    using MerkleMountainRange for MerkleMountainRange.MMR;

    /// @dev Error returned if the leaf is too big
    error PmmrLeafIsTooBig();

    /// @dev Error returned if the leaf is not empty
    error PmmrLeafIsNotEmpty();

    /**
     * @notice A Padded Merkle mountain range is a data structure for efficiently storing a commitment
     *         to a variable length list of hash values batched by a specific size.  For a fixed `paddingSize`
     *         which must be a power of two, a PMMR consists of a standard MMR of Merkle roots of batches of
     *         `paddingSize` hashes and a `paddedLeaf`, which is a Merkle root of the 0-padded last partial batch of
     *         hashes, where the number of hashes lies in `[0, paddingSize)`.
     *         We define `paddedLeaf = bytes32(0x0)` if the last partial batch of hashes is empty.
     * @param  completeLeaves The MMR of the complete leaves of the PMMR
     * @param  paddedLeaf The Merkle root of the 0-padded last partial batch of hashes
     * @param  size The number of hashes this PMMR is a commitment to.
     */
    struct PMMR {
        MerkleMountainRange.MMR completeLeaves;
        bytes32 paddedLeaf;
        uint32 size;
    }

    /**
     * @notice Copies the PMMR from storage to memory
     * @param  self The PMMR in storage
     * @return out The PMMR in memory
     */
    function clone(PMMR storage self) internal view returns (PMMR memory out) {
        out.completeLeaves = self.completeLeaves.clone();
        out.paddedLeaf = self.paddedLeaf;
        out.size = self.size;
    }

    /**
     * @notice Copies PMMR from memory to storage
     * @param  self The PMMR in storage
     * @param  sourcePMMR The PMMR in memory
     * @param  peaksChanged Only copy newMMR.peaks[0 : peaksChanged]
     */
    function persistFrom(PMMR storage self, PMMR memory sourcePMMR, uint256 peaksChanged) internal {
        self.completeLeaves.persistFrom(sourcePMMR.completeLeaves, peaksChanged);
        self.paddedLeaf = sourcePMMR.paddedLeaf;
        self.size = sourcePMMR.size;
    }

    /**
     * @notice Compute a commitment to the PMMR, defined by
     *         keccak(paddedLeaf || completeLeaves.peaks[0] || ... || completeLeaves.peaks[completeLeaves.peaksLength - 1])
     * @param  self The PMMR
     * @return keccak the hash of the concatenation
     */
    function commit(PMMR memory self) internal pure returns (bytes32) {
        bytes32[] memory peaks = new bytes32[](self.completeLeaves.peaksLength);

        for (uint256 i; i < self.completeLeaves.peaksLength;) {
            peaks[i] = self.completeLeaves.peaks[i];
            unchecked {
                ++i;
            }
        }

        return keccak256(abi.encodePacked(self.paddedLeaf, peaks));
    }

    /**
     * @notice Updates the first peak representing the padded batch leaf
     * @dev    Warning: This method can overflow if `self.size + leafSize` exceeds `2**32 - 1`.
     *         This cannot happen for realistic values of block numbers, which is not an issue
     *         in our application.
     * @param  self The PMMR
     * @param  paddingSize The size of the padded batch
     * @param  leaf The padded leaf update
     * @param  leafSize The size of the padded leaf, defined as the number of non-zero hashes it contains
     * @return completePeaksChanged amount of peaks that have been changed
     */
    function updatePaddedLeaf(PMMR memory self, uint32 paddingSize, bytes32 leaf, uint32 leafSize)
        internal
        pure
        returns (uint256 completePeaksChanged)
    {
        if (leafSize > paddingSize) {
            revert PmmrLeafIsTooBig();
        }

        unchecked {
            self.size = self.size - self.size % paddingSize + leafSize;
        }

        // just updating the padded leaf that is always at index 0
        if (leafSize < paddingSize) {
            self.paddedLeaf = leaf;
            return 0;
        }

        // If leaf is complete
        delete self.paddedLeaf;
        completePeaksChanged = self.completeLeaves.appendLeaf(leaf);
    }

    /**
     * @notice Append a sequence of complete leaves to the underlying list of the PMMR
     * @dev    The padded leaf should be empty to be able to append complete leaves
     * @param  self The PMMR
     * @param  paddingSize The size of the padded batch
     * @param  leaves The new elements to append
     * @return completePeaksChanged amount of peaks that have been changed
     * @dev Warning: To save gas, this method overwrites values of `leaves` with intermediate computations.
     *      The input values of `leaves` should be considered invalidated after calling this method.
     */
    function appendCompleteLeaves(PMMR memory self, uint32 paddingSize, bytes32[] memory leaves)
        internal
        pure
        returns (uint256 completePeaksChanged)
    {
        if (self.paddedLeaf != bytes32(0)) {
            revert PmmrLeafIsNotEmpty();
        }

        self.size += uint32(leaves.length) * paddingSize;

        completePeaksChanged = self.completeLeaves.appendLeaves(leaves);
    }
}
