// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Constants and free functions to be inlined into by AxiomV2Core and AxiomV2Query

/*
 * Constants for AxiomV2Core
 */

// AxiomV2Core caches blockhashes in batches, stored as Merkle roots of binary Merkle trees
uint32 constant BLOCK_BATCH_SIZE = 1024;
uint32 constant BLOCK_BATCH_DEPTH = 10;

// constants for batch import of historical block hashes
// historical uploads a bigger batch of block hashes, stored as Merkle roots of binary Merkle trees
uint32 constant HISTORICAL_BLOCK_BATCH_SIZE = 131_072; // 2 ** 17
uint32 constant HISTORICAL_BLOCK_BATCH_DEPTH = 17;
// we will consider the historical Merkle tree of blocks as a Merkle tree of the block batch roots
uint32 constant HISTORICAL_NUM_ROOTS = 128; // HISTORICAL_BATCH_SIZE / BLOCK_BATCH_SIZE

// The first 4 * 3 * 32 bytes of proof calldata are reserved for two BN254 G1 points for a pairing check
// It will then be followed by (7 + BLOCK_BATCH_DEPTH * 2) * 32 bytes of public inputs/outputs
uint32 constant PUBLIC_BYTES_START_IDX = 384; // 4 * 3 * 32
uint32 constant AUX_PEAKS_START_IDX = 608; // PUBLIC_BYTES_START_IDX + 7 * 32

/// @notice Read public instances from the ZK proof
/// @param  proofData the entire ZK proof
/// @return prevHash the hash of the previous block
/// @return endHash the hash of the last block in the batch
/// @return startBlockNumber the block number of the first block in the batch
/// @return endBlockNumber the block number of the last block in the batch
/// @return root the Merkle root of the 0-padded batch of blocks
/// @dev proofData stores bytes32 and uint256 values in hi-lo format as two uint128 values because the BN254 scalar field is 254 bits
/// @dev The first 12 * 32 bytes of proofData are reserved for ZK proof verification data
// Extract public instances from proof
// The public instances are laid out in the proof calldata as follows:
// First 4 * 3 * 32 = 384 bytes are reserved for proof verification data used with the pairing precompile
// 384..384 + 32 * 2: prevHash (32 bytes) as two uint128 cast to uint256, because zk proof uses 254 bit field and cannot fit uint256 into a single element
// 384 + 32 * 2..384 + 32 * 4: endHash (32 bytes) as two uint128 cast to uint256
// 384 + 32 * 4..384 + 32 * 5: startBlockNumber (uint32: 4 bytes) and endBlockNumber (uint32: 4 bytes) are concatenated as `startBlockNumber . endBlockNumber` (8 bytes) and then cast to uint256
// 384 + 32 * 5..384 + 32 * 7: root (32 bytes) as two uint128 cast to uint256, this is the highest peak of the MMR if endBlockNumber - startBlockNumber == 1023, otherwise 0
function getBoundaryBlockData(bytes calldata proofData)
    pure
    returns (bytes32 prevHash, bytes32 endHash, uint32 startBlockNumber, uint32 endBlockNumber, bytes32 root)
{
    prevHash =
        bytes32(uint256(bytes32(proofData[PUBLIC_BYTES_START_IDX:416])) << 128 | uint256(bytes32(proofData[416:448])));
    endHash = bytes32(uint256(bytes32(proofData[448:480])) << 128 | uint256(bytes32(proofData[480:512])));
    startBlockNumber = uint32(bytes4(proofData[536:540]));
    endBlockNumber = uint32(bytes4(proofData[540:544]));
    root = bytes32(uint256(bytes32(proofData[544:576])) << 128 | uint256(bytes32(proofData[576:AUX_PEAKS_START_IDX])));
}

// We have a Merkle mountain range of max depth BLOCK_BATCH_DEPTH (so length BLOCK_BATCH_DEPTH + 1 total) ordered in **decreasing** order of peak size, so:
// `root` from `getBoundaryBlockData` is the peak for depth BLOCK_BATCH_DEPTH
// `getAuxMmrPeak(proofData, i)` is the peaks for depth BLOCK_BATCH_DEPTH - 1 - i
// 384 + 32 * 7 + 32 * 2 * i .. 384 + 32 * 7 + 32 * 2 * (i + 1): (32 bytes) as two uint128 cast to uint256, same as blockHash
// Note that the decreasing ordering is *different* than the convention in library MerkleMountainRange
function getAuxMmrPeak(bytes calldata proofData, uint256 i) pure returns (bytes32) {
    return bytes32(
        uint256(bytes32(proofData[AUX_PEAKS_START_IDX + i * 64:AUX_PEAKS_START_IDX + i * 64 + 32])) << 128
            | uint256(bytes32(proofData[AUX_PEAKS_START_IDX + i * 64 + 32:AUX_PEAKS_START_IDX + (i + 1) * 64]))
    );
}

/*
 * Constants for AxiomV2Query
 */

/// @dev Chain IDs for Ethereum mainnet and testnets
uint64 constant MAINNET_CHAIN_ID = 1;
uint64 constant GOERLI_CHAIN_ID = 5;
uint64 constant SEPOLIA_CHAIN_ID = 11_155_111;
uint64 constant HOLESKY_CHAIN_ID = 17_000;

/// @dev Constant recording the fact that this is Axiom V2
uint8 constant VERSION = 2;

/// @dev Largest deposit allowed at one time
uint256 constant MAX_DEPOSIT_SIZE = 100 ether;

/// @dev Conservative upper bound for `proofVerificationGas`.  Real values should be lower.
uint32 constant MAX_PROOF_VERIFICATION_GAS = 600_000;

/// @dev Conservative upper bound for `axiomQueryFee`. Real values should be lower.
uint256 constant MAX_AXIOM_QUERY_FEE = 0.05 ether;
