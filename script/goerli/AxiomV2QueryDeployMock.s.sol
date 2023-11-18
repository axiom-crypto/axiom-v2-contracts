// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";

import { GOERLI_CHAIN_ID } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";
import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";
import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";

uint32 constant CONTRACT_VERSION = 9;

contract AxiomV2QueryDeployMock is AxiomDeployBase {
    bytes32 constant salt = hex"70ddae67ed07941266609bdc1129853e26d30c0f";
    address coreAddr;

    address headerAddr;
    address proverAddr;
    address resultAddr;

    function run() external {
        vm.startBroadcast();
        create3 = ICREATE3Factory(_getCREATE3Addr(GOERLI_CHAIN_ID));
        (address timelock, address guardian, address unfreeze,, address queryProver) =
            _getMultisigAddresses(GOERLI_CHAIN_ID);

        coreAddr = _getCoreMockAddress(GOERLI_CHAIN_ID);
        {
            address axQuery = create3.getDeployed(msg.sender, salt);
            headerAddr = _deployHeaderVerifier(GOERLI_CHAIN_ID, coreAddr, timelock, guardian, unfreeze);
            proverAddr = _deployProver(axQuery, queryProver, timelock, guardian, unfreeze);
            resultAddr = _deployResultStore(axQuery, timelock, guardian, unfreeze);
        }

        bytes32[] memory aggregateVkeyHashes = new bytes32[](1);
        aggregateVkeyHashes[0] = bytes32(0x0);
        IAxiomV2Query.AxiomV2QueryInit memory init = IAxiomV2Query.AxiomV2QueryInit({
            axiomHeaderVerifierAddress: headerAddr,
            verifierAddress: address(1),
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
        _deployQueryMock(init, salt);
        vm.stopBroadcast();
    }
}
