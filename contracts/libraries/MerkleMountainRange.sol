// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { MerkleTree } from "./MerkleTree.sol";
import { Hash } from "./Hash.sol";

uint256 constant MAX_MMR_PEAKS = 32;

/// @title  Merkle Mountain Range
/// @author Axiom
/// @notice Library for Merkle Mountain Range data structure
library MerkleMountainRange {
    /// @notice A Merkle mountain range is a data structure for efficiently storing a commitment to a variable length list of bytes32 values.
    /// @param  peaks The peaks of the MMR as a fixed-length array of length 32.
    ///         `peaks` is ordered in *increasing* size of peaks: `peaks[i]` is the Merkle root of a tree of size `2 ** i` corresponding to the `i`th bit of `len` (see @dev for details)
    /// @param  peaksLength The actual number of peaks in the MMR
    /// @dev    peaks stores `peaksLength := bit_length(len)` Merkle roots, with
    ///         `peaks[i] = root(list[((len >> i) << i) - 2^i : ((len >> i) << i)])` if 2^i & len != 0, otherwise 0
    ///         where root(single element) = single element, and `list` is the underlying list for the MMR
    ///         Warning: Only use the check `peaks[i] == 0` to determine if `peaks[i]` is undefined if the original list is guaranteed to not contain 0
    ///         (e.g., if the original list is already of hashes)
    ///         Default initialization is to `len = 0`, `peaksLength = 0`, and all `peaks[i] = 0`
    struct MMR {
        bytes32[MAX_MMR_PEAKS] peaks;
        uint256 peaksLength;
    }

    /// @dev Create an MMR from a variable length array
    /// @param peaks The variable length array
    /// @return out The MMR in memory
    function fromPeaks(bytes32[] memory peaks) internal pure returns (MMR memory out) {
        return fromPeaks(peaks, 0, peaks.length);
    }

    /// @notice Create an MMR from a slice of variable length array
    /// @dev    Only reads the peaks up to `peaksLength`
    /// @param peaks The variable length array
    /// @param start The start index of the subarray
    /// @param length The length of the subarray
    /// @return out The MMR in memory
    function fromPeaks(bytes32[] memory peaks, uint256 start, uint256 length) internal pure returns (MMR memory out) {
        out.peaksLength = length;
        for (uint256 idx; idx < length;) {
            unchecked {
                out.peaks[idx] = peaks[start + idx];
                ++idx;
            }
        }
    }

    /// @notice Copies the MMR to memory
    /// @dev    Only reads the peaks up to `peaksLength`
    /// @param  self The MMR
    /// @return out The MMR in memory
    function clone(MMR storage self) internal view returns (MMR memory out) {
        out.peaksLength = self.peaksLength;

        uint256 outPeaksLength = out.peaksLength;
        for (uint256 i; i < outPeaksLength;) {
            out.peaks[i] = self.peaks[i];
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Copies MMR from memory to storage
    /// @dev    Only changes peaks up to `peaksChanged` to limit SSTOREs
    /// @param  self The MMR in storage
    /// @param  peaksChanged Only copy newMMR.peaks[0 : peaksChanged]
    function persistFrom(MMR storage self, MMR memory newMMR, uint256 peaksChanged) internal {
        self.peaksLength = newMMR.peaksLength;

        for (uint256 i; i < peaksChanged;) {
            self.peaks[i] = newMMR.peaks[i];
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Compute the keccak of the concatenated peaks
    /// @param  self The MMR
    /// @return keccak of the concatenated peaks
    function commit(MMR memory self) internal pure returns (bytes32) {
        bytes32[] memory peaks = new bytes32[](self.peaksLength);

        uint256 peaksLength = self.peaksLength;
        for (uint256 i; i < peaksLength;) {
            peaks[i] = self.peaks[i];
            unchecked {
                ++i;
            }
        }

        return keccak256(abi.encodePacked(peaks));
    }

    /// @notice Append a new element to the underlying list of the MMR
    /// @param  self The MMR
    /// @param  leaf The new element to append
    /// @return peaksChanged self.peaks[0 : peaksChanged] have been changed
    function appendLeaf(MMR memory self, bytes32 leaf) internal pure returns (uint256 peaksChanged) {
        unchecked {
            bytes32 newPeak = leaf;
            uint256 i;
            uint256 peaksLength = self.peaksLength;
            for (; i < peaksLength && self.peaks[i] != bytes32(0);) {
                newPeak = Hash.keccak(self.peaks[i], newPeak);
                delete self.peaks[i];
                ++i;
            }
            self.peaks[i] = newPeak;

            if (i >= peaksLength) {
                self.peaksLength = i + 1;
            }

            peaksChanged = i + 1;
        }
    }

    /// @notice Append a sequence of new elements to the underlying list of the MMR, in order
    /// @dev    Optimized compared to looping over `appendLeaf`
    /// @param  self The MMR
    /// @param  leaves The new elements to append
    /// @return peaksChanged self.peaks[0 : peaksChanged] have been changed
    /// @dev Warning: To save gas, this method overwrites values of `leaves` with intermediate computations.
    ///      The input values of `leaves` should be considered invalidated after calling this method.
    function appendLeaves(MMR memory self, bytes32[] memory leaves) internal pure returns (uint256 peaksChanged) {
        // keeps track of running length of `leaves`
        uint256 toAdd = leaves.length;
        uint256 shift;
        uint256 i;
        bytes32 left;
        bytes32 right;
        uint256 nextAdd;
        uint256 bound;

        while (toAdd != 0) {
            // shift records whether there is an existing peak in the range we should hash with
            shift = (self.peaks[i] == bytes32(0)) ? 0 : 1;
            // if shift, add peaks[i] to beginning of leaves
            // then hash all leaves
            unchecked {
                nextAdd = (toAdd + shift) >> 1;
            }

            bound = (nextAdd << 1);
            for (uint256 j; j < bound;) {
                if (shift == 1) {
                    if (j == 0) {
                        left = self.peaks[i];
                    } else {
                        unchecked {
                            left = leaves[j - 1];
                        }
                    }
                    right = leaves[j];
                } else {
                    left = leaves[j];
                    unchecked {
                        right = leaves[j + 1];
                    }
                }
                leaves[j >> 1] = Hash.keccak(left, right);
                unchecked {
                    j = j + 2;
                }
            }
            // if toAdd + shift is odd, the last element is new self.peaks[i], otherwise 0
            if (toAdd & 1 != shift) {
                unchecked {
                    // toAdd is non-zero in this branch
                    self.peaks[i] = leaves[toAdd - 1];
                }
            } else if (shift == 1) {
                // if shift == 0 then self.peaks[i] is already 0
                self.peaks[i] = 0;
            }

            toAdd = nextAdd;
            unchecked {
                ++i;
            }
        }

        if (i > self.peaksLength) {
            self.peaksLength = i;
        }

        peaksChanged = i;
    }

    /**
     * @notice Compute the `completeLeaves` of an existing MMR when converted to a padded MMR with depth `paddingDepth`.
     * @param  self The MMR.
     * @param  paddingDepth The depth of the padded Merkle tree.
     * @return out The `completeLeaves` of the padded Merkle mountain range corresponding to the MMR.
     */
    function getCompleteLeaves(MMR memory self, uint256 paddingDepth) internal pure returns (MMR memory out) {
        unchecked {
            // if self.peaksLength < paddingDepth, then out.peaksLength = 0
            if (self.peaksLength >= paddingDepth) {
                out.peaksLength = self.peaksLength - paddingDepth;
            }
            for (uint256 i = paddingDepth; i < self.peaksLength;) {
                out.peaks[i - paddingDepth] = self.peaks[i];
                ++i;
            }
        }
    }

    /**
     * @notice Hash an existing MMR to a Merkle root of a 0-padded Merkle tree with depth `paddingDepth`.
     * @param  self The MMR.
     * @param  paddingDepth The depth of the padded Merkle tree.
     * @return root The Merkle root of the padded MMR.
     */
    function getZeroPaddedMerkleRoot(MMR memory self, uint256 paddingDepth) internal pure returns (bytes32) {
        bytes32 root;
        bool started;

        for (uint256 peakIdx; peakIdx < paddingDepth;) {
            if (!started && self.peaks[peakIdx] != bytes32(0)) {
                root = MerkleTree.getEmptyHash(peakIdx);
                started = true;
            }

            if (started) {
                root = self.peaks[peakIdx] != bytes32(0)
                    ? Hash.keccak(self.peaks[peakIdx], root)
                    : Hash.keccak(root, MerkleTree.getEmptyHash(peakIdx));
            }
            unchecked {
                ++peakIdx;
            }
        }

        return root;
    }

    /**
     * @dev    Extend an existing MMR to a Merkle root of a padded list of length `paddingSize` using complement peaks.
     * @param  self The MMR.
     * @param  paddingDepth The depth of the padded Merkle tree.
     * @param  mmrComplement Entries which contain peaks of a complementary MMR, where `mmrComplement[idx]` is either `bytes32(0x0)` or the
     *         Merkle root of a tree of depth `idx`.  Only the relevant indices are accessed.
     * @dev    As an example, if `mmr` has peaks of depth 9 8 6 3, then `mmrComplement` has peaks of depth 3 4 5 7
     *         In this example, the peaks of `mmr` are Merkle roots of the first 2^9 leaves, then the next 2^8 leaves, and so on.
     *         The peaks of `mmrComplement` are Merkle roots of the first 2^3 leaves after `mmr`, then the next 2^4 leaves, and so on.
     * @return root The Merkle root of the completion of `mmr`.
     */
    function getComplementMerkleRoot(MMR memory self, uint256 paddingDepth, bytes32[] memory mmrComplement)
        internal
        pure
        returns (bytes32)
    {
        bytes32 root;
        bool started;

        for (uint256 peakIdx; peakIdx < paddingDepth;) {
            if (!started && self.peaks[peakIdx] != bytes32(0)) {
                root = mmrComplement[peakIdx];
                started = true;
            }

            if (started) {
                root = self.peaks[peakIdx] != bytes32(0)
                    ? Hash.keccak(self.peaks[peakIdx], root)
                    : Hash.keccak(root, mmrComplement[peakIdx]);
            }
            unchecked {
                ++peakIdx;
            }
        }

        return root;
    }
}
