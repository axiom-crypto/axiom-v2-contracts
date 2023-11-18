// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { SEPOLIA_CHAIN_ID } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";
import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";

contract AxiomV2CoreDeployMock is AxiomDeployBase {
    function run() external {
        vm.startBroadcast();

        (address timelock, address guardian, address unfreeze, address coreProver,) =
            _getMultisigAddresses(SEPOLIA_CHAIN_ID);
        _deployCoreMock(timelock, guardian, unfreeze, coreProver);
        vm.stopBroadcast();
    }
}
