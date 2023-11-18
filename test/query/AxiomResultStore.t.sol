// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import {
    TimelockAddressIsZero,
    GuardianAddressIsZero,
    UnfreezeAddressIsZero,
    AxiomQueryAddressIsZero,
    ContractIsFrozen
} from "../base/AxiomTestBase.sol";
import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import "../../contracts/query/AxiomResultStore.sol";

contract AxiomResultStoreTest is Test {
    AxiomResultStore private implementationSt = new AxiomResultStore();
    AxiomResultStore public axiomStorage;

    address public constant TIMELOCK_ROLE = address(11);
    address public constant GUARDIAN_ROLE = address(22);
    address public constant UNFREEZE_ROLE = address(33);
    address public constant QUERY_ROLE = address(99);

    address public constant WRONG_ADDRESS = address(66);
    address public constant NEW_ADDRESS = address(77);

    event FreezeAll();
    event UnfreezeAll();
    event AxiomResultHashWritten(bytes32 indexed queryHash, bytes32 resultHash);

    function setUp() public {
        vm.makePersistent(address(implementationSt));

        deploy();
    }

    function deploy() public {
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", QUERY_ROLE, TIMELOCK_ROLE, GUARDIAN_ROLE, UNFREEZE_ROLE
        );
        AxiomProxy proxySt = new AxiomProxy(address(implementationSt), data);
        axiomStorage = AxiomResultStore(payable(address(proxySt)));
    }

    function test_init_zeroQueryAddress_fail() public {
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", address(0), TIMELOCK_ROLE, GUARDIAN_ROLE, UNFREEZE_ROLE
        );
        vm.expectRevert(AxiomQueryAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_init_zeroTimelockAddress_fail() public {
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", QUERY_ROLE, address(0), GUARDIAN_ROLE, UNFREEZE_ROLE
        );
        vm.expectRevert(TimelockAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_init_zeroGuardianAddress_fail() public {
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", QUERY_ROLE, TIMELOCK_ROLE, address(0), UNFREEZE_ROLE
        );
        vm.expectRevert(GuardianAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_init_zeroUnfreezeAddress_fail() public {
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", QUERY_ROLE, TIMELOCK_ROLE, GUARDIAN_ROLE, address(0)
        );
        vm.expectRevert(UnfreezeAddressIsZero.selector);
        new AxiomProxy(address(implementationSt), data);
    }

    function test_freeze() public {
        vm.prank(WRONG_ADDRESS); // any address not guardian
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0x55435dd261a4b9b3364963f7738a7a662ad9c84396d64be3365284bb7f0a5041"
        );
        axiomStorage.freezeAll();
        assertFalse(axiomStorage.frozen());

        vm.prank(GUARDIAN_ROLE); // guardian
        vm.expectEmit();
        emit FreezeAll();

        axiomStorage.freezeAll();
        assertTrue(axiomStorage.frozen());

        vm.prank(WRONG_ADDRESS); // any address not unfreeze
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0xf4e710c64967f31ba1090db2a7dd9e704155d00947ce853da47446cb68ee65da"
        );
        axiomStorage.unfreezeAll();
        assertTrue(axiomStorage.frozen());

        vm.prank(UNFREEZE_ROLE); // timelock
        vm.expectEmit();
        emit UnfreezeAll();

        axiomStorage.unfreezeAll();
        assertFalse(axiomStorage.frozen());
    }

    function test_writeResultHash() public {
        vm.prank(QUERY_ROLE);

        vm.expectEmit();
        emit AxiomResultHashWritten(keccak256("test"), keccak256("data"));

        axiomStorage.writeResultHash(keccak256("test"), keccak256("data"));
        assertEq(axiomStorage.results(keccak256("test")), keccak256("data"));
        assertEq(axiomStorage.getResultHash(keccak256("test")), keccak256("data"));
    }

    function test_writeResultHash_access_fail() public {
        vm.prank(WRONG_ADDRESS);

        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000042 is missing role 0x542178611b653a605b79640db9b52a7afa591d6ace75cd36686e0ee264f4f572"
        );

        axiomStorage.writeResultHash(keccak256("test"), keccak256("data"));
    }

    function test_writeResultHash_frozen_fail() public {
        vm.prank(GUARDIAN_ROLE); // guardian
        axiomStorage.freezeAll();
        vm.prank(QUERY_ROLE); // query
        vm.expectRevert(ContractIsFrozen.selector);

        axiomStorage.writeResultHash(keccak256("test"), keccak256("data"));

        vm.prank(UNFREEZE_ROLE); // unfreeze
        axiomStorage.unfreezeAll();

        vm.prank(QUERY_ROLE);
        axiomStorage.writeResultHash(keccak256("test"), keccak256("data"));

        assertEq(axiomStorage.results(keccak256("test")), keccak256("data"));
        assertEq(axiomStorage.getResultHash(keccak256("test")), keccak256("data"));
    }

    function test_supportsInterface() public view {
        assert(axiomStorage.supportsInterface(type(IAxiomResultStore).interfaceId));
    }
}
