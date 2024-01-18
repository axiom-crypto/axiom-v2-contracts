#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/client/ExampleV2ClientDeploy.s.sol:ExampleV2ClientDeploy --sig "run(uint64,bool)" --sender $SENDER_ADDRESS  --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast 11155111 true