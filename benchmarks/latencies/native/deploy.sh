#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../../common.sh

announcedeploy "latencies-native"

cd $SCRIPT_DIR

sshpass -p $BM_BOARD_PASS rsync --progress out/ca/bm_latencies_native $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin
sshpass -p $BM_BOARD_PASS rsync --progress out/ta/8d72603b-4813-436a-88ae-ea464d59d0c8.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
sshpass -p $BM_BOARD_PASS ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/8d72603b-4813-436a-88ae-ea464d59d0c8.ta'
