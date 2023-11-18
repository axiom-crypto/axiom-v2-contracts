// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";

contract AxiomV2CoreDeployMock is AxiomDeployBase {
    function run() external {
        vm.startBroadcast();
        address timelock = msg.sender;
        address guardian = msg.sender;
        address unfreeze = msg.sender;
        address prover = msg.sender;

        _deployCoreMock(timelock, guardian, unfreeze, prover);
        vm.stopBroadcast();
    }
}
