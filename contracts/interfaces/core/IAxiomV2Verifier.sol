// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAxiomV2Verifier {
    /// @notice Witness data needed to verify a block against the verified blocks cached by AxiomV2Core
    /// @param  blockNumber The block number to verify
    /// @param  claimedBlockHash The claimed blockhash of block `blockNumber`
    /// @param  prevHash The parent hash of the first block in the batch containing block `blockNumber`
    /// @param  numFinal The number of consecutive blocks verified in this batch
    /// @param  merkleProof The Merkle inclusion proof of `claimedBlockHash` to the root of the batch
    struct BlockHashWitness {
        uint32 blockNumber;
        bytes32 claimedBlockHash;
        bytes32 prevHash;
        uint32 numFinal;
        bytes32[] merkleProof;
    }

    /// @notice Verify the blockhash of block blockNumber equals claimedBlockHash. Assumes that blockNumber is within the last 256 most recent blocks.
    /// @param  blockNumber The block number to verify
    /// @param  claimedBlockHash The claimed blockhash of block blockNumber
    function isRecentBlockHashValid(uint32 blockNumber, bytes32 claimedBlockHash) external view returns (bool);

    /// @notice Verify the blockhash of block witness.blockNumber equals witness.claimedBlockHash by checking against Axiom's cache of #historicalRoots.
    /// @dev    For block numbers within the last 256, use #isRecentBlockHashValid instead.
    /// @param  witness The block hash to verify and the Merkle proof to verify it
    ///         witness.blockNumber is the block number to verify
    ///         witness.claimedBlockHash is the claimed blockhash of block witness.blockNumber
    ///         witness.prevHash is the prevHash stored in #historicalRoots(witness.blockNumber - witness.blockNumber % 1024)
    ///         witness.numFinal is the numFinal stored in #historicalRoots(witness.blockNumber - witness.blockNumber % 1024)
    ///         witness.merkleProof is the Merkle inclusion proof of witness.claimedBlockHash to the root stored in #historicalRoots(witness.blockNumber - witness.blockNumber % 1024)
    ///         witness.merkleProof[i] is the sibling of the Merkle node at depth 10 - i, for i = 0, ..., 10
    function isBlockHashValid(BlockHashWitness calldata witness) external view returns (bool);
}
