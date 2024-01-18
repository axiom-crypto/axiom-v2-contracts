// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Hash
/// @notice Gas-optimized library for computing packed Keccak hashes
library Hash {
    /// @notice Compute the Keccak hash of the packed values `keccak(a || b)`
    ///         Gas-optimized equivalent of `keccak256(abi.encodePacked(a, b))`
    function keccak(bytes32 a, bytes32 b) internal pure returns (bytes32 hash) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            hash := keccak256(0x00, 0x40)
        }
    }
}
