#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

deploywatz
deploywamr

announcedeploy "onnx"
cd $SCRIPT_DIR
mkdir -p out

if [ "$TARGET" == "JETSON" ]; then
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/onnx_native $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/

  sshpass -p "$BM_BOARD_PASS" rsync --progress out/ca/onnx_native_tee $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/ta/ffbe14df-62b5-429e-966d-866d47cedaec.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/ffbe14df-62b5-429e-966d-866d47cedaec.ta'
  
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/onnx.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/
elif [ "$TARGET" == "QEMU" ]; then
  # sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT out/polybench_all.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT -r out/*.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-wasm/
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT -r out/*_native $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-native/
fi
