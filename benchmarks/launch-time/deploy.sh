#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

deploywatz

announcedeploy "launch-time"
cd $SCRIPT_DIR
if [ "$TARGET" == "JETSON" ]; then
  sshpass -p "$BM_BOARD_PASS" rsync --progress -r out/*.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/launch-time
elif [ "$TARGET" == "QEMU" ]; then
  sshpass -p "$BM_BOARD_PASS" scp -P $BM_SSH_PORT -r out/*.aot $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/launch-time
fi
