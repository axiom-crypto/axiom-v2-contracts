// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { AxiomAccess } from "../libraries/access/AxiomAccess.sol";
import { IAxiomV2HeaderVerifier } from "../interfaces/query/IAxiomV2HeaderVerifier.sol";
import { IAxiomV2State } from "../interfaces/core/IAxiomV2State.sol";
import { MerkleMountainRange, MAX_MMR_PEAKS } from "../libraries/MerkleMountainRange.sol";
import { PaddedMerkleMountainRange } from "../libraries/PaddedMerkleMountainRange.sol";
import { BLOCK_BATCH_DEPTH, BLOCK_BATCH_SIZE } from "../libraries/configuration/AxiomV2Configuration.sol";

contract AxiomV2HeaderVerifier is IAxiomV2HeaderVerifier, AxiomAccess, UUPSUpgradeable {
    using PaddedMerkleMountainRange for PaddedMerkleMountainRange.PMMR;
    using MerkleMountainRange for MerkleMountainRange.MMR;

    address public axiomCoreAddress;

    uint64 internal immutable _CHAIN_ID;

    /// @custom:oz-upgrades-unsafe-allow constructor
    /// @notice Prevents the implementation contract from being initialized outside of the upgradeable proxy.
    constructor(uint64 chainId) {
        _CHAIN_ID = chainId;

        _disableInitializers();
    }

    /// @dev Initialize the contract.
    /// @param _axiomCoreAddress The address of the AxiomV2Core contract.
    /// @param timelock The address with the permission of a 'timelock'.
    /// @param guardian The address with the permission of a 'guardian'.
    /// @param unfreeze The address with the permission of a 'unfreeze'.
    function initialize(address _axiomCoreAddress, address timelock, address guardian, address unfreeze)
        public
        initializer
    {
        __UUPSUpgradeable_init();
        __AxiomAccess_init_unchained();

        if (_axiomCoreAddress == address(0)) {
            revert AxiomCoreAddressIsZero();
        }
        if (timelock == address(0)) {
            revert TimelockAddressIsZero();
        }
        if (guardian == address(0)) {
            revert GuardianAddressIsZero();
        }
        if (unfreeze == address(0)) {
            revert UnfreezeAddressIsZero();
        }

        axiomCoreAddress = _axiomCoreAddress;
        emit UpdateAxiomCoreAddress(_axiomCoreAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, timelock);
        _grantRole(TIMELOCK_ROLE, timelock);
        _grantRole(GUARDIAN_ROLE, guardian);
        _grantRole(UNFREEZE_ROLE, unfreeze);
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
    ///           -- TODO: `queryBlockNum` is no longer recent, we can pass enough witness data to extend `blockhashMmrKeccak`
    ///              to the transaction submission chain head.  If this chain head is still recent, then we can verify
    ///              against a recent `blockhashPmmr` using recent blockhashes.
    ///           -- If the chain head at time of transaction submission is no longer recent, the transaction will fail.
    ///              In this case, we should resubmit with the new recent `blockhashPmmr` at time of transaction execution.
    function verifyQueryHeaders(bytes32 proofMmrKeccak, MmrWitness calldata mmrWitness) external view onlyNotFrozen {
        if (proofMmrKeccak != keccak256(abi.encodePacked(mmrWitness.proofMmrPeaks))) {
            revert ProofMmrKeccakDoesNotMatch();
        }

        uint32 proofMmrSize;
        uint32 proofMmrPeaksLength = uint32(mmrWitness.proofMmrPeaks.length);
        // Get proofMmrSize from heights of witnessMmrPeaks
        for (uint32 idx; idx < proofMmrPeaksLength;) {
            if (mmrWitness.proofMmrPeaks[idx] != bytes32(0)) {
                proofMmrSize = proofMmrSize + uint32(1 << idx);
            }
            unchecked {
                ++idx;
            }
        }

        if (proofMmrSize <= mmrWitness.snapshotPmmrSize) {
            // Creating a proof PMMR with empty padded leaf and complete leaf peaks from proofMmrPeaks[BLOCK_BATCH_DEPTH:]
            PaddedMerkleMountainRange.PMMR memory proofPmmr = PaddedMerkleMountainRange.PMMR({
                paddedLeaf: bytes32(0),
                completeLeaves: MerkleMountainRange.fromPeaks(
                    mmrWitness.proofMmrPeaks, BLOCK_BATCH_DEPTH, proofMmrPeaksLength - BLOCK_BATCH_DEPTH
                    ),
                size: proofMmrSize - (proofMmrSize % BLOCK_BATCH_SIZE)
            });

            MerkleMountainRange.MMR memory proofBatchMmr =
                MerkleMountainRange.fromPeaks(mmrWitness.proofMmrPeaks, 0, BLOCK_BATCH_DEPTH);

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

            if (mmrWitness.snapshotPmmrSize - (mmrWitness.snapshotPmmrSize % BLOCK_BATCH_SIZE) >= proofMmrSize) {
                if (proofMmrSize % BLOCK_BATCH_SIZE > 0) {
                    // complete the first 10 peaks of `proofMmrPeaks` to a full Merkle root and update `proofPmmr`
                    bytes32 completedLeaf =
                        proofBatchMmr.getComplementMerkleRoot(BLOCK_BATCH_DEPTH, mmrWitness.mmrComplementOrPeaks);
                    proofPmmr.updatePaddedLeaf(BLOCK_BATCH_SIZE, completedLeaf, BLOCK_BATCH_SIZE);
                }

                if (mmrWitness.snapshotPmmrSize - (mmrWitness.snapshotPmmrSize % BLOCK_BATCH_SIZE) > proofMmrSize) {
                    // append additional complete leaves
                    proofPmmr.appendCompleteLeaves(BLOCK_BATCH_SIZE, mmrWitness.mmrComplementOrPeaks[11:]);
                }

                proofPmmr.updatePaddedLeaf(
                    BLOCK_BATCH_SIZE,
                    mmrWitness.mmrComplementOrPeaks[10],
                    mmrWitness.snapshotPmmrSize % BLOCK_BATCH_SIZE
                );
            } else {
                // complete the first 10 peaks of `proofMmrPeaks` to a full Merkle root and update `proofPmmr`
                bytes32 completedLeaf =
                    proofBatchMmr.getComplementMerkleRoot(BLOCK_BATCH_DEPTH, mmrWitness.mmrComplementOrPeaks);
                proofPmmr.updatePaddedLeaf(
                    BLOCK_BATCH_SIZE, completedLeaf, mmrWitness.snapshotPmmrSize % BLOCK_BATCH_SIZE
                );
            }

            // check the resulting PMMR is committed to in `pmmrSnapshots[mmrWitness.snapshotPmmrSize]`
            bytes32 completePmmrKeccak = proofPmmr.commit();
            if (completePmmrKeccak != IAxiomV2State(axiomCoreAddress).pmmrSnapshots(mmrWitness.snapshotPmmrSize)) {
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
                mmrWitness.snapshotPmmrSize >= block.number - 256
                    && (
                        proofMmrSize > corePmmrSize
                            || proofMmrSize - mmrWitness.snapshotPmmrSize <= corePmmrSize - proofMmrSize
                    )
            ) {
                // Decommit the PMMR in `pmmrSnapshots[mmrWitness.snapshotPmmrSize]`
                PaddedMerkleMountainRange.PMMR memory snapshotPmmr = PaddedMerkleMountainRange.PMMR({
                    paddedLeaf: bytes32(0),
                    completeLeaves: MerkleMountainRange.fromPeaks(
                        mmrWitness.mmrComplementOrPeaks,
                        BLOCK_BATCH_DEPTH,
                        uint32(mmrWitness.mmrComplementOrPeaks.length) - BLOCK_BATCH_DEPTH
                        ),
                    size: mmrWitness.snapshotPmmrSize - (mmrWitness.snapshotPmmrSize % BLOCK_BATCH_SIZE)
                });

                bytes32 snapshotLeaf = MerkleMountainRange.fromPeaks(
                    mmrWitness.mmrComplementOrPeaks, 0, BLOCK_BATCH_DEPTH
                ).getZeroPaddedMerkleRoot(BLOCK_BATCH_DEPTH);

                snapshotPmmr.updatePaddedLeaf(
                    BLOCK_BATCH_SIZE, snapshotLeaf, mmrWitness.snapshotPmmrSize % BLOCK_BATCH_SIZE
                );
                bytes32 snapshotPmmrKeccak = snapshotPmmr.commit();

                if (snapshotPmmrKeccak != IAxiomV2State(axiomCoreAddress).pmmrSnapshots(mmrWitness.snapshotPmmrSize)) {
                    revert BlockhashMmrKeccakDoesNotMatchProof();
                }

                // check appending to the committed MMR with recent blocks will yield the claimed MMR
                uint256 appendRemaining = proofMmrSize - mmrWitness.snapshotPmmrSize;
                bytes32[] memory append = new bytes32[](appendRemaining);

                for (uint256 idx; idx < appendRemaining;) {
                    append[idx] = blockhash(mmrWitness.snapshotPmmrSize + idx);
                    unchecked {
                        ++idx;
                    }
                }

                MerkleMountainRange.MMR memory snapshotMmr =
                    MerkleMountainRange.fromPeaks(mmrWitness.mmrComplementOrPeaks);
                snapshotMmr.appendLeaves(append);

                for (uint256 idx; idx < snapshotMmr.peaksLength;) {
                    if (snapshotMmr.peaks[idx] != mmrWitness.proofMmrPeaks[idx]) {
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

                uint256 appendRemaining = corePmmrSize - proofMmrSize;
                bytes32[] memory append = new bytes32[](appendRemaining);

                for (uint256 idx; idx < appendRemaining;) {
                    append[idx] = blockhash(proofMmrSize + idx);
                    unchecked {
                        ++idx;
                    }
                }

                MerkleMountainRange.MMR memory proofMmr = MerkleMountainRange.fromPeaks(mmrWitness.proofMmrPeaks);
                proofMmr.appendLeaves(append);

                MerkleMountainRange.MMR memory corePmmrPeaks = IAxiomV2State(axiomCoreAddress).blockhashPmmrPeaks();
                for (uint32 idx; idx < proofMmrPeaksLength - BLOCK_BATCH_DEPTH;) {
                    if (corePmmrPeaks.peaks[idx] != proofMmr.peaks[idx + BLOCK_BATCH_DEPTH]) {
                        revert ClaimedMmrDoesNotMatchRecent();
                    }
                    unchecked {
                        ++idx;
                    }
                }

                bytes32 resultLeaf = proofMmr.getZeroPaddedMerkleRoot(BLOCK_BATCH_DEPTH);
                if (resultLeaf != IAxiomV2State(axiomCoreAddress).blockhashPmmrLeaf()) {
                    revert ClaimedMmrDoesNotMatchRecent();
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(IAxiomV2HeaderVerifier).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address) internal override onlyRole(TIMELOCK_ROLE) { }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[40] private __gap;
}
