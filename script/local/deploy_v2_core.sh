#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env
LOCAL_RPC_URL="http://127.0.0.1:8545"

# Make sure environmental variables are already exported

forge script script/local/AxiomV2CoreDeploy.s.sol:AxiomV2CoreDeploy --sig "run(uint64,uint256,address)" --private-key $ANVIL_PRIVATE_KEY --rpc-url $LOCAL_RPC_URL --force -vvvv --broadcast 1 $1 $SENDER_ADDRESS 