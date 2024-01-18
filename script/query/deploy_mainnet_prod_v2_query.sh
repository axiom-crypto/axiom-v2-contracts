#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/query/AxiomV2QueryDeploy.s.sol:AxiomV2QueryDeploy --sig "run(uint64,bool,uint256)" --sender $SENDER_ADDRESS --ledger --rpc-url $MAINNET_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 1 true $1

# if mainnet slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
#forge script script/query/AxiomV2QueryDeploy.s.sol:AxiomV2QueryDeploy --sig "run(uint64,bool,uint256)" --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH  --rpc-url $MAINNET_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv 1 true $1