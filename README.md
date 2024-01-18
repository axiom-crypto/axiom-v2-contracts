# Axiom V2 Contracts

This repo implements smart contracts for Axiom V2, which enables smart contracts to access and compute over the history of Ethereum. The correctness of all queries into Axiom V2 is cryptographically verified by ZK proofs which check the correctness of the compute and data access against an on-chain cache of historic Ethereum block hashes.

## Repository Overview

The main contracts in this repository are `AxiomV2Core` and `AxiomV2Query`:

-   `AxiomV2Core` maintains an on-chain commitment to all historic Ethereum block hashes back to genesis.
-   `AxiomV2Query` accepts Axiom queries involving user computations over historic block headers, accounts, storage slots, transactions, receipts, and Solidity mapping values and allows fulfillment by verifying ZK proofs and checking their roots of trust against `AxiomV2Core`. `AxiomV2Query` depends on the following auxiliary contracts:
    -   `AxiomV2HeaderVerifier`: Verifies authenticity of the padded Merkle mountain range which roots trust for ZK proofs of a query against the block hash cache in `AxiomV2Core`.

In addition to these core contracts, the repo contains:

-   `contracts`
    -   `client`: Contracts relating to client contracts written by dapps integrating Axiom to receive callbacks from Axiom.
        -   `AxiomV2Client`: Abstract base contract for receiving callbacks from `AxiomV2Query`.
        -   `ExampleV2Client`: Example client for receiving callbacks from `AxiomV2Query`.
    -   `core/AxiomV2Core`: Core contract to maintain a commitment to all historic block hashes on Ethereum.
    -   `interfaces`: Interfaces for each other contract.
    -   `libraries`
        -   `access`
            -   `AxiomAccess`: Abstract base contract to control permissions for Axiom contracts. For use in UUPS upgradeable contracts.
            -   `AxiomProxy`: `ERC1967Proxy` for Axiom contracts.
            -   `AxiomTimelock`: OpenZeppelin `TimelockController` for Axiom contracts.
        -   `configuration`
            -   `AxiomV2Configuration`: Configuration constants for `AxiomV2Core` and `AxiomV2Query`.
        -   `Hash`: Library to efficiently perform packed Keccak on two concatenated `bytes32`.
        -   `MerkleMountainRange`: Library to maintain a Merkle mountain range data structure.
        -   `MerkleTree`: Library to compute Merkle root of a Merkle tree.
        -   `PaddedMerkleMountainRange`: Library to maintain a padded Merkle mountain range, which consists of a Merkle mountain range whose last few peaks are replaced by a Merkle root of a 0-padded Merkle tree.
    -   `mock`:
        -   `AxiomV2CoreMock`: Mock version of `AxiomV2Core`. Identical to `AxiomV2Core` with ZK proof verification skipped.
        -   `AxiomV2CoreHistoricalMock`: Mock version of `AxiomV2Core`. Identical to `AxiomV2Core` with ZK proof verification skipped for the initial historical import only.
        -   `AxiomV2QueryMock`: Mock version of `AxiomV2Query`. Identical to `AxiomV2Query` with ZK proof verification skipped.
    -   `query`
        -   `AxiomV2HeaderVerifier`: Verifies authenticity of the padded Merkle mountain range which roots trust for ZK proofs of a query against the block hash cache in `AxiomV2Core`.
        -   `AxiomV2Query`: Manages queries into Axiom.
-   `script`: Deployment scripts for `client`, `core`, and `query`. This also has folders for common deployment utilities in `base`, configuration in `config`, and local Anvil fork deployments in `local`.
-   `snark-verifiers`
    -   `core/{version}/AxiomV2CoreGoerliVerifier.{version}.sol`: On-chain verifier for ZK circuits verifying chains of up to 1024 block headers on Goerli testnet for `AxiomV2Core`. These are versioned.
    -   `core/{version}/AxiomV2CoreVerifier.{version}.sol`: On-chain verifier for ZK circuits verifying chains of up to 1024 block headers on mainnet for `AxiomV2Core`. These are versioned.
    -   `core/{version}/AxiomV2CoreHistoricalGoerliVerifier.{version}.sol`: On-chain verifier for ZK circuits verifying chains of 128 \* 1024 block headers on Goerli testnet for `AxiomV2Core`. These are versioned.
    -   `core/{version}/AxiomV2CoreHistoricalVerifier.{version}.sol`: On-chain verifier for ZK circuits verifying chains of 128 \* 1024 block headers on mainnet for `AxiomV2Core`. These are versioned.
    -   `query/{version}/AxiomV2QueryVerifier.{version}.sol`: On-chain verifier for ZK circuit verifying Axiom V2 queries. These are versioned.
-   `test`: Unit and integration tests for all smart contracts.

## Contract Documentation

### `AxiomV2Core`

`AxiomV2Core` is the core Axiom contract for caching all historic Ethereum block hashes. The overall goal is that the contract state [`IAxiomV2State`](contracts/interfaces/core/IAxiomV2State.sol) should contain commitments to all Ethereum block hashes from genesis to `recentBlockNumber` where `recentBlockNumber` is in `[block.number - 256, block.number)`.

These historic block hashes are stored in two ways:

-   As a Merkle root corresponding to a batch of block numbers `[startBlockNumber, startBlockNumber + numFinal)` where `startBlockNumber` is a multiple of `1024`, and `numFinal` is in `[1,1024]`. This is stored in `historicalRoots`.
-   As a padded Merkle mountain range of the Merkle roots of batches of 1024 block hashes starting from genesis to a recent block.

#### Updating the cache of Merkle roots

The cache of Merkle roots of block hashes in `historicalRoots`, and the interface to update it is provided in [`IAxiomV2Update`](contracts/interfaces/core/IAxiomV2Update.sol). The following functions allow for updates:

-   `updateRecent`: Verifies a zero-knowledge proof that proves the block header commitment chain from `[startBlockNumber, startBlockNumber + numFinal)` is correct, where `startBlockNumber` is a multiple of `1024`, and `numFinal` is in `[1,1024]`. This reverts unless `startBlockNumber + numFinal - 1` is in `[block.number - 256, block.number)`, i.e., if `blockhash(startBlockNumber + numFinal - 1)` is accessible from within the smart contract at the block this function is called. The zero-knowledge proof checks that each parent hash is in the block header of the next block, and that the block header RLP hashes to the block hash. This is accepted only if the block hash of `startBlockNumber + numFinal - 1`, according to the zero-knowledge proof, matches the block hash according to the EVM.
-   `updateOld`: Verifies a zero-knowledge proof that proves the block header commitment chain from `[startBlockNumber, startBlockNumber + 1024)` is correct, where block `startBlockNumber + 1024` must already be cached by the smart contract. This stores a single new Merkle root in the cache.
-   `updateHistorical`: Same as `updateOld` except that it uses a different zero-knowledge proof to prove the block header commitment chain from `[startBlockNumber, startBlockNumber + 2 ** 17)`. Requires block `startBlockNumber + 2 ** 17` to already be cached by the smart contract. This stores `2 ** 7 = 128` new Merkle roots in the cache.

As an initial safety feature, the `update*` functions are permissioned to only be callable by a 'prover' role.

#### Updating the padded Merkle mountain range

The `blockhashPmmr` stores a padded Merkle mountain range which commits to a contiguous chain of block hashes starting from genesis using:

-   A Merkle mountain range over Merkle roots of 1024 consecutive block hashes
-   A padded Merkle root of part of the most recent 1024 block hashes.

The `pmmrSnapshots` mapping caches commitments to recent values of `blockhashPmmr` to facilitate asynchronous proving against a padded Merkle mountain range which may be updated on-chain during proving. Updates to `blockhashPmmr` are made using newly verified Merkle roots added to `historicalRoots`. There are two update methods:

-   `updateRecent`: We extend `blockhashPmmr` based on the new block hashes proven in `updateRecent` and update the cache in `pmmrSnapshots`.
-   `appendHistoricalPMMR`: If there are new Merkle roots in `historicalRoots` which are not committed to in `blockhashPmmr` (usually because they were added by `updateOld`), this function appends them to `blockhashPmmr` in a single batch.

#### Reading from the cache

Most users will primarily interact with the [`IAxiomV2Verifier`](contracts/interfaces/core/IAxiomV2Verifier.sol) interface to read from the block hash cache.

-   Verifying the block hash of a block within the last `256` most recent blocks can be done through `isRecentBlockHashValid`.
-   To verify a historical block hash, one should use the `isBlockHashValid` method which takes in a witness that a block hash is included in the cache, formatted via struct `IAxiomV2Verifier.BlockHashWitness`. This provides a Merkle proof of a block hash into the Merkle root of a batch (up to `1024` blocks) stored in `historicalRoots`. The `isBlockHashValid` method verifies that the Merkle proof is a valid Merkle path for the relevant block hash and checks that the Merkle root lies in the cache.

### `AxiomV2Query`

`AxiomV2Query` uses `AxiomV2Core` to fulfill queries made by users into Axiom V2. `AxiomV2Query` supports the [Axiom V2 Query Format](#axiom-v2-query-format) and supports:

-   On-chain query requests with on- or off-chain data availability for queries and on-chain payment or refunds.
-   On-chain fulfillment of queries with on-chain proof verification.

#### Initiating queries on-chain

Users can initiate a query on-chain with on-chain payment. Both on- and off-chain data availability are supported for the data query:

-   `sendQuery`: Send an on-chain query with on-chain data availability.
-   `sendQueryWithIpfsData`: Send an on-chain query with data availability on IPFS.

On-chain queries are identified by `queryId` as specified in the [Axiom V2 Query Format](#axiom-v2-query-format). For each query, `AxiomQueryMetadata` in `queries[queryId]` stores the relevant metadata, consisting of:

-   `state` (`uint8`): One of `AXIOM_QUERY_STATE_INACTIVE`, `AXIOM_QUERY_STATE_ACTIVE`, `AXIOM_QUERY_STATE_FULFILLED`, or `AXIOM_QUERY_STATE_PAID`.
-   `deadlineBlockNumber` (`uint32`): The block number after which the query is eligible for a refund.
-   `callbackGasLimit` (`uint32`): The gas limit to use in the callback upon fulfillment.
-   `payee` (`address`): Once fulfilled, the address payment is due to.
-   `payment` (`uint256`): The payment amount, in gwei, escrowed for this query.

#### Query fulfillment

Query fulfillment is permissioned to:

-   accounts holding the `PROVER_ROLE`, initially anticipated to be controlled by the Axiom team for safety at the moment
-   additional accounts permissioned for each `(querySchema, target)` pair, tracked in the `allowedProvers` mapping

There are two ways to fulfill queries:

-   `fulfillQuery`: Fulfill an existing on-chain query.
-   `fulfillOffchainQuery`: Fulfill a query which was initiated off-chain.

These functions take in a ZK proof verifying a query and fulfill the query by:

-   verifying the ZK proof on-chain
-   checking the Merkle mountain range the proof verifies the query into is committed in `AxiomV2Core` using `AxiomV2HeaderVerifier`
-   for on-chain queries, checking that the query verified corresponds to the on-chain query by matching the `queryHash`
-   calling the desired callback

#### Fees and permissions

All fees are charged in ETH. User balances are maintained in the `balances` mapping.

-   To deposit, users can use `deposit` or transfer ETH together with their on-chain query.
-   To withdraw, users can use `withdraw`.

The fee for each query is determined by the `AxiomV2FeeData` data structure, which contains:

-   `maxFeePerGas` (`uint64`): The max fee to use in the fulfillment transaction.
-   `callbackGasLimit` (`uint32`): Gas limit allocated for use in the callback.
-   `overrideAxiomQueryFee` (`uint256`): If larger than `axiomQueryFee`, the value to be used for the query fee.

Each on-chain query will escrow a max payment of

```
maxQueryPri = maxFeePerGas * (callbackGasLimit + proofVerificationGas) + _axiomQueryFee;
```

where

-   `proofVerificationGas`: Gas cost of proof verification, fixed to `420_000`
-   `_axiomQueryFee`: Fee charged by Axiom, fixed to the higher of `overrideAxiomQueryFee` and `axiomQueryFee`, which is set to `0.003 ether`

To increase gas parameters after making a query, anyone can add funds to a query with `increaseQueryGas`.

Upon fulfillment, the `maxQueryPri` fee is released to the prover, who can call `unescrow` to claim payment.

-   The prover can refund the portion of `maxQueryPri` not used in gas or paid to the prover as fee to the original query `caller`.
-   If the query is not fulfilled by `deadlineBlockNumber`, the `caller` can retrieve their fees paid using `refundQuery`

### `AxiomV2HeaderVerifier`

`AxiomV2HeaderVerifier` verifies that a Merkle mountain range `proofMmr` of block hashes is committed to by block hashes available to `AxiomV2Core` in `verifyQueryHeaders`. This happens by comparing `proofMmr` to:

-   the padded Merkle mountain ranges committed to in `pmmrSnapshots` and `blockhashPmmr`
-   the block hashes available in the EVM via the `BLOCKHASH` opcode

## Contract permissions and upgrades

The contracts `AxiomV2Core` and `AxiomV2Query` implement UUPS Upgradeability, freezing, and unfreezing functionality, controlled by the `AxiomAccess` contract. The relevant roles are:

-   `TIMELOCK_ROLE`: All upgrades, including upgrades of the underlying SNARK verifier addresses, are controlled by a OpenZeppelin [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController) with a 1 week delay controlled by a Axiom multisig. To rule out the possibility of timelock bypass by metamorphic contracts, users should verify that the contracts deployed at verifier contracts do not contain the SELFDESTRUCT or DELEGATECALL opcodes. This can be done by viewing all contract opcodes on Etherscan as detailed [here](https://ethereum.org/en/developers/tutorials/reverse-engineering-a-contract/#prepare-the-executable-code).
-   `GUARDIAN_ROLE`: This role allows for immediate freezing of critical functions like `AxiomV2Core` block hash updates and `AxiomV2Query` query initiation and fulfillment. The freeze functionality is intended to be used in the event of an unforeseen ZK circuit bug. This role is held by an Axiom multisig.
-   `UNFREEZE_ROLE`: This role allows for immediate unfreezing of contracts. It is held by an Axiom multisig with a higher threshold than `GUARDIAN_ROLE`.
-   `PROVER_ROLE`: This role is given to accounts which are permissioned to prove in the Axiom system.

## Axiom V2 Query Format

Axiom V2 queries allow users to compute over historic data on Ethereum. These queries consist of the following three pieces:

-   **Data query:** ZK authenticated access to historic block headers, accounts, storage slots, transactions, receipts, and Solidity mapping values from the history of Ethereum.
-   **Compute query:** ZK-proven computation over the data authenticated in the data query.
-   **Callback:** An on-chain callback to invoke with the result of the compute query.

All three of the data, compute, and callback are optional, but a valid query must have at least one of the data or compute queries.

### Query format specification

The query is specified by the following fields, of which we will detail the data, compute, and callback details below.

-   `version` (`uint8`) -- the version, fixed to be `uint8(2)` for Axiom V2.
-   `sourceChainId` (`uint64`) -- the source `chainId`
-   `caller` (`address`) -- the address of the caller
-   `dataQueryHash` (`bytes32`) -- the encoded data query
-   `computeQuery` (`AxiomV2ComputeQuery`) -- the compute query
-   `callback` (`AxiomV2Callback`) -- the callback
-   `feeData` (`AxiomV2FeeData`) -- data associated to query fees
-   `userSalt` (`bytes32`) -- salt chosen by the user
-   `refundee` (`address`) -- address taking refunds

We create an unique identifier for the query via:

```
queryId = uint256(keccak(chainId . caller . userSalt . queryHash . callbackHash . refundee))
```

where

-   `chainId` is the chainId of the target chain
-   `queryHash` is:
    -   for `k > 0`: `keccak(version . sourceChainId . dataQueryHash . encodedComputeQuery)` for `encodedComputeQuery = k . resultLen . vkeyLen . vkey . proofLen . computeProof`
    -   for `k = 0`: `keccak(version . sourceChainId . dataQueryHash . k . resultLen)`
-   `callbackHash = keccak(target . extraData)`
-   `uint8 vkeyLen` is the length of `vkey` as `bytes32[]`
-   `proofLen` is the length of `computeProof` as `bytes`

We also define the query schema via:

```
querySchema = keccak(k . resultLen . vkeyLen . vkey)
```

> The difference between `queryHash` and `querySchema` is that `querySchema` specifies a general schema for a query, with unknown variables which may change from instance to instance. `queryHash` specifies a specific instance of the query schema, where all unknown variables have numerical values.

### Query result specification

We anticipate a ZK proof for each query with public input/outputs consisting of:

-   `sourceChainId` (`uint64`) -- the source `chainId`
-   `computeResultsHash` (`bytes32`) -- the Keccak hash of `computeResults`, specified as:
    -   `computeResults` (`bytes32[]`) -- the result of applying the compute circuit with the data subquery outputs as public inputs
    -   if no compute is needed, this is the first `resultLen` data results.
-   `queryHash` (`bytes32`) -- the `queryHash` identifying the query.
-   `querySchema` (`bytes32`) -- the `querySchema` identifying the query type.
-   `blockhashMMRKeccak` (`bytes32`) -- witness data for reconciling the proof against `AxiomV2Core`
-   `aggregateVkeyHash` (`bytes32`) -- a hash identifying the aggregation strategy used to generate a ZK proof of the query result.
-   `payee` (`address`) -- a free public input which is associated to a private witness in the proof to avoid malleability issues

### Data query format

Each data query consists of the fields:

-   `sourceChainId` (`uint64`) -- the `chainId` of the source chain
-   `subqueries` (`Subquery[]`)

Each **subquery** has a result given by a single `uint256` or `bytes32` and is specified by

-   `type` (`uint16`) -- a number identifying the **subquery type**
-   `subqueryData` -- data specifying the subquery which follows a different **subquery schema** for each `type`.
    -   This should be of a max size over all subquery types.

We encode the query by:

-   `dataQueryHash` (`bytes32`): The Keccak hash of `sourceChainId` concatenated with the array with entries given by:
    -   `keccak(type . subqueryData)`

Each subquery has a `result` which is of type `uint256` or `bytes32`, with smaller datatypes left-padded with 0's. If a user wishes to access multiple fields from e.g. a single account or receipt, they must make multiple subqueries. We hope this does not impose too much overhead, since we will only constrain the Keccak hashes once in the Keccak table.

We have 6 subquery types, corresponding to:

-   `block_header`: fields from block header
-   `account`: fields from accounts, e.g. nonce, balance, codeHash, storageRoot
-   `storage`: slots in account local storage
-   `transaction`: fields from transactions, including indexing into calldata.
-   `receipt`: fields from receipts, including indexing into topics and data of logs.
-   `solidity_nested_mapping`: values from nested mappings of value types

### Compute query format

The compute query is specified by `AxiomV2ComputeQuery`, which contains:

-   `k` (`uint8`) -- degree of the compute circuit, equal to `0` if no compute is needed
-   `resultLen` (`uint16`) --- number of meaningful public outputs of the circuit
-   `vkey` (`bytes32[]`) -- verification key for the compute circuit
-   `computeProof` (`bytes32[]` or `bytes(0x0)`) -- user generated proof, equal to `bytes(0x0)` if no compute is needed or there is no user generated proof

If no compute proof is provided, then `k = 0` and `vkey, computeProof` are empty. In that case the `resultLen` specifies the number of data results to pass on to the callback.

### Callback format

The callback is specified by `AxiomV2Callback`, which contains:

-   `target` (`address`) -- equal to `address(0x0)` if no callback needed
-   `extraData` (`bytes`) -- additional data sent to the callback. Equal to `bytes(0x0)` if no callback is needed.

### Fee data format

The fee data is specified by `AxiomV2FeeData`, which contains:

-   `maxFeePerGas` (`uint64`) -- max fee to use on the fulfillment transaction
-   `callbackGasLimit` (`uint32`) -- gas limit to allocate for the callback
-   `overrideAxiomQueryFee` (`uint256`) -- if larger than `axiomQueryFee`, the value to be used for the query fee

## Development and Testing

Clone this repository (and git submodule dependencies) with

```bash
git clone --recurse-submodules -j8 https://github.com/axiom-crypto/axiom-v2-contracts.git
cd axiom-v2-contracts
cp .env.example .env
```

To run tests, fill in `.env` with your `INFURA_ID`.

### Unit tests

We use [Foundry](https://book.getfoundry.sh/) for smart contract development and testing. You can follow these [instructions](https://book.getfoundry.sh/getting-started/installation) to install it.

In order for Forge to access `MAINNET_RPC_URL` for testing, we need to export `.env`:

```bash
set -a
source .env
set +a
```

After installing `foundry`, run:

```bash
forge install
forge test
```

For verbose logging of events and gas tracking, run

```bash
forge test -vvvv
```
