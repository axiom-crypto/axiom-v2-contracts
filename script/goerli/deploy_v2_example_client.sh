#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env

forge script script/goerli/ExampleV2ClientDeploy.s.sol:ExampleV2ClientDeploy --private-key $GOERLI_PRIVATE_KEY --rpc-url $GOERLI_RPC_URL --force --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --broadcast