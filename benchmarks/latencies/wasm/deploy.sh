#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

deploywatz
deploywamr

announcedeploy "latencies-wasm"
cd $SCRIPT_DIR
if [ "$TARGET" == "JETSON" ]; then
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/bm_latencies.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/bm_latencies.wasm $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
elif [ "$TARGET" == "QEMU" ]; then
  sshpass -p $BM_BOARD_PASS scp -P $BM_SSH_PORT out/bm_latencies.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p $BM_BOARD_PASS scp -P $BM_SSH_PORT out/bm_latencies.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
fi
