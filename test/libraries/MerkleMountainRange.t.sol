// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import { MerkleMountainRange } from "../../contracts/libraries/MerkleMountainRange.sol";

contract MerkleMountainRangeTest is Test {
    using MerkleMountainRange for MerkleMountainRange.MMR;

    bytes32[] public leaves;
    MerkleMountainRange.MMR public mmr;

    function setUp() public {
        leaves = new bytes32[](2**(17-10));
        for (uint256 i = 0; i < leaves.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(i));
        }

        mmr.peaksLength = 4;
        mmr.peaks[0] = keccak256(abi.encodePacked(uint256(0)));
        mmr.peaks[1] = keccak256(abi.encodePacked(uint256(1)));
        mmr.peaks[2] = keccak256(abi.encodePacked(uint256(2)));
        mmr.peaks[3] = keccak256(abi.encodePacked(uint256(3)));
    }

    function test_fromPeaks() public {
        MerkleMountainRange.MMR memory mmr1;
        mmr1.peaksLength = 2;
        mmr1.peaks[0] = keccak256(abi.encodePacked(uint256(0)));
        mmr1.peaks[1] = keccak256(abi.encodePacked(uint256(1)));

        bytes32[] memory peaks = new bytes32[](2);
        peaks[0] = mmr1.peaks[0];
        peaks[1] = mmr1.peaks[1];

        MerkleMountainRange.MMR memory mmr2 = MerkleMountainRange.fromPeaks(peaks);
        assert(mmr1.peaksLength == mmr2.peaksLength); // "peaksLength do not match");
        for (uint256 i = 0; i < mmr1.peaksLength; i++) {
            assert(mmr1.peaks[i] == mmr2.peaks[i]); // "peaks do not match");
        }

        MerkleMountainRange.MMR memory mmr3 = MerkleMountainRange.fromPeaks(peaks, 1, 1);
        assert(mmr3.peaksLength == 1); // "peaksLength do not match");
        for (uint256 i = 0; i < mmr3.peaksLength; i++) {
            assert(mmr3.peaks[i] == mmr1.peaks[i + 1]); // "peaks do not match");
        }
    }

    function test_clone() public {
        MerkleMountainRange.MMR memory mmr1 = mmr.clone();
        assert(mmr1.peaksLength == mmr.peaksLength); // "peaksLength do not match");
        for (uint256 i = 0; i < mmr1.peaksLength; i++) {
            assert(mmr1.peaks[i] == mmr.peaks[i]); // "peaks do not match");
        }
    }

    function test_persistFrom() public {
        MerkleMountainRange.MMR memory mmr1;
        mmr1.peaksLength = 2;
        mmr1.peaks[0] = keccak256(abi.encodePacked(uint256(3)));
        mmr1.peaks[1] = keccak256(abi.encodePacked(uint256(4)));

        mmr.persistFrom(mmr1, 2);

        assertEq(mmr.peaksLength, 2);
        assertEq(mmr.peaks[0], mmr1.peaks[0]);
        assertEq(mmr.peaks[1], mmr1.peaks[1]);
    }

    function test_commit() public {
        bytes32 root = mmr.commit();
        bytes32[] memory peaks = new bytes32[](mmr.peaksLength);
        for (uint256 i = 0; i < mmr.peaksLength; i++) {
            peaks[i] = mmr.peaks[i];
        }
        assertEq(root, keccak256(abi.encodePacked(peaks)));
    }

    function test_appendEmpty() public {
        MerkleMountainRange.MMR memory mmr2;
        mmr2.appendLeaves(leaves);

        vm.pauseGasMetering();
        MerkleMountainRange.MMR memory mmr1;
        for (uint256 i = 0; i < leaves.length; i++) {
            mmr1.appendLeaf(leaves[i]);
        }

        assert(mmr1.peaksLength == mmr2.peaksLength); // "peaksLength do not match");
        for (uint256 i = 0; i < mmr1.peaksLength; i++) {
            assert(mmr1.peaks[i] == mmr2.peaks[i]);
        }
        vm.resumeGasMetering();
    }

    function test_appendNonempty() public {
        MerkleMountainRange.MMR memory mmr2;
        vm.pauseGasMetering();
        MerkleMountainRange.MMR memory mmr1;
        uint256 i;
        for (i = 0; i < 10; i++) {
            if (i & 1 == 1) {
                mmr1.peaks[i] = keccak256(abi.encodePacked(i)); // more random
                mmr2.peaks[i] = mmr1.peaks[i];
            }
        }
        mmr1.peaksLength = uint8(i);
        mmr2.peaksLength = uint8(i);

        for (i = 0; i < leaves.length; i++) {
            mmr1.appendLeaf(leaves[i]);
        }
        vm.resumeGasMetering();

        mmr2.appendLeaves(leaves);

        vm.pauseGasMetering();
        assert(mmr1.peaksLength == mmr2.peaksLength); // "peaksLength do not match");
        for (i = 0; i < mmr1.peaksLength; i++) {
            // emit log_uint(i);
            // emit log_named_bytes32("mmr1", mmr1.peaks[i]);
            // emit log_named_bytes32("mmr2", mmr2.peaks[i]);
            assert(mmr1.peaks[i] == mmr2.peaks[i]); // "peaks do not match");
        }
        vm.resumeGasMetering();
    }
}
