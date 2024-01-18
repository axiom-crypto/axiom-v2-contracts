// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";
import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";

uint32 constant VERIFIER_VERSION = 14;

contract AxiomV2QueryMockDeploy is AxiomDeployBase {
    address public coreAddr;
    address public headerAddr;

    function run(uint64 sourceChainId, bool isProd, uint256 saltNum) external {
        bytes32 salt = bytes32(saltNum);
        create3 = ICREATE3Factory(_getCREATE3Addr(sourceChainId));
        (address timelock, address guardian, address unfreeze,, address[] memory queryProvers) =
            _getMultisigAddresses(sourceChainId, isProd);
        (
            uint32 queryDeadlineInterval,
            uint32 proofVerificationGas,
            uint256 axiomQueryFee,
            uint64 minMaxFeePerGas,
            uint32 maxQueryDeadlineInterval
        ) = _getQueryParams(sourceChainId);

        coreAddr = _getCoreMockAddress(sourceChainId, isProd);

        console.log("Deploying AxiomV2QueryMock");
        console.log("sourceChainId:", sourceChainId);
        console.log("isProd:", isProd);
        console.log("saltNum:", saltNum);
        console.log("AxiomV2CoreMock:", coreAddr);
        console.log("timelock:", timelock);
        console.log("guardian:", guardian);
        console.log("unfreeze:", unfreeze);
        console.log("queryProvers.length:", queryProvers.length);
        for (uint256 i = 0; i < queryProvers.length; i++) {
            console.log("queryProvers[%d]:", i, queryProvers[i]);
        }
        console.log("queryDeadlineInterval:", queryDeadlineInterval);
        console.log("proofVerificationGas:", proofVerificationGas);
        console.log("axiomQueryFee:", axiomQueryFee);
        console.log("minMaxFeePerGas:", minMaxFeePerGas);
        console.log("maxQueryDeadlineInterval:", maxQueryDeadlineInterval);

        vm.startBroadcast();
        headerAddr = _deployHeaderVerifier(sourceChainId, coreAddr);

        console.log("AxiomV2HeaderVerifier:", headerAddr);

        bytes32[] memory aggregateVkeyHashes = _getAggregateVkeyHashes(VERIFIER_VERSION);
        IAxiomV2Query.AxiomV2QueryInit memory init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: headerAddr,
            verifierAddress: address(1),
            proverAddresses: queryProvers,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: queryDeadlineInterval,
            proofVerificationGas: proofVerificationGas,
            axiomQueryFee: axiomQueryFee,
            minMaxFeePerGas: minMaxFeePerGas,
            maxQueryDeadlineInterval: maxQueryDeadlineInterval,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        address queryMock = _deployQueryMock(init, salt);
        vm.stopBroadcast();

        console.log("AxiomV2QueryMock:", queryMock);
    }
}
