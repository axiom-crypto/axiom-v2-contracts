// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import { IAxiomV2Client } from "../../contracts/interfaces/client/IAxiomV2Client.sol";
import { AxiomV2Client } from "../../contracts/client/AxiomV2Client.sol";
import { ExampleV2Client } from "../../contracts/client/ExampleV2Client.sol";

error SourceChainIdDoesNotMatch();
error CallerMustBeAxiomV2Query();
error AxiomV2QueryAddressIsZero();

contract AxiomV2ClientTest is Test {
    event AxiomV2Call(
        uint64 indexed sourceChainId, address caller, bytes32 indexed querySchema, uint256 indexed queryId
    );

    event AxiomV2OffchainCall(
        uint64 indexed sourceChainId, address caller, bytes32 indexed querySchema, uint256 indexed queryId
    );

    event ExampleClientAddrAndSchema(address indexed caller, bytes32 indexed querySchema);
    event ExampleClientEvent(uint256 indexed queryId, bytes32[] axiomResults, bytes extraData);

    // initialization settings for client
    address public queryAddress;
    uint64 public callbackSourceChainId;

    ExampleV2Client public client;

    // callback inputs
    address public caller;
    bytes32 public querySchema;
    uint256 public queryId;
    bytes32[] public axiomResults;
    bytes public extraData;

    address public constant WRONG_ADDRESS = address(99);

    function setUp() public {
        queryAddress = address(1);
        callbackSourceChainId = uint64(5);

        client = new ExampleV2Client(queryAddress, callbackSourceChainId);
        vm.makePersistent(address(client));

        caller = address(10);
        querySchema = bytes32(uint256(11));
        queryId = uint256(22);
        axiomResults = new bytes32[](1);
        axiomResults[0] = bytes32(uint256(33));
        extraData = bytes("extraData");
    }

    function test_axiomV2Client_init_zeroAddress_fail() public {
        vm.expectRevert(AxiomV2QueryAddressIsZero.selector);
        ExampleV2Client clientTest = new ExampleV2Client(address(0), callbackSourceChainId);
    }

    function test_axiomV2Callback() public {
        vm.prank(queryAddress);
        vm.expectEmit();
        emit AxiomV2Call(callbackSourceChainId, caller, querySchema, queryId);
        vm.expectEmit();
        emit ExampleClientAddrAndSchema(caller, querySchema);
        vm.expectEmit();
        emit ExampleClientEvent(queryId, axiomResults, extraData);
        client.axiomV2Callback(callbackSourceChainId, caller, querySchema, queryId, axiomResults, extraData);
    }

    function test_axiomV2Callback_wrongCaller_fail() public {
        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(CallerMustBeAxiomV2Query.selector);
        client.axiomV2Callback(callbackSourceChainId, caller, querySchema, queryId, axiomResults, extraData);
    }

    function test_axiomV2Callback_wrongSourceChainId_fail() public {
        vm.prank(queryAddress);
        vm.expectRevert(SourceChainIdDoesNotMatch.selector);
        client.axiomV2Callback(uint64(1), caller, querySchema, queryId, axiomResults, extraData);
    }

    function test_axiomV2OffchainCallback() public {
        vm.prank(queryAddress);
        vm.expectEmit();
        emit AxiomV2OffchainCall(callbackSourceChainId, caller, querySchema, queryId);
        vm.expectEmit();
        emit ExampleClientAddrAndSchema(caller, querySchema);
        vm.expectEmit();
        emit ExampleClientEvent(queryId, axiomResults, extraData);
        client.axiomV2OffchainCallback(callbackSourceChainId, caller, querySchema, queryId, axiomResults, extraData);
    }

    function test_axiomV2OffchainCallback_wrongCaller_fail() public {
        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(CallerMustBeAxiomV2Query.selector);
        client.axiomV2OffchainCallback(callbackSourceChainId, caller, querySchema, queryId, axiomResults, extraData);
    }

    function test_axiomV2OffchainCallback_wrongSourceChainId_fail() public {
        vm.prank(queryAddress);
        vm.expectRevert(SourceChainIdDoesNotMatch.selector);
        client.axiomV2OffchainCallback(uint64(1), caller, querySchema, queryId, axiomResults, extraData);
    }
}
