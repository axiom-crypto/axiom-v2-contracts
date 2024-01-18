# Axiom V2 SNARK Verifiers

This folder contains ZK verifier contracts and metadata files for the ZK circuits used in Axiom V2. The list of ZK circuit verifiers we expect are:

- `core`:
  - `AxiomV2CoreVerifier`: ZK verifier for circuit proving a chain of up to 1024 block headers.
  - `AxiomV2CoreHistoricalVerifier`: ZK verifier for circuit proving a chain of 128 \* 1024 block headers.
  - `AxiomV2CoreGoerliVerifier`: ZK verifier for circuit proving a chain of up to 1024 block headers for Goerli testnet.
  - `AxiomV2CoreHistoricalGoerliVerifier`: ZK verifier for circuit proving a chain of 128 \* 1024 block headers for Goerli testnet.
- `query`:
  - `AxiomV2QueryVerifier`: ZK verifier for Axiom V2 queries.

### Verifier Versions and Metadata

We arrange the verifiers into folders based on their **version** so that the verifiers for `version` is located at:

- `core/{version}/{verifier_name}.{version}.sol`
- `query/{version}/{verifier_name}.{version}.sol`

For example, the ZK circuit verifier `AxiomV2CoreVerifier` for version `0.11` is located at `core/v0.11/AxiomV2CoreVerifier.v0.11.sol`.

Each ZK verifier has associated metadata, which is contained in a **ZK metadata file** located at:

- `core/{version}/{verifier_name}.{version}.zk.json`
- `query/{version}/{verifier_name}.{version}.zk.json`

Each metadata file is a JSON with keys:

- `name`: The name of the verifier, e.g. `AxiomV2CoreVerifier`
- `version`: The version of the ZK circuit, e.g. `0.11`.
- `repo`: The Github repo of the code used to generate the circuit, e.g. `github.com/axiom-crypto/axiom-eth`
- `circuit_daata` (optional): A JSON containing additional circuit-specific metadata. For `AxiomV2QueryVerifier`, we expect this to have a single key `aggregate_vkey_hashes` which is an array of bytes32 hashes.
