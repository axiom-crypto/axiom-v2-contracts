#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/goerli/AxiomV2CoreDeployMock.s.sol:AxiomV2CoreDeployMock --sender $SENDER_ADDRESS --private-key $HOT_KEY --rpc-url $GOERLI_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 

# if goerli slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
#forge script script/goerli/AxiomV2CoreDeployMock.s.sol:AxiomV2CoreDeployMock --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $GOERLI_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv