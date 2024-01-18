#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/core/AxiomV2CoreDeploy.s.sol:AxiomV2CoreDeploy --sig "run(uint64,bool,uint256)" --sender $SENDER_ADDRESS  --private-key $PRIVATE_KEY --rpc-url $GOERLI_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 5 true $1

# if mainnet slow and fails to verify, https://github.com/foundry-rs/foundry/issues/2435 
# forge script script/core/AxiomV2CoreDeploy.s.sol:AxiomV2CoreDeploy --sig "run(uint64,bool,uint256)" --sender $SENDER_ADDRESS  --private-key $PRIVATE_KEY --rpc-url $GOERLI_RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv 5 true $1