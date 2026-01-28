#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

./run-native-ree.sh
./run-native-tee.sh
./run-wasm-ree.sh
./run-wasm-tee.sh
