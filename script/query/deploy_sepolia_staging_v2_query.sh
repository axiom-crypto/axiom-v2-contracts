#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/query/AxiomV2QueryDeploy.s.sol:AxiomV2QueryDeploy --sig "run(uint64,bool,uint256)" --sender $SENDER_ADDRESS  --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 11155111 false $1

# if mainnet slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
#forge script script/query/AxiomV2QueryDeploy.s.sol:AxiomV2QueryDeploy --sig "run(uint64,bool,uint256)" --sender $SENDER_ADDRESS  --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv 11155111 false $1