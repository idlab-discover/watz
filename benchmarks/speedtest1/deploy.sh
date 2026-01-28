#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

deploywatz
deploywamr

announcedeploy "SQLite"

cd $SCRIPT_DIR

if [ "$TARGET" == "JETSON" ]; then
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/bm_speedtest1.wasm $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/bm_speedtest1.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/bm_speedtest1_native_ree $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root

  sshpass -p "$BM_BOARD_PASS" rsync --progress out/ca/bm_speedtest1_native_tee $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p "$BM_BOARD_PASS" rsync --progress out/ta/b4c9d236-cb68-45a5-b218-4266ca43b237.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/b4c9d236-cb68-45a5-b218-4266ca43b237.ta'
elif [ "$TARGET" == "QEMU" ]; then
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT out/bm_speedtest1.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT out/bm_speedtest1_native_ree $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root

  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT out/ca/bm_speedtest1_native_tee $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT out/ta/b4c9d236-cb68-45a5-b218-4266ca43b237.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/b4c9d236-cb68-45a5-b218-4266ca43b237.ta'
fi
