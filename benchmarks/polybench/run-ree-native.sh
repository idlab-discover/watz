#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

mkdir -p $LOGS_DIR/polybench/

wasm_heap_size=$((10 * 1024 * 1024))


for iterations in {1..50}
do
    sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "/root/polybench_all 2>&1" | tee -a $LOGS_DIR/polybench/ree-native.csv 
done

# for iterations in {1..50}
# do
#     start=$(date +%s%N)
#     for file in $polybench_files
#     do
#         sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "polybench-native/$local_file 2>&1" 
#     done
#     end=$(date +%s%N)
#     echo "$start,$end" | tee -a $LOGS_DIR/polybench/ree-native.csv
# done
