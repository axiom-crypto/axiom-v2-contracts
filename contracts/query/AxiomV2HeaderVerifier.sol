// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IAxiomV2HeaderVerifier } from "../interfaces/query/IAxiomV2HeaderVerifier.sol";
import { IAxiomV2State } from "../interfaces/core/IAxiomV2State.sol";
import { MerkleMountainRange } from "../libraries/MerkleMountainRange.sol";
import { PaddedMerkleMountainRange } from "../libraries/PaddedMerkleMountainRange.sol";
import { BLOCK_BATCH_DEPTH, BLOCK_BATCH_SIZE } from "../libraries/configuration/AxiomV2Configuration.sol";

contract AxiomV2HeaderVerifier is IAxiomV2HeaderVerifier {
    using PaddedMerkleMountainRange for PaddedMerkleMountainRange.PMMR;
    using MerkleMountainRange for MerkleMountainRange.MMR;

    address public immutable axiomCoreAddress;

    uint64 internal immutable _CHAIN_ID;

    /// @dev Initialize the contract.
    /// @param chainId The chain ID of the source chain this verifies headers from.
    /// @param _axiomCoreAddress The address of the AxiomV2Core contract.
    constructor(uint64 chainId, address _axiomCoreAddress) {
        _CHAIN_ID = chainId;

        if (_axiomCoreAddress == address(0)) {
            revert AxiomCoreAddressIsZero();
        }
        axiomCoreAddress = _axiomCoreAddress;
    }

    /// @dev This verifier handles the case of the same source and target chain. For the purpose
    ///      of this discussion, we call recent blocks to be blocks in [block.number - 256, block.number)
    ///
    ///      We make the assumption that AxiomV2Core guarantees that `blockhashPmmr` is a commitment
    ///      to block hashes up to a recent block at all times.
    ///
    ///      We consider the state of AxiomV2Core at three block times:
    ///        -- Proof time:      Time of query submission / proof initiation
    ///        -- Submission time: Time of verification tx submission
    ///        -- Execution time:  Time of verification tx execution
    ///
    ///      At proof time, let `blockhashPmmr` commit to blocks `[0, currentPmmrSize)`.
    ///      Each query also has some minimum range of blocks `[0, queryPmmrSize)` which must be accessed.
    ///        -- If `queryBlockNum <= currentBlockNum`, then we check that `blockhashMmrKeccak` is committed
    ///           to in `blockhashPmmr` using the commitment to `blockhashPmmr` in `pmmrSnapshots`.
    ///        -- Otherwise, at transaction submission time, if `blockhashPmmr` is more recent than
    ///           `queryBlockNum`, then `queryBlockNum` is committed to in `blockhashPmmr` and
    ///           we can submit witness data allowing us to check that commitment as in the previous case.
    ///        -- Otherwise, at transaction submission time, `queryBlockNum` must be recent (as otherwise
    ///           `blockhashPmmr` is recent and thus more recent).  At transaction execution time, if:
    ///           -- `queryBlockNum` is still recent, then at least one of the following must hold, and we can use
    ///              recent block hashes to verify:
    ///              -- `pmmrSnapshot` is still recent
    ///              -- `queryBlockNum <= blockhashPmmr.size`
    ///           -- If `queryBlockNum` is no longer recent, the transaction will fail.
    ///              In this case, we should resubmit with the new recent `blockhashPmmr` at time of transaction execution.
    function verifyQueryHeaders(bytes32 proofMmrKeccak, MmrWitness calldata mmrWitness) external view {
        bytes32[] memory peaks = mmrWitness.proofMmrPeaks;
        uint32 snapshotPmmrSize = mmrWitness.snapshotPmmrSize;

        if (proofMmrKeccak != keccak256(abi.encodePacked(peaks))) {
            revert ProofMmrKeccakDoesNotMatch();
        }

        uint32 proofMmrSize;
        uint256 proofMmrPeaksLength = peaks.length;
        // Get proofMmrSize from heights of witnessMmrPeaks
        for (uint256 idx; idx < proofMmrPeaksLength;) {
            if (peaks[idx] != bytes32(0)) {
                proofMmrSize = proofMmrSize + uint32(1 << idx);
            }
            unchecked {
                ++idx;
            }
        }

        if (proofMmrSize <= snapshotPmmrSize) {
            // Creating a proof PMMR with empty padded leaf and complete leaf peaks from proofMmrPeaks[BLOCK_BATCH_DEPTH:]
            PaddedMerkleMountainRange.PMMR memory proofPmmr = PaddedMerkleMountainRange.PMMR({
                paddedLeaf: bytes32(0),
                completeLeaves: MerkleMountainRange.fromPeaks(
                    peaks, BLOCK_BATCH_DEPTH, proofMmrPeaksLength - BLOCK_BATCH_DEPTH
                    ),
                size: proofMmrSize - (proofMmrSize % BLOCK_BATCH_SIZE)
            });

            MerkleMountainRange.MMR memory proofBatchMmr = MerkleMountainRange.fromPeaks(peaks, 0, BLOCK_BATCH_DEPTH);

            // We check `proofMmrPeaks` can be extended to the MMR committed to
            // in `pmmrSnapshots[mmrWitness.snapshotPmmrSize]`
            //
            // This can happen in two possible ways:
            // * If `snapshotPmmrSize - (snapshotPmmrSize % 1024) > proofMmrSize`, then we can check:
            //   -- the completion of proofMmrPeaks[:10] to a full Merkle root
            //   -- the extension of proofMmrPeaks[10:] by this Merkle root and additional Merkle roots
            //   -- the extension of the resulting MMR by a padded leaf
            //   -- this result should match `pmmrSnapshots[snapshotPmmrSize]`
            //
            // * If `snapshotPmmrSize - (snapshotPmmrSize % 1024) <= proofMmrSize`, then we can check:
            //   -- the completion of proofMmrPeaks[:10] to a full Merkle root with zero padding
            //   -- the commitment of the resulting PMMR should match `pmmrSnapshots[snapshotPmmrSize]`

            if (snapshotPmmrSize - (snapshotPmmrSize % BLOCK_BATCH_SIZE) >= proofMmrSize) {
                if (proofMmrSize % BLOCK_BATCH_SIZE > 0) {
                    // complete the first 10 peaks of `proofMmrPeaks` to a full Merkle root and update `proofPmmr`
                    bytes32 completedLeaf =
                        proofBatchMmr.getComplementMerkleRoot(BLOCK_BATCH_DEPTH, mmrWitness.mmrComplementOrPeaks);
                    proofPmmr.updatePaddedLeaf(BLOCK_BATCH_SIZE, completedLeaf, BLOCK_BATCH_SIZE);
                }

                if (snapshotPmmrSize - (snapshotPmmrSize % BLOCK_BATCH_SIZE) > proofMmrSize) {
                    // append additional complete leaves
                    proofPmmr.appendCompleteLeaves(BLOCK_BATCH_SIZE, mmrWitness.mmrComplementOrPeaks[11:]);
                }

                proofPmmr.updatePaddedLeaf(
                    BLOCK_BATCH_SIZE, mmrWitness.mmrComplementOrPeaks[10], snapshotPmmrSize % BLOCK_BATCH_SIZE
                );
            } else {
                // complete the first 10 peaks of `proofMmrPeaks` to a full Merkle root and update `proofPmmr`
                bytes32 completedLeaf =
                    proofBatchMmr.getComplementMerkleRoot(BLOCK_BATCH_DEPTH, mmrWitness.mmrComplementOrPeaks);
                proofPmmr.updatePaddedLeaf(BLOCK_BATCH_SIZE, completedLeaf, snapshotPmmrSize % BLOCK_BATCH_SIZE);
            }

            // check the resulting PMMR is committed to in `pmmrSnapshots[mmrWitness.snapshotPmmrSize]`
            bytes32 completePmmrKeccak = proofPmmr.commit();
            if (completePmmrKeccak != IAxiomV2State(axiomCoreAddress).pmmrSnapshots(snapshotPmmrSize)) {
                revert BlockhashMmrKeccakDoesNotMatchProof();
            }
        } else {
            // We check in order of preference that:
            //   * If `mmrWitness.snapshotPmmrSize >= block.number - 256`, we can check the PMMR committed to
            //     by `pmmrSnapshots[mmrWitness.snapshotPmmrSize]` can be extended to `proofMmrPeaks` by blockhashes
            //     accessible in EVM.  This happens by:
            //     -- Decommit the PMMR in `pmmrSnapshots[mmrWitness.snapshotPmmrSize]`
            //     -- Decommit the padded leaf in the decommitted PMMR.
            //     -- Extend the padded leaf with `blockhash` calls
            //     -- If necessary, extend the MMR and padding with `blockhash` calls
            //
            //   * If `proofMmrSize >= block.number - 256` and `proofMmrSize <= blockhashPmmr.size`,
            //     we can check that `proofMmrPeaks` can be extended to `blockhashPmmr` by blockhashes accessible in EVM via:
            //     -- Extend the MMR with `blockhash` calls
            //     -- Form the padded leaf and check against `blockhashPmmr`

            if (proofMmrSize > block.number) {
                revert MmrEndBlockNotRecent();
            }

            // if both mmrWitness.snapshotPmmrSize >= block.number - 256 and
            // proofMmrSize >= block.number - 256 and `proofMmrSize <= blockhashPmmr.size`
            //
            // then we have two options for which way to validate, which require calling `blockhash`
            // * case 1: `proofMmrSize - snapshotPmmrSize` times
            // * case 2: `blockhashPmmr.size - proofMmrSize` times
            //
            // we choose the smaller one
            uint32 corePmmrSize = IAxiomV2State(axiomCoreAddress).blockhashPmmrSize();
            if (
                snapshotPmmrSize >= block.number - 256
                    && (proofMmrSize > corePmmrSize || proofMmrSize - snapshotPmmrSize <= corePmmrSize - proofMmrSize)
            ) {
                // Decommit the PMMR in `pmmrSnapshots[mmrWitness.snapshotPmmrSize]`
                PaddedMerkleMountainRange.PMMR memory snapshotPmmr = PaddedMerkleMountainRange.PMMR({
                    paddedLeaf: bytes32(0),
                    completeLeaves: MerkleMountainRange.fromPeaks(
                        mmrWitness.mmrComplementOrPeaks,
                        BLOCK_BATCH_DEPTH,
                        mmrWitness.mmrComplementOrPeaks.length - BLOCK_BATCH_DEPTH
                        ),
                    size: snapshotPmmrSize - (snapshotPmmrSize % BLOCK_BATCH_SIZE)
                });

                bytes32 snapshotLeaf = MerkleMountainRange.fromPeaks(
                    mmrWitness.mmrComplementOrPeaks, 0, BLOCK_BATCH_DEPTH
                ).getZeroPaddedMerkleRoot(BLOCK_BATCH_DEPTH);

                snapshotPmmr.updatePaddedLeaf(BLOCK_BATCH_SIZE, snapshotLeaf, snapshotPmmrSize % BLOCK_BATCH_SIZE);
                bytes32 snapshotPmmrKeccak = snapshotPmmr.commit();

                if (snapshotPmmrKeccak != IAxiomV2State(axiomCoreAddress).pmmrSnapshots(snapshotPmmrSize)) {
                    revert BlockhashMmrKeccakDoesNotMatchProof();
                }

                // check appending to the committed MMR with recent blocks will yield the claimed MMR

                uint256 appendRemaining;
                unchecked {
                    // in this branch, proofMmrSize > snapshotPmmrSize
                    appendRemaining = proofMmrSize - snapshotPmmrSize;
                }
                bytes32[] memory append = new bytes32[](appendRemaining);

                for (uint256 idx; idx < appendRemaining;) {
                    unchecked {
                        append[idx] = blockhash(snapshotPmmrSize + idx);
                    }
                    unchecked {
                        ++idx;
                    }
                }

                MerkleMountainRange.MMR memory snapshotMmr =
                    MerkleMountainRange.fromPeaks(mmrWitness.mmrComplementOrPeaks);
                snapshotMmr.appendLeaves(append);

                uint256 snapshotMmrPeaksLength = snapshotMmr.peaksLength;
                for (uint256 idx; idx < snapshotMmrPeaksLength;) {
                    if (snapshotMmr.peaks[idx] != peaks[idx]) {
                        revert ClaimedMmrDoesNotMatchRecent();
                    }
                    unchecked {
                        ++idx;
                    }
                }
            } else if (proofMmrSize >= block.number - 256) {
                if (proofMmrSize > corePmmrSize) {
                    revert NoMoreRecentBlockhashPmmr();
                }

                uint256 appendRemaining;
                unchecked {
                    // in this branch, corePmmrSize >= proofMmrSize
                    appendRemaining = corePmmrSize - proofMmrSize;
                }
                bytes32[] memory append = new bytes32[](appendRemaining);
                for (uint256 idx; idx < appendRemaining;) {
                    unchecked {
                        append[idx] = blockhash(proofMmrSize + idx);
                    }
                    unchecked {
                        ++idx;
                    }
                }

                MerkleMountainRange.MMR memory proofMmr = MerkleMountainRange.fromPeaks(peaks);
                proofMmr.appendLeaves(append);

                PaddedMerkleMountainRange.PMMR memory completePmmr = PaddedMerkleMountainRange.PMMR({
                    paddedLeaf: proofMmr.getZeroPaddedMerkleRoot(BLOCK_BATCH_DEPTH),
                    completeLeaves: proofMmr.getCompleteLeaves(BLOCK_BATCH_DEPTH),
                    size: corePmmrSize
                });
                bytes32 completePmmrKeccak = completePmmr.commit();
                if (completePmmrKeccak != IAxiomV2State(axiomCoreAddress).pmmrSnapshots(corePmmrSize)) {
                    revert BlockhashMmrKeccakDoesNotMatchProof();
                }
            } else {
                revert BlockHashWitnessNotRecent();
            }
        }
    }

    /// @inheritdoc IAxiomV2HeaderVerifier
    function getSourceChainId() external view returns (uint64) {
        return _CHAIN_ID;
    }

    /// @notice Implements ERC-165 interface check
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IAxiomV2HeaderVerifier).interfaceId;
    }
}
