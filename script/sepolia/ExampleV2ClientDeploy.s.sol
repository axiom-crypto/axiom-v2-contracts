// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { SEPOLIA_CHAIN_ID } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";

import { ExampleV2Client } from "../../contracts/client/ExampleV2Client.sol";

import "forge-std/Script.sol";

contract ExampleV2ClientDeploy is Script {
    bytes32 constant salt = hex"1234";

    function run() external {
        vm.startBroadcast();
        address axQuery = address(0x8DdE5D4a8384F403F888E1419672D94C570440c9);

        ExampleV2Client client = new ExampleV2Client(axQuery, SEPOLIA_CHAIN_ID);
        vm.stopBroadcast();
    }
}
