#!/bin/bash

cd $(git rev-parse --show-toplevel)
source .env
LOCAL_RPC_URL="http://localhost:8545"

# Make sure environmental variables are already exported

cast send --private-key $ANVIL_PRIVATE_KEY $SENDER_ADDRESS --value 100ether
forge script script/local/AxiomV2CoreDeployMock.s.sol:AxiomV2CoreDeployMock --sender $SENDER_ADDRESS --keystore $KEYSTORE_PATH --password $KEY_PASSWD --rpc-url $LOCAL_RPC_URL --broadcast -vvvv --skip tests
