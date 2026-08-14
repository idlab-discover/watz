#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

mkdir -p $LOGS_DIR/polybench/

for iterations in {1..250}
do
    sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "nice -n -24 /root/polybench_native_tee 2>&1" | tee -a $LOGS_DIR/polybench/tee-native-nice.csv
    # sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "taskset -c 8-11 /root/polybench_native_tee 2>&1" | tee -a $LOGS_DIR/polybench/tee-native-pinned.csv
done

# for iterations in {1..500}
# do
#     sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "/root/polybench_native_tee 2>&1" | tee -a $LOGS_DIR/polybench/tee-native.csv
# done
