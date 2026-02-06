#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

deploywatz
deploywamr

announcedeploy "polybench"
cd $SCRIPT_DIR
mkdir -p out
# mv $BM_BUILDER_PATH/polybench/out/\*.aot out/wasm
# mv $BM_BUILDER_PATH/dist/polybench-c/output/\* out/native

if [ "$TARGET" == "JETSON" ]; then
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/polybench_all.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/
  # sshpass -p "$BM_BOARD_PASS" rsync --progress out/polybench_all $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/

  # sshpass -p "$BM_BOARD_PASS" rsync --progress -r out/wasm/ $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-wasm/
  # sshpass -p "$BM_BOARD_PASS" rsync --progress -r out/native/ $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-native/
  
  # sshpass -p "$BM_BOARD_PASS" rsync --progress out/ca/polybench_native_tee $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  # sshpass -p "$BM_BOARD_PASS" rsync --progress out/ta/a0be14df-62b5-429e-966d-866d47cedaec.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  # sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/a0be14df-62b5-429e-966d-866d47cedaec.ta'
elif [ "$TARGET" == "QEMU" ]; then
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT out/polybench_all.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/
  # sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT -r out/*.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-wasm/
  # sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT -r out/*_native $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-native/
fi
