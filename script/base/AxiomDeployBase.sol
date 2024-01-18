// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

import { ICREATE3Factory } from "@create3-factory/ICREATE3Factory.sol";
import { CREATE3Factory } from "@create3-factory/CREATE3Factory.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

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
import { AxiomV2Query } from "../../contracts/query/AxiomV2Query.sol";
import { AxiomV2QueryMock } from "../../contracts/mock/AxiomV2QueryMock.sol";

import {
    AxiomV2CoreVerifier,
    AxiomV2CoreHistoricalVerifier,
    AxiomV2CoreGoerliVerifier,
    AxiomV2CoreHistoricalGoerliVerifier,
    AxiomV2QueryVerifier
} from "../../snark-verifiers/AxiomVerifierImports.sol";

string constant PREDEPLOYED_ADDRESS_FILE = "script/config/predeployed.json";
string constant DEPLOYED_ADDRESS_FILE = "script/config/deployed.json";
string constant ZK_CONFIG_FILE = "script/config/zk.json";
string constant QUERY_PARAMS_FILE = "script/config/query_params.json";

abstract contract AxiomDeployBase is Script {
    ICREATE3Factory public create3;

    function _getPrefix(uint64 sourceChainId, bool isProd) internal pure returns (string memory prefix) {
        prefix = string.concat(".", Strings.toString(uint256(sourceChainId)));
        if (isProd) {
            prefix = string.concat(prefix, "-prod");
        } else {
            prefix = string.concat(prefix, "-staging");
        }
    }

    function _getCREATE3Addr(uint64 sourceChainId) internal returns (address) {
        return abi.decode(
            vm.parseJson(
                vm.readFile(PREDEPLOYED_ADDRESS_FILE), string.concat(_getPrefix(sourceChainId, true), ".create3")
            ),
            (address)
        );
    }

    function _deployCREATE3() internal returns (address) {
        CREATE3Factory create3Deploy = new CREATE3Factory();
        return address(create3Deploy);
    }

    function _getCoreAddress(uint64 sourceChainId, bool isProd) internal returns (address coreAddress) {
        string memory prefix = _getPrefix(sourceChainId, isProd);

        if (sourceChainId == MAINNET_CHAIN_ID) {
            coreAddress = abi.decode(
                vm.parseJson(vm.readFile(DEPLOYED_ADDRESS_FILE), string.concat(prefix, ".core_address")), (address)
            );
        } else if (sourceChainId == GOERLI_CHAIN_ID || sourceChainId == SEPOLIA_CHAIN_ID) {
            coreAddress = abi.decode(
                vm.parseJson(vm.readFile(DEPLOYED_ADDRESS_FILE), string.concat(prefix, ".core_historial_mock_address")),
                (address)
            );
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _getCoreMockAddress(uint64 sourceChainId, bool isProd) internal returns (address coreAddress) {
        string memory prefix = _getPrefix(sourceChainId, isProd);

        if (sourceChainId == MAINNET_CHAIN_ID) {
            revert("AxiomDeployBase: no AxiomV2CoreMock on mainnet");
        } else if (sourceChainId == GOERLI_CHAIN_ID || sourceChainId == SEPOLIA_CHAIN_ID) {
            coreAddress = abi.decode(
                vm.parseJson(vm.readFile(DEPLOYED_ADDRESS_FILE), string.concat(prefix, ".core_mock_address")), (address)
            );
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _getQueryMockAddress(uint64 sourceChainId, bool isProd) internal returns (address queryAddress) {
        string memory prefix = _getPrefix(sourceChainId, isProd);
        if (sourceChainId == MAINNET_CHAIN_ID) {
            revert("AxiomDeployBase: no AxiomV2QueryMock on mainnet");
        } else if (sourceChainId == GOERLI_CHAIN_ID || sourceChainId == SEPOLIA_CHAIN_ID) {
            queryAddress = abi.decode(
                vm.parseJson(vm.readFile(DEPLOYED_ADDRESS_FILE), string.concat(prefix, ".query_mock_address")),
                (address)
            );
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _getQueryAddress(uint64 sourceChainId, bool isProd) internal returns (address queryAddress) {
        string memory prefix = _getPrefix(sourceChainId, isProd);
        if (sourceChainId == MAINNET_CHAIN_ID || sourceChainId == GOERLI_CHAIN_ID || sourceChainId == SEPOLIA_CHAIN_ID)
        {
            queryAddress = abi.decode(
                vm.parseJson(vm.readFile(DEPLOYED_ADDRESS_FILE), string.concat(prefix, ".query_address")), (address)
            );
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _getMultisigAddresses(uint64 sourceChainId, bool isProd)
        internal
        returns (
            address timelock,
            address guardian,
            address unfreeze,
            address coreProver,
            address[] memory queryProvers
        )
    {
        string memory prefix = _getPrefix(sourceChainId, isProd);

        string memory addressFile = vm.readFile(PREDEPLOYED_ADDRESS_FILE);
        timelock = abi.decode(vm.parseJson(addressFile, string.concat(prefix, ".timelock")), (address));
        guardian = abi.decode(vm.parseJson(addressFile, string.concat(prefix, ".guardian")), (address));
        unfreeze = abi.decode(vm.parseJson(addressFile, string.concat(prefix, ".unfreeze")), (address));
        coreProver = abi.decode(vm.parseJson(addressFile, string.concat(prefix, ".core_prover")), (address));
        queryProvers = abi.decode(vm.parseJson(addressFile, string.concat(prefix, ".query_provers")), (address[]));
    }

    function _getQueryParams(uint64 sourceChainId)
        internal
        returns (
            uint32 queryDeadlineInterval,
            uint32 proofVerificationGas,
            uint256 axiomQueryFee,
            uint64 minMaxFeePerGas,
            uint32 maxQueryDeadlineInterval
        )
    {
        string memory prefix = _getPrefix(sourceChainId, true);
        string memory queryParamsFile = vm.readFile(QUERY_PARAMS_FILE);

        queryDeadlineInterval =
            abi.decode(vm.parseJson(queryParamsFile, string.concat(prefix, ".queryDeadlineInterval")), (uint32));
        proofVerificationGas =
            abi.decode(vm.parseJson(queryParamsFile, string.concat(prefix, ".proofVerificationGas")), (uint32));
        axiomQueryFee = abi.decode(vm.parseJson(queryParamsFile, string.concat(prefix, ".axiomQueryFee")), (uint256));
        minMaxFeePerGas = abi.decode(vm.parseJson(queryParamsFile, string.concat(prefix, ".minMaxFeePerGas")), (uint64));
        maxQueryDeadlineInterval =
            abi.decode(vm.parseJson(queryParamsFile, string.concat(prefix, ".maxQueryDeadlineInterval")), (uint32));
    }

    function _getAggregateVkeyHashes(uint32 version) internal returns (bytes32[] memory aggregateVkeyHashes) {
        string memory configFile = vm.readFile(ZK_CONFIG_FILE);
        string memory versionStr = string.concat("0.", Strings.toString(uint256(version)));
        string memory configVersionStr = abi.decode(vm.parseJson(configFile, ".version"), (string));
        if (
            bytes(versionStr).length != bytes(configVersionStr).length
                || keccak256(abi.encodePacked(versionStr)) != keccak256(abi.encodePacked(configVersionStr))
        ) {
            revert("AxiomDeployBase: version mismatch");
        }

        string memory queryMetadataPath = abi.decode(vm.parseJson(configFile, ".query_verifier_metadata"), (string));
        string memory queryMetadataFile = vm.readFile(queryMetadataPath);
        aggregateVkeyHashes =
            abi.decode(vm.parseJson(queryMetadataFile, ".circuit_data.aggregate_vkey_hashes"), (bytes32[]));
    }

    function _deployCoreVerifiers(uint64 sourceChainId)
        internal
        returns (address verifierAddress, address historicalVerifierAddress)
    {
        verifierAddress = _deployCoreVerifier(sourceChainId);
        historicalVerifierAddress = _deployCoreHistoricalVerifier(sourceChainId);
    }

    function _deployCoreVerifier(uint64 sourceChainId) internal returns (address verifierAddress) {
        if (sourceChainId == MAINNET_CHAIN_ID || sourceChainId == SEPOLIA_CHAIN_ID) {
            AxiomV2CoreVerifier verifier = new AxiomV2CoreVerifier();
            verifierAddress = address(verifier);
        } else if (sourceChainId == GOERLI_CHAIN_ID) {
            AxiomV2CoreGoerliVerifier verifier = new AxiomV2CoreGoerliVerifier();
            verifierAddress = address(verifier);
        } else {
            revert("AxiomDeployBase: invalid sourceChainId");
        }
    }

    function _deployCoreHistoricalVerifier(uint64 sourceChainId) internal returns (address historicalVerifierAddress) {
        if (sourceChainId == MAINNET_CHAIN_ID || sourceChainId == SEPOLIA_CHAIN_ID) {
            AxiomV2CoreHistoricalVerifier verifier = new AxiomV2CoreHistoricalVerifier();
            historicalVerifierAddress = address(verifier);
        } else if (sourceChainId == GOERLI_CHAIN_ID) {
            AxiomV2CoreHistoricalGoerliVerifier verifier = new AxiomV2CoreHistoricalGoerliVerifier();
            historicalVerifierAddress = address(verifier);
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
        address prover,
        bytes32 salt
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

        address addr = create3.deploy(
            salt, abi.encodePacked(type(AxiomProxy).creationCode, abi.encode(address(implementation), data))
        );
        AxiomProxy coreProxy = AxiomProxy(payable(addr));
        return address(coreProxy);
    }

    function _deployCoreMock(address timelock, address guardian, address unfreeze, address prover, bytes32 salt)
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
        address addr = create3.deploy(
            salt, abi.encodePacked(type(AxiomProxy).creationCode, abi.encode(address(implementation), data))
        );
        AxiomProxy coreProxy = AxiomProxy(payable(addr));
        return address(coreProxy);
    }

    function _deployCoreHistoricalMock(
        address verifier,
        address timelock,
        address guardian,
        address unfreeze,
        address prover,
        bytes32 salt
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
        address addr = create3.deploy(
            salt, abi.encodePacked(type(AxiomProxy).creationCode, abi.encode(address(implementation), data))
        );
        AxiomProxy coreProxy = AxiomProxy(payable(addr));
        return address(coreProxy);
    }

    function _deployHeaderVerifier(uint64 sourceChainId, address coreAddr) internal returns (address) {
        AxiomV2HeaderVerifier verifier = new AxiomV2HeaderVerifier(sourceChainId, coreAddr);
        return address(verifier);
    }

    function _deployQuery(IAxiomV2Query.AxiomV2QueryInit memory init, bytes32 salt) internal returns (address) {
        bytes memory queryInit = abi.encodeWithSignature(
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
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
            "initialize((address,address,address[],bytes32[],uint32,uint32,uint256,uint64,uint32,address,address,address))",
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
