#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/mainnet/AxiomV2CoreDeploy.s.sol:AxiomV2CoreDeploy --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $MAINNET_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 

# if mainnet slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
#forge script script/mainnet/AxiomV2CoreDeploy.s.sol:AxiomV2CoreDeploy --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $MAINNET_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv