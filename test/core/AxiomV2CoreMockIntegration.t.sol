// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { AxiomV2CoreMock } from "../../contracts/mock/AxiomV2CoreMock.sol";
import { IAxiomV2Core } from "../../contracts/interfaces/core/IAxiomV2Core.sol";
import { MerkleTree } from "../../contracts/libraries/MerkleTree.sol";

import { AxiomTestBase } from "../base/AxiomTestBase.sol";

contract AxiomV2CoreMockIntegrationTest is AxiomTestBase {
    event FreezeAll();
    event UnfreezeAll();

    function setUp() public virtual {
        _forkAndDeploy("goerli", 9_867_480);
    }

    function test_bootstrap() public {
        _runBootstrap();
    }

    function test_supportsInterface() public view {
        assert(axiomMock.supportsInterface(type(IAxiomV2Core).interfaceId));
    }
}
