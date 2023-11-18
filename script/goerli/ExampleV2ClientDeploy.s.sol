// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";

import { ExampleV2Client } from "../../contracts/client/ExampleV2Client.sol";

import "forge-std/Script.sol";

contract ExampleV2ClientDeploy is Script {
    bytes32 constant salt = hex"70ddae67ed07941266609bdc1129853e26d30c0f";

    function run() external {
        vm.startBroadcast();
        address axQuery = address(0xf15cc7B983749686Cd1eCca656C3D3E46407DC1f);

        ExampleV2Client client = new ExampleV2Client(axQuery, uint64(5));
        vm.stopBroadcast();
    }
}
