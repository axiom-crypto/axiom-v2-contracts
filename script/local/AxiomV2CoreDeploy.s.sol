// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";

contract AxiomV2CoreDeploy is AxiomDeployBase {
    function run(uint64 sourceChainId, uint256 saltNum, address coreProver) external {
        bytes32 salt = bytes32(saltNum);
        create3 = ICREATE3Factory(_getCREATE3Addr(sourceChainId));
        address timelock = coreProver;
        address guardian = coreProver;
        address unfreeze = coreProver;

        console.log("Deploying AxiomV2Core");
        console.log("sourceChainId:", sourceChainId);
        console.log("saltNum:", saltNum);
        console.log("timelock:", timelock);
        console.log("guardian:", guardian);
        console.log("unfreeze:", unfreeze);
        console.log("coreProver:", coreProver);

        vm.startBroadcast();
        (address verifier, address historicalVerifier) = _deployCoreVerifiers(sourceChainId);
        address core = _deployCore(verifier, historicalVerifier, timelock, guardian, unfreeze, coreProver, salt);
        vm.stopBroadcast();

        console.log("AxiomV2CoreVerifier:", verifier);
        console.log("AxiomV2CoreHistoricalVerifier:", historicalVerifier);
        console.log("AxiomV2Core:", core);
    }
}
