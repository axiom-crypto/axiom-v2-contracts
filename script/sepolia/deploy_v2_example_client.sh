#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/sepolia/ExampleV2ClientDeploy.s.sol:ExampleV2ClientDeploy --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --rpc-url $SEPOLIA_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast