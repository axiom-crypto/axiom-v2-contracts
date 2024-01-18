// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";
import { ExampleV2Client } from "../../contracts/client/ExampleV2Client.sol";

contract ExampleV2ClientDeploy is AxiomDeployBase {
    function run(uint64 sourceChainId, bool isMock) external {
        address axQuery;
        if (isMock) {
            axQuery = _getQueryMockAddress(sourceChainId, true);
        } else {
            axQuery = _getQueryAddress(sourceChainId, true);
        }

        vm.startBroadcast();
        ExampleV2Client client = new ExampleV2Client(axQuery, sourceChainId);
        vm.stopBroadcast();
    }
}
