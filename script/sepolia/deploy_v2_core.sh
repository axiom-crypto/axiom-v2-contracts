#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/sepolia/AxiomV2CoreDeploy.s.sol:AxiomV2CoreDeploy --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $SEPOLIA_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 

# if sepolia slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
#forge script script/sepolia/AxiomV2CoreDeployMock.s.sol:AxiomV2CoreDeployMock --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $SEPOLIA_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv