#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

announcedeploy "latencies-native ($TARGET)"

cd $SCRIPT_DIR

if [ "$TARGET" == "JETSON" ]; then
  sshpass -p $BM_BOARD_PASS rsync -e '/usr/bin/ssh -p 2222' --progress out/ca/bm_latencies_native $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin
  sshpass -p $BM_BOARD_PASS rsync -e '/usr/bin/ssh -p 2222' --progress out/ta/8d72603b-4813-436a-88ae-ea464d59d0c8.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  sshpass -p $BM_BOARD_PASS /usr/bin/ssh -p 2222 $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/8d72603b-4813-436a-88ae-ea464d59d0c8.ta'
elif [ "$TARGET" == "QEMU" ]; then
  sshpass -p $BM_BOARD_PASS scp -P 2222 out/ca/bm_latencies_native $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin
  sshpass -p $BM_BOARD_PASS scp -P 2222 out/ta/8d72603b-4813-436a-88ae-ea464d59d0c8.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  sshpass -p $BM_BOARD_PASS /usr/bin/ssh -p 2222 $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/8d72603b-4813-436a-88ae-ea464d59d0c8.ta'
fi
