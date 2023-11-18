// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { AxiomV2CoreMock } from "../../contracts/mock/AxiomV2CoreMock.sol";
import { IAxiomV2Core } from "../../contracts/interfaces/core/IAxiomV2Core.sol";
import { MerkleTree } from "../../contracts/libraries/MerkleTree.sol";
import { MerkleMountainRange } from "../../contracts/libraries/MerkleMountainRange.sol";
import { PaddedMerkleMountainRange } from "../../contracts/libraries/PaddedMerkleMountainRange.sol";

import { AxiomTestBase } from "../base/AxiomTestBase.sol";

contract AxiomV2CoreMockStatesTest is AxiomTestBase {
    event FreezeAll();
    event UnfreezeAll();

    function setUp() public virtual { }

    function test_backfill() public {
        file = vm.readFile("test/data/core/backfillTest_1_9867456_3000.json");
        uint32 forkBlock = abi.decode(vm.parseJson(file, ".recoveryBlockNumber"), (uint32));

        _forkAndDeploy("goerli", forkBlock);
        _runBackfillTest("test/data/core/backfillTest_1_9867456_3000.json");
    }
}
