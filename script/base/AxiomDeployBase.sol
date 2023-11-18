// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import {
    GOERLI_CHAIN_ID,
    MAINNET_CHAIN_ID,
    SEPOLIA_CHAIN_ID
} from "../../contracts/libraries/configuration/AxiomV2Configuration.sol";
import { IAxiomV2Query } from "../../contracts/interfaces/query/IAxiomV2Query.sol";

import { AxiomProxy } from "../../contracts/libraries/access/AxiomProxy.sol";
import { AxiomV2Core } from "../../contracts/core/AxiomV2Core.sol";
import { AxiomV2CoreMock } from "../../contracts/mock/AxiomV2CoreMock.sol";
import { AxiomV2CoreHistoricalMock } from "../../contracts/mock/AxiomV2CoreHistoricalMock.sol";
import { AxiomV2HeaderVerifier } from "../../contracts/query/AxiomV2HeaderVerifier.sol";
import { AxiomV2Prover } from "../../contracts/query/AxiomV2Prover.sol";
import { AxiomV2Query } from "../../contracts/query/AxiomV2Query.sol";
import { AxiomV2QueryMock } from "../../contracts/mock/AxiomV2QueryMock.sol";
import { AxiomResultStore } from "../../contracts/query/AxiomResultStore.sol";

import { YulDeployer } from "../../lib/YulDeployer.sol";
import { AxiomV2QueryVerifier } from "../../snark-verifiers/query/AxiomV2QueryVerifier.v0.9.sol";
import { AxiomV2CoreMainnetVerifier } from "../../snark-verifiers/core/AxiomV2CoreMainnetVerifier.v0.8.sol";
import { AxiomV2CoreGoerliVerifier } from "../../snark-verifiers/core/AxiomV2CoreGoerliVerifier.v0.8.sol";

address constant MAINNET_TIMELOCK = address(0x0c8630ef55ADC50266189CF2Ea2222A1a86Fcea2);
address constant MAINNET_GUARDIAN = address(0x99C7E4eB11541388535a4608C14738C24f131921);
address constant MAINNET_UNFREEZE = address(0x99C7E4eB11541388535a4608C14738C24f131921);
address constant MAINNET_CORE_PROVER = address(0x8018fe32fCFd3d166E8b4c4E37105318A84BA11b);
address constant MAINNET_QUERY_PROVER = address(0x8018fe32fCFd3d166E8b4c4E37105318A84BA11b);

address constant GOERLI_TIMELOCK = address(0xc2d7e38a40808BBfc1834C79b5Ba4b27bC4c462e);
address constant GOERLI_GUARDIAN = address(0x99C7E4eB11541388535a4608C14738C24f131921);
address constant GOERLI_UNFREEZE = address(0x99C7E4eB11541388535a4608C14738C24f131921);
address constant GOERLI_CORE_PROVER = address(0x8018fe32fCFd3d166E8b4c4E37105318A84BA11b);
address constant GOERLI_QUERY_PROVER = address(0x8018fe32fCFd3d166E8b4c4E37105318A84BA11b);

address constant GOERLI_OLD_CORE_MOCK_ADDRESS = address(0x0c8630ef55ADC50266189CF2Ea2222A1a86Fcea2);
address constant GOERLI_V08_CORE_MOCK_ADDRESS = address(0x2aE6ad6127C222f071C023086C442080B03AfCCe);
address constant GOERLI_V08_CORE_HISTORICAL_MOCK_ADDRESS = address(0x071b7aA74f060B40cB7EEE577c30E634276e7C9f);

abstract contract AxiomDeployBase is Script {
    ICREATE3Factory public create3;

    function _getCREATE3Addr(uint64 sourceChainId) internal returns (address) {
        if (sourceChainId == MAINNET_CHAIN_ID) {
            return address(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);
        } else if (sourceChainId == GOERLI_CHAIN_ID) {
            return address(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);
        } else if (sourceChainId == SEPOLIA_CHAIN_ID) {
            return address(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1);
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _deployCREATE3() internal returns (address) {
        CREATE3Factory create3 = new CREATE3Factory();
        return address(create3);
    }

    function _getCoreAddress(uint64 sourceChainId) internal returns (address coreAddress) {
        if (sourceChainId == MAINNET_CHAIN_ID) {
            revert("AxiomDeployBase: mainnet disabled");
        } else if (sourceChainId == GOERLI_CHAIN_ID) {
            coreAddress = GOERLI_V08_CORE_HISTORICAL_MOCK_ADDRESS;
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _getCoreMockAddress(uint64 sourceChainId) internal returns (address coreAddress) {
        if (sourceChainId == GOERLI_CHAIN_ID) {
            coreAddress = GOERLI_V08_CORE_MOCK_ADDRESS;
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _getMultisigAddresses(uint64 sourceChainId)
        internal
        returns (address timelock, address guardian, address unfreeze, address coreProver, address queryProver)
    {
        if (sourceChainId == MAINNET_CHAIN_ID) {
            revert("AxiomDeployBase: mainnet disabled");

            timelock = MAINNET_TIMELOCK;
            guardian = MAINNET_GUARDIAN;
            unfreeze = MAINNET_UNFREEZE;
            coreProver = MAINNET_CORE_PROVER;
            queryProver = MAINNET_QUERY_PROVER;
        } else if (sourceChainId == GOERLI_CHAIN_ID) {
            timelock = GOERLI_TIMELOCK;
            guardian = GOERLI_GUARDIAN;
            unfreeze = GOERLI_UNFREEZE;
            coreProver = GOERLI_CORE_PROVER;
            queryProver = GOERLI_QUERY_PROVER;
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _getAggregateVkeyHashes(uint32 version) internal returns (bytes32[] memory aggregateVkeyHashes) {
        if (version == 7) {
            aggregateVkeyHashes = new bytes32[](1);
            aggregateVkeyHashes[0] = bytes32(0x0e237205617f6abafb336441b10ed85bc213cadcb008e65440981e4c2188c488);
        } else if (version == 8) {
            // contract-v0.8
            aggregateVkeyHashes = new bytes32[](2);
            // config 1
            aggregateVkeyHashes[0] = bytes32(0x0739285abf85e3891e07b6ffa68cbd41b7557c51894d99a153c386fe3161e900);
            // config 2
            aggregateVkeyHashes[1] = bytes32(0x094fc9e4526a20304cfa40b4f9c2410a6edb7e23a29c491527cd3d4babd882d3);
        } else if (version == 9) {
            // contract-v0.9
            aggregateVkeyHashes = new bytes32[](2);
            // config 1
            aggregateVkeyHashes[0] = bytes32(0x0088c85dd433925fd2c5f083fc523be447fa7c5046a93425f0ef3df3523768f5);
            // config 2
            aggregateVkeyHashes[1] = bytes32(0x1b46de31e41b181c8f38639a52ee6af6936f2cf067d628fda6ee768f217f565a);
        }
    }

    function _deployCoreVerifiers(uint64 sourceChainId)
        internal
        returns (address verifierAddress, address historicalVerifierAddress)
    {
        verifierAddress = _deployCoreVerifier(sourceChainId);
        historicalVerifierAddress = _deployCoreHistoricalVerifier(sourceChainId);
    }

    function _deployCoreVerifier(uint64 sourceChainId) internal returns (address verifierAddress) {
        if (sourceChainId == MAINNET_CHAIN_ID) {
            AxiomV2CoreMainnetVerifier verifier = new AxiomV2CoreMainnetVerifier();
            verifierAddress = address(verifier);
        } else if (sourceChainId == GOERLI_CHAIN_ID) {
            AxiomV2CoreGoerliVerifier verifier = new AxiomV2CoreGoerliVerifier();
            verifierAddress = address(verifier);
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _deployCoreHistoricalVerifier(uint64 sourceChainId) internal returns (address historicalVerifierAddress) {
        YulDeployer deployer = new YulDeployer();
        vm.allowCheatcodes(address(deployer));
        if (sourceChainId == MAINNET_CHAIN_ID) {
            historicalVerifierAddress = address(deployer.deployContract("core/mainnet_17_7.v1"));
        } else if (sourceChainId == GOERLI_CHAIN_ID) {
            historicalVerifierAddress = address(deployer.deployContract("core/goerli_17_7.v1"));
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _deployQueryVerifier() internal returns (address) {
        AxiomV2QueryVerifier verifier = new AxiomV2QueryVerifier();
        return address(verifier);
    }

    function _deployCore(
        address verifier,
        address historicalVerifier,
        address timelock,
        address guardian,
        address unfreeze,
        address prover
    ) internal returns (address) {
        AxiomV2Core implementation = new AxiomV2Core();

        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            verifier,
            historicalVerifier,
            timelock,
            guardian,
            unfreeze,
            prover
        );
        AxiomProxy coreProxy = new AxiomProxy(address(implementation), data);
        return address(coreProxy);
    }

    function _deployCoreMock(address timelock, address guardian, address unfreeze, address prover)
        internal
        returns (address)
    {
        AxiomV2CoreMock implementation = new AxiomV2CoreMock();

        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            address(1),
            address(1),
            timelock,
            guardian,
            unfreeze,
            prover
        );
        AxiomProxy coreProxy = new AxiomProxy(address(implementation), data);
        return address(coreProxy);
    }

    function _deployCoreHistoricalMock(
        address verifier,
        address timelock,
        address guardian,
        address unfreeze,
        address prover
    ) internal returns (address) {
        AxiomV2CoreHistoricalMock implementation = new AxiomV2CoreHistoricalMock();

        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address)",
            verifier,
            address(1),
            timelock,
            guardian,
            unfreeze,
            prover
        );
        AxiomProxy coreProxy = new AxiomProxy(address(implementation), data);
        return address(coreProxy);
    }

    function _deployHeaderVerifier(
        uint64 sourceChainId,
        address coreAddr,
        address timelock,
        address guardian,
        address unfreeze
    ) internal returns (address) {
        AxiomV2HeaderVerifier headerImpl = new AxiomV2HeaderVerifier(sourceChainId);
        bytes memory headerInit = abi.encodeWithSignature(
            "initialize(address,address,address,address)", coreAddr, timelock, guardian, unfreeze
        );
        AxiomProxy headerProxy = new AxiomProxy(address(headerImpl), headerInit);
        return address(headerProxy);
    }

    function _deployProver(address axQuery, address proverAddr, address timelock, address guardian, address unfreeze)
        internal
        returns (address)
    {
        AxiomV2Prover proverImpl = new AxiomV2Prover();
        bytes memory proverInit = abi.encodeWithSignature(
            "initialize(address,address,address,address,address)", axQuery, proverAddr, timelock, guardian, unfreeze
        );
        AxiomProxy proverProxy = new AxiomProxy(address(proverImpl), proverInit);
        return address(proverProxy);
    }

    function _deployResultStore(address axQuery, address timelock, address guardian, address unfreeze)
        internal
        returns (address)
    {
        AxiomResultStore resultImpl = new AxiomResultStore();
        bytes memory resultInit = abi.encodeWithSignature(
            "initialize(address,address,address,address)", axQuery, timelock, guardian, unfreeze
        );
        AxiomProxy resultProxy = new AxiomProxy(address(resultImpl), resultInit);
        return address(resultProxy);
    }

    function _deployQuery(IAxiomV2Query.AxiomV2QueryInit memory init, bytes32 salt) internal returns (address) {
        bytes memory queryInit = abi.encodeWithSignature(
            "initialize((address,address,address,address,bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        AxiomV2Query queryImpl = new AxiomV2Query();
        address addr = create3.deploy(
            salt, abi.encodePacked(type(AxiomProxy).creationCode, abi.encode(address(queryImpl), queryInit))
        );
        AxiomProxy _queryProxy = AxiomProxy(payable(addr));
        return address(_queryProxy);
    }

    function _deployQueryMock(IAxiomV2Query.AxiomV2QueryInit memory init, bytes32 salt) internal returns (address) {
        bytes memory queryInit = abi.encodeWithSignature(
            "initialize((address,address,address,address,bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
            init
        );
        AxiomV2QueryMock queryImpl = new AxiomV2QueryMock();
        address addr = create3.deploy(
            salt, abi.encodePacked(type(AxiomProxy).creationCode, abi.encode(address(queryImpl), queryInit))
        );
        AxiomProxy _queryProxy = AxiomProxy(payable(addr));
        return address(_queryProxy);
    }
}
