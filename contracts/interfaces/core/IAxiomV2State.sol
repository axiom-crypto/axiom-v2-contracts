// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PaddedMerkleMountainRange } from "../../libraries/PaddedMerkleMountainRange.sol";
import { MerkleMountainRange } from "../../libraries/MerkleMountainRange.sol";

interface IAxiomV2State {
    /// @notice Returns the hash of a batch of consecutive blocks previously verified by the contract
    /// @param  startBlockNumber The block number of the first block in the batch
    /// @dev    The reads here will match the emitted #UpdateEvent
    /// @return historicalRoots(startBlockNumber) is 0 unless (startBlockNumber % 1024 == 0)
    ///         historicalRoots(startBlockNumber) = 0 if block `startBlockNumber` is not verified
    ///         historicalRoots(startBlockNumber) = keccak256(prevHash || root || numFinal) where || is concatenation
    ///         - prevHash is the parent hash of block `startBlockNumber`
    ///         - root is the keccak Merkle root of hash(i) for i in [0, 1024), where
    ///             hash(i) is the blockhash of block `startBlockNumber + i` if i < numFinal,
    ///             hash(i) = bytes32(0x0) if i >= numFinal
    ///         - 0 < numFinal <= 1024 is the number of verified consecutive roots in [startBlockNumber, startBlockNumber + numFinal)
    function historicalRoots(uint32 startBlockNumber) external view returns (bytes32);

    /// @notice Get the number of consecutive blocks from genesis currently committed to in `blockhashPmmr`
    ///         The padded Merkle mountain range `blockhashPmmr` commits to the block hashes of blocks
    ///         `[0, pmmrSize)`
    /// @return pmmrSize indicates that the blockhashPmmr commits to blockhashes of blocks `[0, pmmrSize)`
    function blockhashPmmrSize() external view returns (uint32 pmmrSize);

    /// @notice Get the `paddedLeaf` of the padded Merkle mountain range `blockhashPmmr`
    /// @return paddedLeaf the `paddedLeaf` corresponding to `blockhashPmmr`
    function blockhashPmmrLeaf() external view returns (bytes32);

    /// @notice Returns the PMMR commitment to the blockhashes of blocks `[0, pmmrSize)`, if it exists, `bytes32(0x0)` otherwise
    /// @param  pmmrSize The number of blocks committed to in the PMMR
    /// @return pmmrHash The hash of the PMMR, as computed by `PaddedMerkleMountainRange.commit`
    function pmmrSnapshots(uint32 pmmrSize) external view returns (bytes32);

    /// @notice Returns the Merkle mountain range of peaks in `blockhashPmmr
    /// @return mmr The Merkle mountain range.
    function blockhashPmmrPeaks() external view returns (MerkleMountainRange.MMR memory);

    /// @notice Get the full current `blockhashPmmr`
    /// @return blockhashPmmr The current PMMR commitment to historic block hashes
    function fullBlockhashPmmr() external view returns (PaddedMerkleMountainRange.PMMR memory);
}
