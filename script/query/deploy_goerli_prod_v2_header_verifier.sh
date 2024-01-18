#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/query/AxiomV2HeaderVerifierDeploy.s.sol:AxiomV2HeaderVerifierDeploy --sig "run(uint64,bool)" --sender $SENDER_ADDRESS  --private-key $PRIVATE_KEY --rpc-url $GOERLI_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 11155111 true

# if mainnet slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
#forge script script/query/AxiomV2HeaderVerifierDeploy.s.sol:AxiomV2HeaderVerifierDeploy --sig "run(uint64,bool)" --sender $SENDER_ADDRESS  --private-key $PRIVATE_KEY --rpc-url $GOERLI_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv 11155111 true