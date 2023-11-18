// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";

import { SEPOLIA_CHAIN_ID } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";
import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";
import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";

uint32 constant CONTRACT_VERSION = 8;

contract AxiomV2QueryDeploy is AxiomDeployBase {
    bytes32 constant salt = hex"1234567811";
    address coreAddr;

    address headerAddr;
    address proverAddr;
    address resultAddr;
    address verifierAddr;

    function run() external {
        vm.startBroadcast();
        create3 = ICREATE3Factory(_getCREATE3Addr(SEPOLIA_CHAIN_ID));
        (address timelock, address guardian, address unfreeze,, address queryProver) =
            _getMultisigAddresses(SEPOLIA_CHAIN_ID);

        coreAddr = _getCoreAddress(SEPOLIA_CHAIN_ID);
        {
            address axQuery = create3.getDeployed(msg.sender, salt);
            headerAddr = _deployHeaderVerifier(SEPOLIA_CHAIN_ID, coreAddr, timelock, guardian, unfreeze);
            proverAddr = _deployProver(axQuery, queryProver, timelock, guardian, unfreeze);
            resultAddr = _deployResultStore(axQuery, timelock, guardian, unfreeze);
            verifierAddr = _deployQueryVerifier();
        }

        bytes32[] memory aggregateVkeyHashes = _getAggregateVkeyHashes(CONTRACT_VERSION);
        IAxiomV2Query.AxiomV2QueryInit memory init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: headerAddr,
            verifierAddress: verifierAddr,
            axiomProverAddress: proverAddr,
            axiomResultStoreAddress: resultAddr,
            aggregateVkeyHashes: aggregateVkeyHashes,
            queryDeadlineInterval: 7200,
            proofVerificationGas: 400_000,
            axiomQueryFee: 0.003 ether,
            minMaxFeePerGas: 5 gwei,
            maxQueryDeadlineInterval: 50_400,
            timelock: timelock,
            guardian: guardian,
            unfreeze: unfreeze
        });
        _deployQuery(init, salt);
        vm.stopBroadcast();
    }
}
