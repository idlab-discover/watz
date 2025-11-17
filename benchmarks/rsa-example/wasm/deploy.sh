#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

deploywatz
deploywamr

announcedeploy "latencies-wasm"
cd $SCRIPT_DIR
sshpass -p $BM_BOARD_PASS scp -P 2222 out/rsa_example.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
