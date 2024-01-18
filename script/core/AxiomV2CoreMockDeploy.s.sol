// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";

contract AxiomV2CoreMockDeploy is AxiomDeployBase {
    function run(uint64 sourceChainId, bool isProd, uint256 saltNum) external {
        bytes32 salt = bytes32(saltNum);
        create3 = ICREATE3Factory(_getCREATE3Addr(sourceChainId));
        (address timelock, address guardian, address unfreeze, address coreProver,) =
            _getMultisigAddresses(sourceChainId, isProd);

        console.log("Deploying AxiomV2CoreMock");
        console.log("sourceChainId:", sourceChainId);
        console.log("isProd:", isProd);
        console.log("saltNum:", saltNum);
        console.log("timelock:", timelock);
        console.log("guardian:", guardian);
        console.log("unfreeze:", unfreeze);
        console.log("coreProver:", coreProver);

        vm.startBroadcast();
        address coreMock = _deployCoreMock(timelock, guardian, unfreeze, coreProver, salt);
        vm.stopBroadcast();

        console.log("AxiomV2CoreMock:", coreMock);
    }
}
