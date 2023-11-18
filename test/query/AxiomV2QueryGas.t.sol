// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import {
    AxiomTestBase,
    AxiomTestSendInputs,
    AxiomTestMetadata,
    AxiomTestFulfillInputs,
    BASE_FILE_PATH
} from "../base/AxiomTestBase.sol";

contract AxiomV2QueryGasTest is AxiomTestBase {
    AxiomTestSendInputs public sendInputs;
    AxiomTestMetadata public metadata;
    AxiomTestFulfillInputs public fulfillInputs;
    uint32 public forkBlockNumber;
    uint64 public sourceChainId;

    function setUp() public {
        (
            AxiomTestSendInputs memory _sendInputs,
            AxiomTestMetadata memory _metadata,
            AxiomTestFulfillInputs memory _fulfillInputs,
            uint32 _forkBlockNumber,
            uint64 _sourceChainId
        ) = _readFromFile(BASE_FILE_PATH, false, false, false, false);

        sendInputs = _sendInputs;
        metadata = _metadata;
        fulfillInputs = _fulfillInputs;
        forkBlockNumber = _forkBlockNumber;
        sourceChainId = _sourceChainId;
    }

    function sendQuery() public returns (uint256 queryId) {
        _forkAndDeploy("goerli", forkBlockNumber);
        vm.deal(caller, 1 ether);

        vm.prank(caller);
        queryId = axiomQuery.sendQuery{ value: 0.1 ether }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.userSalt,
            sendInputs.maxFeePerGas,
            sendInputs.callbackGasLimit,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function sendQueryNoDeposit() public returns (uint256 queryId) {
        _forkAndDeploy("goerli", forkBlockNumber);
        vm.deal(caller, 1 ether);
        axiomQuery.deposit{ value: 0.2 ether }(caller);

        vm.prank(caller);
        queryId = axiomQuery.sendQuery(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.userSalt,
            sendInputs.maxFeePerGas,
            sendInputs.callbackGasLimit,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_gas_sendQuery() public {
        sendQuery();
    }

    function test_gas_sendQueryNoDeposit() public {
        sendQueryNoDeposit();
    }

    function test_gas_fulfillQuery() public {
        uint256 queryId = sendQuery();
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        axiomQuery.increaseQueryGas{ value: 0.02 ether }(queryId, 30 gwei, 400_000);

        vm.prank(prover);
        axiomProver.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );

        vm.prank(prover);
        axiomQuery.unescrow(metadata.queryWitness, 0.02 ether);

        vm.prank(prover);
        axiomQuery.withdraw(0.01 ether, payable(prover));
    }
}
