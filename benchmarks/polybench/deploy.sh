#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

deploywatz
# deploywamr

announcedeploy "polybench"
cd $SCRIPT_DIR
mkdir -p out
# mv $BM_BUILDER_PATH/polybench/out/\*.aot out/wasm
# mv $BM_BUILDER_PATH/dist/polybench-c/output/\* out/native

if [ "$TARGET" == "JETSON" ]; then
  sshpass -p "$BM_BOARD_PASS" rsync --progress --include="out/*_aot" --exclude="out/*" -r out/ $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-wasm/
  sshpass -p "$BM_BOARD_PASS" rsync --progress --include="out/*_native"  --exclude="out/*" -r  out/ $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-native/
elif [ "$TARGET" == "QEMU" ]; then
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT -r out/*.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-wasm/
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT -r out/*_native $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/polybench-native/
fi
