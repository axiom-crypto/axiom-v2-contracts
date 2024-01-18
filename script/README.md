# Axiom V2 Deploy Scripts

This folder contains deployment configurations and scripts for the Axiom V2 contracts.

## Configuration

We specify deployments by:

- `chain_id`: The chain ID for the EVM chain or testnet the deployment is on.
- `multisig_type`: This is either `prod` or `staging`, denoting the type of multisig admin addresses each deployment is made with.
- `tag`: English language encoding of `chain_id` and `multisig_type`
- `version`: A string indicating the version of the deployment, which includes both smart contracts and ZK circuits.

Configuration is done through the `config` folder, which contains:

- `deployed.json`: A JSON file containing a mapping between `{chain_id}_{multisig_type}` and `tag`, `version`, and deployed contract addresses. Deployments which do not yet exist are assigned addresses of `address(0)`, and we expect deployments for a subset of:
  - `core_mock_address`
  - `header_verifier_mock_address`
  - `query_mock_address`
  - `core_verifier_address`
  - `core_historical_verifier_address`
  - `core_historical_mock_address`
  - `core_address`
  - `header_verifier_address`
  - `query_verifier_address`
  - `query_address`
- `predeployed.json`: A JSON file containing a mapping between `{chain_id}_{multisig_type}` and `tag` and deployed CREATE3, multisig, and prover addresses for contract initialization. We expect:
  - `create3`
  - `timelock`
  - `guardian`
  - `unfreeze`
  - `core_prover`
  - `query_provers`
- `query_params.json`: A JSON file containing a mapping between `{chain_id}_{multisig_type}` and initialization parameters for AxiomV2Query. We expect:
  - `queryDeadlineInterval`
  - `proofVerificationGas`
  - `axiomQueryFee`
  - `minMaxFeePerGas`
  - `maxQueryDeadlineInterval`
- `zk.json`: A JSON file containing the metadata locations for each verifier file. We expect:
  - `version`: A version string
  - `core_verifier_metadata`
  - `core_historical_verifier_metadata`
  - `core_goerli_verifier_metadata`
  - `core_historical_goerli_verifier_metadata`
  - `query_verifier_metadata`
