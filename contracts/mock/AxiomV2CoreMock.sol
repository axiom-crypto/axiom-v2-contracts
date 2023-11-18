// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { AxiomAccess } from "../libraries/access/AxiomAccess.sol";
import { IAxiomV2Core } from "../interfaces/core/IAxiomV2Core.sol";
import { MerkleTree } from "../libraries/MerkleTree.sol";
import { MerkleMountainRange } from "../libraries/MerkleMountainRange.sol";
import { PaddedMerkleMountainRange } from "../libraries/PaddedMerkleMountainRange.sol";
import { Hash } from "../libraries/Hash.sol";
import {
    BLOCK_BATCH_DEPTH,
    BLOCK_BATCH_SIZE,
    HISTORICAL_BLOCK_BATCH_SIZE,
    HISTORICAL_NUM_ROOTS,
    getAuxMmrPeak,
    getBoundaryBlockData
} from "../libraries/configuration/AxiomV2Configuration.sol";

/// @title  AxiomV2CoreMock
/// @notice Mock version of core Axiom smart contract that verifies the validity of historical block hashes using SNARKs.
/// @dev    For use in a UUPS upgradeable contract.
contract AxiomV2CoreMock is IAxiomV2Core, AxiomAccess, UUPSUpgradeable {
    using { MerkleTree.merkleRoot } for bytes32[HISTORICAL_NUM_ROOTS];
    using PaddedMerkleMountainRange for PaddedMerkleMountainRange.PMMR;
    using MerkleMountainRange for MerkleMountainRange.MMR;

    /// @dev The verifier address for block header hash chains of up to 1024 block headers.
    address public verifierAddress;

    /// @dev The verifier address for historic block header hash chains.
    address public historicalVerifierAddress;

    /// @dev `historicalRoots[startBlockNumber]` is 0 unless `startBlockNumber % 1024 = 0`
    ///      `historicalRoots(startBlockNumber) = 0` if block `startBlockNumber` is not verified
    ///      `historicalRoots(startBlockNumber) = keccak256(prevHash || root || numFinal)` where || is concatenation
    ///         - `prevHash` is the parent hash of block `startBlockNumber`
    ///         - `root` is the Keccak Merkle root of hash(i) for i in [0, 1024), where
    ///             hash(i) is the blockhash of block `startBlockNumber + i` if i < numFinal,
    ///             hash(i) = bytes32(0x0) if i >= numFinal
    ///         - `0 < numFinal <= 1024` is the number of verified consecutive roots in [startBlockNumber, startBlockNumber + numFinal)
    mapping(uint32 => bytes32) public historicalRoots;

    /// @dev `blockhashPmmr` is the current PMMR commitment to historic block hashes
    ///      A commitment to each `blockhashPmmr` stored in the state is guaranteed to have been stored in `pmmrSnapshots`
    PaddedMerkleMountainRange.PMMR public blockhashPmmr;

    /// @dev Snapshots of commitments to `blockhashPmmr` as computed by `PaddedMerkleMountainRange.commit`
    ///      `pmmrSnapshots[pmmrSize]` is a commitment to block hashes for blocks `[0, pmmrSize)`
    mapping(uint32 => bytes32) public pmmrSnapshots;

    /// @custom:oz-upgrades-unsafe-allow constructor
    /// @notice Prevents the implementation contract from being initialized outside of the upgradeable proxy.
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the contract and the parent contracts once.
    /// @param  _verifierAddress The address of the SNARK verifier contract for `updateRecent` and `updateOld`
    /// @param  _historicalVerifierAddress The address of the SNARK verifier contract for `updateHistorical`
    /// @param  timelock The address of the timelock contract.
    /// @param  guardian The address of the guardian contract.
    /// @param  unfreeze The address of the unfreeze contract.
    /// @param  prover The address of the prover contract.
    function initialize(
        address _verifierAddress,
        address _historicalVerifierAddress,
        address timelock,
        address guardian,
        address unfreeze,
        address prover
    ) public initializer {
        if (_verifierAddress == address(0)) {
            revert VerifierAddressIsZero();
        }
        if (_historicalVerifierAddress == address(0)) {
            revert HistoricalVerifierAddressIsZero();
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
        if (prover == address(0)) {
            revert ProverAddressIsZero();
        }
        __UUPSUpgradeable_init();
        __AxiomAccess_init_unchained();

        verifierAddress = _verifierAddress;
        historicalVerifierAddress = _historicalVerifierAddress;
        emit UpgradeSnarkVerifier(_verifierAddress);
        emit UpgradeHistoricalSnarkVerifier(_historicalVerifierAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, timelock);
        _grantRole(TIMELOCK_ROLE, timelock);
        _grantRole(PROVER_ROLE, prover);
        _grantRole(GUARDIAN_ROLE, guardian);
        _grantRole(UNFREEZE_ROLE, unfreeze);
    }

    function updateRecent(bytes calldata proofData) external onlyProver onlyNotFrozen {
        (bytes32 prevHash, bytes32 endHash, uint32 startBlockNumber, uint32 endBlockNumber, bytes32 root) =
            getBoundaryBlockData(proofData);
        // See `getBoundaryBlockData` comments for initial `proofData` formatting

        uint32 numFinal = endBlockNumber - startBlockNumber + 1;
        if (numFinal > BLOCK_BATCH_SIZE) {
            revert IncorrectNumberOfBlocks();
        }
        if (startBlockNumber % BLOCK_BATCH_SIZE != 0) {
            revert StartingBlockNotValid();
        }
        if (endBlockNumber >= block.number) {
            revert NotRecentEndBlock();
        }
        if (block.number - endBlockNumber > 256) {
            revert NotRecentEndBlock();
        }
        if (blockhash(endBlockNumber) != endHash) {
            revert BlockHashIncorrect();
        }

        if (!_verifyRaw(proofData)) {
            revert SNARKVerificationFailed();
        }

        PaddedMerkleMountainRange.PMMR memory pmmr = blockhashPmmr.clone();

        if (root == bytes32(0)) {
            // We have a Merkle mountain range of max depth 10 (so length 11 total) ordered in **decreasing** order of peak size, so:
            // `root` (above) is the peak for depth 10
            // `roots` below are the peaks for depths 9..0 where `roots[i]` is for depth `9 - i`
            // 384 + 32 * 7 + 32 * 2 * i .. 384 + 32 * 7 + 32 * 2 * (i + 1): `roots[i]` (32 bytes) as two uint128 cast to uint256, same as blockHash
            // Note that the decreasing ordering is *different* than the convention in library MerkleMountainRange

            // compute Merkle root of completed Merkle mountain range with 0s for unconfirmed blockhashes
            for (uint256 round; round < BLOCK_BATCH_DEPTH;) {
                bytes32 peak = getAuxMmrPeak(proofData, BLOCK_BATCH_DEPTH - 1 - round);
                if (peak != 0) {
                    root = Hash.keccak(peak, root);
                } else {
                    root = Hash.keccak(root, MerkleTree.getEmptyHash(round));
                }
                unchecked {
                    ++round;
                }
            }
        }

        // The `blockhashPmmr` commits to block hashes in the range `[0, pmmrSize)`, and the proof
        // establishes a Keccak chain of blocks in the range `[startBlockNumber, endBlockNumber]`,
        // so we can extend `blockhashPmmr` so long as `size` lies in `[startBlockNumber, endBlockNumber]`.
        if (pmmr.size >= startBlockNumber && pmmr.size <= endBlockNumber) {
            // updating PMMR with the latest padded leaf
            uint32 peaksChanged = pmmr.updatePaddedLeaf(BLOCK_BATCH_SIZE, root, numFinal);
            blockhashPmmr.persistFrom(pmmr, peaksChanged);

            bytes32 blockhashPmmrKeccak = pmmr.commit();
            pmmrSnapshots[endBlockNumber + 1] = blockhashPmmrKeccak;

            emit PaddedMerkleMountainRangeUpdated(blockhashPmmrKeccak, pmmr.size);
        }

        historicalRoots[startBlockNumber] = keccak256(abi.encodePacked(prevHash, root, numFinal));
        emit HistoricalRootUpdated(startBlockNumber, prevHash, root, numFinal);
    }

    function updateOld(bytes32 nextRoot, uint32 nextNumFinal, bytes calldata proofData)
        external
        onlyProver
        onlyNotFrozen
    {
        (bytes32 prevHash, bytes32 endHash, uint32 startBlockNumber, uint32 endBlockNumber, bytes32 root) =
            getBoundaryBlockData(proofData);

        if (startBlockNumber % BLOCK_BATCH_SIZE != 0) {
            revert StartingBlockNotValid();
        }
        if (endBlockNumber - startBlockNumber != BLOCK_BATCH_SIZE - 1) {
            revert IncorrectNumberOfBlocks();
        }

        if (historicalRoots[endBlockNumber + 1] != keccak256(abi.encodePacked(endHash, nextRoot, nextNumFinal))) {
            revert BlockHashIncorrect();
        }

        if (!_verifyRaw(proofData)) {
            revert SNARKVerificationFailed();
        }

        historicalRoots[startBlockNumber] = keccak256(abi.encodePacked(prevHash, root, BLOCK_BATCH_SIZE));
        emit HistoricalRootUpdated(startBlockNumber, prevHash, root, BLOCK_BATCH_SIZE);
    }

    /// @dev endHashProofs is length HISTORICAL_NUM_ROOTS - 1 because the last endHash is provided in proofData
    function updateHistorical(
        bytes32 nextRoot,
        uint32 nextNumFinal,
        bytes32[HISTORICAL_NUM_ROOTS] calldata roots,
        bytes32[BLOCK_BATCH_DEPTH + 1][HISTORICAL_NUM_ROOTS - 1] calldata endHashProofs,
        bytes calldata proofData
    ) external onlyProver onlyNotFrozen {
        (bytes32 _prevHash, bytes32 _endHash, uint32 startBlockNumber, uint32 endBlockNumber, bytes32 aggregateRoot) =
            getBoundaryBlockData(proofData);

        if (startBlockNumber % BLOCK_BATCH_SIZE != 0) {
            revert StartingBlockNotValid();
        }
        if (endBlockNumber - startBlockNumber != HISTORICAL_BLOCK_BATCH_SIZE - 1) {
            revert IncorrectNumberOfBlocks();
        }

        if (historicalRoots[endBlockNumber + 1] != keccak256(abi.encodePacked(_endHash, nextRoot, nextNumFinal))) {
            revert BlockHashIncorrect();
        }
        if (roots.merkleRoot() != aggregateRoot) {
            revert MerkleProofFailed();
        }

        if (!_verifyHistoricalRaw(proofData)) {
            revert SNARKVerificationFailed();
        }

        for (uint256 i; i < HISTORICAL_NUM_ROOTS;) {
            if (i != HISTORICAL_NUM_ROOTS - 1) {
                bytes32 proofCheck = endHashProofs[i][BLOCK_BATCH_DEPTH];
                for (uint256 j; j < BLOCK_BATCH_DEPTH;) {
                    proofCheck = Hash.keccak(endHashProofs[i][BLOCK_BATCH_DEPTH - 1 - j], proofCheck);
                    unchecked {
                        ++j;
                    }
                }
                if (proofCheck != roots[i]) {
                    revert MerkleProofFailed();
                }
            }
            bytes32 prevHash = i == 0 ? _prevHash : endHashProofs[i - 1][BLOCK_BATCH_DEPTH];
            uint32 start = uint32(startBlockNumber + i * BLOCK_BATCH_SIZE);
            historicalRoots[start] = keccak256(abi.encodePacked(prevHash, roots[i], BLOCK_BATCH_SIZE));
            emit HistoricalRootUpdated(start, prevHash, roots[i], BLOCK_BATCH_SIZE);
            unchecked {
                ++i;
            }
        }
    }

    function appendHistoricalPMMR(
        uint32 startBlockNumber,
        bytes32[] calldata roots,
        bytes32[] calldata prevHashes,
        uint32 lastNumFinal
    ) external onlyNotFrozen {
        PaddedMerkleMountainRange.PMMR memory pmmr = blockhashPmmr.clone(); // to compute total change

        if (
            roots.length == 0 // must append non-empty list
                || roots.length != prevHashes.length // roots and prevHashes must be same length
                || startBlockNumber != pmmr.size - (pmmr.size % BLOCK_BATCH_SIZE) // startBlockNumber must be the size of completed leaves in PMMR
        ) {
            revert IncorrectNumberOfBlocks();
        }

        // To append complete leaves to the PMMR, first remove any non-empty padded leaf
        pmmr.updatePaddedLeaf(BLOCK_BATCH_SIZE, bytes32(0x0), 0);

        // check all complete leaves
        for (uint256 i; i < roots.length - 1;) {
            bytes32 commitment = keccak256(abi.encodePacked(prevHashes[i], roots[i], BLOCK_BATCH_SIZE));
            if (historicalRoots[startBlockNumber] != commitment) {
                revert AxiomBlockVerificationFailed();
            }
            startBlockNumber += BLOCK_BATCH_SIZE;
            unchecked {
                ++i;
            }
        }

        // append all complete leaves
        uint32 peaksChanged = pmmr.appendCompleteLeaves(BLOCK_BATCH_SIZE, roots[:roots.length - 1]);

        // check the last, possibly incomplete leaf
        bytes32 commitment =
            keccak256(abi.encodePacked(prevHashes[roots.length - 1], roots[roots.length - 1], lastNumFinal));
        if (historicalRoots[startBlockNumber] != commitment) {
            revert AxiomBlockVerificationFailed();
        }

        // append the last, possibly incomplete leaf
        uint32 leafPeaksChanged = pmmr.updatePaddedLeaf(BLOCK_BATCH_SIZE, roots[roots.length - 1], lastNumFinal);
        if (leafPeaksChanged > peaksChanged) {
            peaksChanged = leafPeaksChanged;
        }

        bytes32 blockhashPmmrKeccak = pmmr.commit();
        pmmrSnapshots[pmmr.size] = blockhashPmmrKeccak;
        blockhashPmmr.persistFrom(pmmr, peaksChanged);

        emit PaddedMerkleMountainRangeUpdated(blockhashPmmrKeccak, pmmr.size);
    }

    /// @notice Updates the address of the SNARK verifier contract, governed by a 'timelock'.
    ///         To avoid timelock bypass by metamorphic contracts, users should verify that
    ///         the contract deployed at `_verifierAddress` does not contain any `SELFDESTRUCT`
    ///         or `DELEGATECALL` opcodes.
    function upgradeSnarkVerifier(address _verifierAddress) external onlyRole(TIMELOCK_ROLE) {
        if (_verifierAddress == address(0)) {
            revert VerifierAddressIsZero();
        }
        verifierAddress = _verifierAddress;
        emit UpgradeSnarkVerifier(_verifierAddress);
    }

    /// @notice Updates the address of the historical SNARK verifier contract, governed by a 'timelock'.
    ///         To avoid timelock bypass by metamorphic contracts, users should verify that
    ///         the contract deployed at `_historicalVerifierAddress` does not contain any `SELFDESTRUCT`
    ///         or `DELEGATECALL` opcodes.
    /// @dev    We expect this should never need to be called since the historical verifier is only used for the initial batch import of historical block hashes.
    function upgradeHistoricalSnarkVerifier(address _historicalVerifierAddress) external onlyRole(TIMELOCK_ROLE) {
        if (_historicalVerifierAddress == address(0)) {
            revert HistoricalVerifierAddressIsZero();
        }
        historicalVerifierAddress = _historicalVerifierAddress;
        emit UpgradeHistoricalSnarkVerifier(_historicalVerifierAddress);
    }

    function blockhashPmmrLeaf() external view returns (bytes32) {
        return blockhashPmmr.paddedLeaf;
    }

    function blockhashPmmrPeaks() external view returns (MerkleMountainRange.MMR memory) {
        return blockhashPmmr.completeLeaves.clone();
    }

    function blockhashPmmrSize() external view returns (uint32 pmmrSize) {
        return blockhashPmmr.size;
    }

    function fullBlockhashPmmr() external view returns (PaddedMerkleMountainRange.PMMR memory) {
        return blockhashPmmr.clone();
    }

    function isRecentBlockHashValid(uint32 blockNumber, bytes32 claimedBlockHash) public view returns (bool) {
        bytes32 blockHash = blockhash(blockNumber);
        if (blockHash == 0x0) {
            revert BlockHashIncorrect();
        } // Must supply block hash of one of 256 most recent blocks
        return (blockHash == claimedBlockHash);
    }

    function isBlockHashValid(BlockHashWitness calldata witness) public view returns (bool) {
        if (witness.claimedBlockHash == 0x0) {
            revert BlockHashIncorrect();
        } // Claimed block hash cannot be 0
        uint32 side = witness.blockNumber % BLOCK_BATCH_SIZE;
        uint32 startBlockNumber = witness.blockNumber - side;
        bytes32 merkleRoot = historicalRoots[startBlockNumber];
        if (merkleRoot == 0) {
            revert MerkleProofFailed();
        } // Merkle root must be stored already
        // compute Merkle root of blockhash
        bytes32 root = witness.claimedBlockHash;
        for (uint256 i; i < BLOCK_BATCH_DEPTH;) {
            // depth = BLOCK_BATCH_DEPTH - i
            // if i-th bit = 1, proof is on the left, else, proof is on the right
            if ((side >> i) & 1 == 0) {
                root = Hash.keccak(root, witness.merkleProof[i]);
            } else {
                root = Hash.keccak(witness.merkleProof[i], root);
            }
            unchecked {
                ++i;
            }
        }
        return merkleRoot == keccak256(abi.encodePacked(witness.prevHash, root, witness.numFinal));
    }

    /// @dev Verify the SNARK proof for `updateRecent` and `updateOld` methods.
    /// @param input The SNARK proof data.
    /// @return success Whether the SNARK proof is valid.
    function _verifyRaw(bytes calldata input) private returns (bool) {
        return true;
        // (bool success,) = verifierAddress.call(input);
        // return success;
    }

    /// @dev Verify the SNARK proof for `updateHistorical`.
    /// @param input The SNARK proof data.
    /// @return success Whether the SNARK proof is valid.
    function _verifyHistoricalRaw(bytes calldata input) private returns (bool) {
        return true;
        // (bool success,) = historicalVerifierAddress.call(input);
        // return success;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(IAxiomV2Core).interfaceId || super.supportsInterface(interfaceId);
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
