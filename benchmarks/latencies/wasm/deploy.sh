#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

deploywatz
deploywamr

announcedeploy "latencies-wasm"
cd $SCRIPT_DIR
sshpass -p "$BM_BOARD_PASS" rsync --progress out/bm_latencies.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
sshpass -p "$BM_BOARD_PASS" rsync --progress out/bm_latencies.wasm $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
