// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";
import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";

contract AxiomV2HeaderVerifierDeploy is AxiomDeployBase {
    address public coreAddr;
    address public headerAddr;
    address public verifierAddr;

    function run(uint64 sourceChainId, bool isProd) external {
        (address timelock, address guardian, address unfreeze,, address[] memory queryProvers) =
            _getMultisigAddresses(sourceChainId, isProd);
        coreAddr = _getCoreAddress(sourceChainId, isProd);

        console.log("Deploying AxiomV2HeaderVerifier");
        console.log("sourceChainId:", sourceChainId);
        console.log("isProd:", isProd);
        console.log("AxiomV2Core / AxiomV2CoreHistoricalMock:", coreAddr);
        console.log("timelock:", timelock);
        console.log("guardian:", guardian);
        console.log("unfreeze:", unfreeze);
        console.log("queryProvers.length:", queryProvers.length);
        for (uint256 i = 0; i < queryProvers.length; i++) {
            console.log("queryProvers[%d]:", i, queryProvers[i]);
        }

        vm.startBroadcast();
        headerAddr = _deployHeaderVerifier(sourceChainId, coreAddr);
        vm.stopBroadcast();

        console.log("AxiomV2HeaderVerifier:", headerAddr);
    }
}
