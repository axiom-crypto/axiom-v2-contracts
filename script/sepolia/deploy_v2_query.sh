#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/sepolia/AxiomV2QueryDeploy.s.sol:AxiomV2QueryDeploy --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $SEPOLIA_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 

# if sepolia slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
#forge script script/sepolia/AxiomV2QueryDeploy.s.sol:AxiomV2QueryDeploy --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $SEPOLIA_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv