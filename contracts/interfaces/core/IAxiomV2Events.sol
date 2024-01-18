// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAxiomV2Events {
    /// @notice Error returned when the SNARK verification fails
    error SNARKVerificationFailed();

    /// @notice Error returned when block header verification fails
    error AxiomBlockVerificationFailed();

    /// @notice Error returned when the length of block header chain verified in a proof is inconsistent
    ///         with other data.
    error IncorrectNumberOfBlocks();

    /// @notice Error returned when the first block hash in a chain is not consistent with other dat.
    error StartingBlockNotValid();

    /// @notice Error returned when the last block hash in a chain is not in the window of 256 recent block hashes.
    error NotRecentEndBlock();

    /// @notice Error returned when the last block hash in a chain is not consistent with other data.
    error BlockHashIncorrect();

    /// @notice Error returned when a Merkle proof verification fails.
    error MerkleProofFailed();

    /// @dev Error returned if the prover address is 0.
    error VerifierAddressIsZero();

    /// @dev Error returned if the prover address is 0.
    error HistoricalVerifierAddressIsZero();

    /// @dev Error returned if the timelock address is 0.
    error TimelockAddressIsZero();

    /// @dev Error returned if the guardian address is 0.
    error GuardianAddressIsZero();

    /// @dev Error returned if the unfreeze address is 0.
    error UnfreezeAddressIsZero();

    /// @dev Error returned if the prover address is 0.
    error ProverAddressIsZero();

    /// @notice Emitted when a new batch of consecutive blocks is trustlessly verified and cached in the contract storage `historicalRoots`
    /// @param  startBlockNumber The block number of the first block in the batch
    /// @param  prevHash The parent hash of block `startBlockNumber`
    /// @param  root The Merkle root of hash(i) for i in [0, 1024), where hash(i) is the blockhash of block `startBlockNumber + i` if i < numFinal,
    ///              Otherwise hash(i) = bytes32(0x0) if i >= numFinal
    /// @param  numFinal The number of consecutive blocks in this batch, i.e., [startBlockNumber, startBlockNumber + numFinal) blocks are verified
    event HistoricalRootUpdated(uint32 indexed startBlockNumber, bytes32 prevHash, bytes32 root, uint32 numFinal);

    /// @notice Emitted when the size of `blockhashPmmr` changes.
    /// @param  commitment Commitment to `blockhashPmmr` as computed by `PaddedMerkleMountainRange.commit`
    /// @param  pmmrSize The `blockhashPmmr` now commits to block hashes `[0, endBlockNumber)`
    event PaddedMerkleMountainRangeUpdated(bytes32 indexed commitment, uint32 pmmrSize);

    /// @notice Emitted when the SNARK verifierAddress changes
    /// @param  newAddress The new address of the SNARK verifier contract
    event UpgradeSnarkVerifier(address newAddress);

    /// @notice Emitted when the SNARK historicalVerifierAddress changes
    /// @param  newAddress The new address of the SNARK historical verifier contract
    event UpgradeHistoricalSnarkVerifier(address newAddress);
}
