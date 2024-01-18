// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import {
    AxiomTestBase, AxiomTestSendInputs, AxiomTestMetadata, AxiomTestFulfillInputs
} from "../base/AxiomTestBase.sol";

contract AxiomV2QuerySendGasTest is AxiomTestBase {
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

        _forkAndDeploy("sepolia", forkBlockNumber);
        vm.deal(caller, 1 ether);

        maxQueryPri = 0.003 ether + sendInputs.feeData.maxFeePerGas * (sendInputs.feeData.callbackGasLimit + 500_000);
    }

    function test_gas_sendQueryMatchedBalance() public {
        vm.prank(caller);
        uint256 queryId2 = axiomQuery.sendQuery{ value: maxQueryPri }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            bytes32(uint256(sendInputs.userSalt) + 1),
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }

    function test_gas_sendQueryUnmatchedBalance() public {
        vm.prank(caller);
        uint256 queryId2 = axiomQuery.sendQuery{ value: maxQueryPri + 1 }(
            sourceChainId,
            sendInputs.dataQueryHash,
            sendInputs.computeQuery,
            sendInputs.callback,
            sendInputs.feeData,
            bytes32(uint256(sendInputs.userSalt) + 1),
            sendInputs.refund,
            sendInputs.dataQuery
        );
    }
}
