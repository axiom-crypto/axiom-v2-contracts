// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import { GOERLI_CHAIN_ID, MAINNET_CHAIN_ID } from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";

import { AxiomDeployBase } from "../base/AxiomDeployBase.sol";
import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";

contract AxiomV2QueryDeployMock is AxiomDeployBase {
    bytes32 constant salt = hex"1234";
    address public coreAddr;

    address headerAddr;
    address proverAddr;
    address resultAddr;

    function run() external {
        vm.startBroadcast();
        address timelock = msg.sender;
        address guardian = msg.sender;
        address unfreeze = msg.sender;
        address prover = msg.sender;

        create3 = ICREATE3Factory(_deployCREATE3());
        coreAddr = _deployCoreMock(timelock, guardian, unfreeze, prover);

        {
            address axQuery = create3.getDeployed(msg.sender, salt);
            headerAddr = _deployHeaderVerifier(MAINNET_CHAIN_ID, coreAddr, timelock, guardian, unfreeze);
            proverAddr = _deployProver(axQuery, msg.sender, timelock, guardian, unfreeze);
            resultAddr = _deployResultStore(axQuery, timelock, guardian, unfreeze);
        }

        bytes32[] memory aggregateVkeyHashes = new bytes32[](1);
        aggregateVkeyHashes[0] = bytes32(0x000000000000000000000000000000000000000000000000000000000000beef);
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
