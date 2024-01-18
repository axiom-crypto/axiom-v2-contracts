// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import {
    AxiomTestBase, AxiomTestSendInputs, AxiomTestMetadata, AxiomTestFulfillInputs
} from "../base/AxiomTestBase.sol";

contract AxiomV2QueryFulfillGasTest is AxiomTestBase {
    AxiomTestSendInputs public sendInputs;
    AxiomTestMetadata public metadata;
    AxiomTestFulfillInputs public fulfillInputs;
    uint32 public forkBlockNumber;
    uint64 public sourceChainId;
    uint256 public maxQueryPri;

    function setUp() public {
        (
            AxiomTestSendInputs memory _sendInputs,
            AxiomTestMetadata memory _metadata,
            AxiomTestFulfillInputs memory _fulfillInputs,
            uint32 _forkBlockNumber,
            uint64 _sourceChainId
        ) = _readFromFile(QUERY_TEST_FILE_PATH, false, false, false, false);

        sendInputs = _sendInputs;
        metadata = _metadata;
        fulfillInputs = _fulfillInputs;
        forkBlockNumber = _forkBlockNumber;
        sourceChainId = _sourceChainId;

        uint256 queryId = sendQuery();
        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);
    }

    function sendQuery() public returns (uint256 queryId) {
        _forkAndDeploy("sepolia", forkBlockNumber);
        vm.deal(caller, 1 ether);

        vm.prank(caller);
        maxQueryPri = 0.003 ether + sendInputs.feeData.maxFeePerGas * (sendInputs.feeData.callbackGasLimit + 500_000);
        queryId = axiomQuery.sendQuery{ value: maxQueryPri }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            sendInputs.userSalt,
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_gas_fulfillQuery() public {
        vm.prank(prover);
        axiomQuery.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );

        vm.prank(fulfillInputs.payee);
        axiomQuery.unescrow(metadata.queryWitness, 0.02 ether);

        vm.prank(fulfillInputs.payee);
        axiomQuery.withdraw(0.01 ether, payable(fulfillInputs.payee));
    }
}
