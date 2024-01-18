// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";

contract AxiomV2CoreDeployMock is AxiomDeployBase {
    bytes32 constant salt = hex"1234";

    function run() external {
        vm.startBroadcast();
        address timelock = msg.sender;
        address guardian = msg.sender;
        address unfreeze = msg.sender;
        address prover = msg.sender;

        create3 = ICREATE3Factory(_deployCREATE3());
        _deployCoreMock(timelock, guardian, unfreeze, prover, salt);
        vm.stopBroadcast();
    }
}
