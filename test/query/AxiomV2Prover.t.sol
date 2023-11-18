// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { IAxiomV2Prover } from "../../contracts/interfaces/query/IAxiomV2Prover.sol";
import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { AxiomV2Prover } from "../../contracts/query/AxiomV2Prover.sol";
import {
    AxiomTestBase,
    AxiomTestSendInputs,
    AxiomTestMetadata,
    AxiomTestFulfillInputs,
    BASE_FILE_PATH,
    TimelockAddressIsZero,
    GuardianAddressIsZero,
    UnfreezeAddressIsZero,
    AxiomQueryAddressIsZero,
    ProverAddressIsZero,
    ProverNotAuthorized
} from "../base/AxiomTestBase.sol";

contract AxiomV2ProverTest is AxiomTestBase {
    event FreezeAll();
    event UnfreezeAll();
    event AxiomResultHashWritten(bytes32 queryHash, bytes32 resultHash);
    event AddAllowedProver(bytes32 indexed querySchema, address target, address prover);
    event RemoveAllowedProver(bytes32 indexed querySchema, address target, address prover);
    event QueryFulfilled(uint256 indexed queryId, address payee, bool callbackSucceeded);

    error ContractIsFrozen();

    AxiomTestSendInputs public sendInputs;
    AxiomTestMetadata public metadata;
    AxiomTestFulfillInputs public fulfillInputs;
    uint32 public forkBlockNumber;
    uint64 public sourceChainId;

    function setUp() public { }

    function assignFromFile(
        string memory filename,
        bool isIpfs,
        bool isEmptyComputeQuery,
        bool isEmptyCallback,
        bool isOffchainFulfill
    ) public {
        (
            AxiomTestSendInputs memory _sendInputs,
            AxiomTestMetadata memory _metadata,
            AxiomTestFulfillInputs memory _fulfillInputs,
            uint32 _forkBlockNumber,
            uint64 _sourceChainId
        ) = _readFromFile(filename, isIpfs, isEmptyComputeQuery, isEmptyCallback, isOffchainFulfill);

        sendInputs = _sendInputs;
        metadata = _metadata;
        fulfillInputs = _fulfillInputs;
        forkBlockNumber = _forkBlockNumber;
        sourceChainId = _sourceChainId;
    }

    function test_init_zeroQueryAddress_fail() public {
        AxiomV2Prover implementationSt = new AxiomV2Prover();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address)", address(0), prover, timelock, guardian, unfreeze
        );
        vm.expectRevert(AxiomQueryAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_init_zeroProverAddress_fail() public {
        AxiomV2Prover implementationSt = new AxiomV2Prover();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address)", query, address(0), timelock, guardian, unfreeze
        );
        vm.expectRevert(ProverAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_init_zeroTimelockAddress_fail() public {
        AxiomV2Prover implementationSt = new AxiomV2Prover();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address)", query, prover, address(0), guardian, unfreeze
        );
        vm.expectRevert(TimelockAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_init_zeroGuardianAddress_fail() public {
        AxiomV2Prover implementationSt = new AxiomV2Prover();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address)", query, prover, timelock, address(0), unfreeze
        );
        vm.expectRevert(GuardianAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_init_zeroUnfreezeAddress_fail() public {
        AxiomV2Prover implementationSt = new AxiomV2Prover();
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address)", query, prover, timelock, guardian, address(0)
        );
        vm.expectRevert(UnfreezeAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_freeze() public {
        _forkAndDeploy("goerli", forkBlockNumber);

        vm.prank(WRONG_ADDRESS); // any address not guardian
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0x55435dd261a4b9b3364963f7738a7a662ad9c84396d64be3365284bb7f0a5041"
        );
        axiomProver.freezeAll();
        assertFalse(axiomProver.frozen());

        vm.prank(guardian);
        vm.expectEmit();
        emit FreezeAll();

        axiomProver.freezeAll();
        assertTrue(axiomProver.frozen());

        vm.prank(WRONG_ADDRESS); // any address not unfreeze
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf4e710c64967f31ba1090db2a7dd9e704155d00947ce853da47446cb68ee65da"
        );
        axiomProver.unfreezeAll();
        assertTrue(axiomProver.frozen());

        vm.prank(unfreeze);
        vm.expectEmit();
        emit UnfreezeAll();

        axiomProver.unfreezeAll();
        assertFalse(axiomProver.frozen());
    }

    function test_fulfillQuery_access_fail() public {
        _forkAndDeploy("goerli", forkBlockNumber);
        assignFromFile(BASE_FILE_PATH, false, false, false, false);

        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(ProverNotAuthorized.selector);
        axiomProver.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillOffchainQuery_access_fail() public {
        _forkAndDeploy("goerli", forkBlockNumber);
        assignFromFile(BASE_FILE_PATH, false, false, false, true);

        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(ProverNotAuthorized.selector);

        axiomProver.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );
    }

    function test_fulfillQuery_frozen_fail() public {
        _forkAndDeploy("goerli", forkBlockNumber);
        assignFromFile(BASE_FILE_PATH, false, false, false, false);

        sendQuery();

        vm.prank(guardian);
        axiomProver.freezeAll();
        vm.prank(prover);
        vm.expectRevert(ContractIsFrozen.selector);

        axiomProver.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );

        vm.prank(unfreeze);
        axiomProver.unfreezeAll();

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        axiomProver.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_fulfillOffchainQuery_frozen_fail() public {
        _forkAndDeploy("goerli", forkBlockNumber);
        assignFromFile(BASE_FILE_PATH, false, false, false, true);

        vm.prank(guardian);
        axiomProver.freezeAll();

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(prover);
        vm.expectRevert(ContractIsFrozen.selector);
        axiomProver.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );

        vm.prank(unfreeze);
        axiomProver.unfreezeAll();

        vm.prank(prover);
        axiomProver.fulfillOffchainQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            sendInputs.userSalt
        );
    }

    function test_supportsInterface() public {
        _forkAndDeploy("goerli", forkBlockNumber);
        assert(axiomProver.supportsInterface(type(IAxiomV2Prover).interfaceId));
    }

    function sendQuery() public returns (uint256 queryId) {
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

    function test_addAllowedProver() public {
        _forkAndDeploy("goerli", forkBlockNumber);
        assignFromFile(BASE_FILE_PATH, false, false, false, false);

        sendQuery();

        vm.prank(timelock);
        vm.expectEmit();
        emit AddAllowedProver(metadata.querySchema, address(client), WRONG_ADDRESS);
        axiomProver.addAllowedProver(metadata.querySchema, address(client), WRONG_ADDRESS);

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(WRONG_ADDRESS);
        vm.expectEmit();
        emit QueryFulfilled(metadata.queryId, prover, true);
        axiomProver.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }

    function test_removeAllowedProver() public {
        _forkAndDeploy("goerli", forkBlockNumber);
        assignFromFile(BASE_FILE_PATH, false, false, false, false);

        sendQuery();

        vm.prank(timelock);
        vm.expectEmit();
        emit AddAllowedProver(metadata.querySchema, address(client), WRONG_ADDRESS);
        axiomProver.addAllowedProver(metadata.querySchema, address(client), WRONG_ADDRESS);

        vm.prank(timelock);
        vm.expectEmit();
        emit RemoveAllowedProver(metadata.querySchema, address(client), WRONG_ADDRESS);
        axiomProver.removeAllowedProver(metadata.querySchema, address(client), WRONG_ADDRESS);

        axiom.setPmmrSnapshot(fulfillInputs.mmrWitness.snapshotPmmrSize, fulfillInputs.snapshotPmmrHash);

        vm.prank(WRONG_ADDRESS);
        vm.expectRevert(ProverNotAuthorized.selector);
        axiomProver.fulfillQuery(
            fulfillInputs.mmrWitness,
            fulfillInputs.computeResults,
            fulfillInputs.proof,
            sendInputs.callback,
            metadata.queryWitness
        );
    }
}
