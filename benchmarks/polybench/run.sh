#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

mkdir -p $LOGS_DIR/polybench/

# wasm_heap_size=$((10 * 1024 * 1024))

# for iterations in {1..500}
# do
#     sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "/root/polybench_all 2>&1" | tee -a $LOGS_DIR/polybench/ree-native.csv 
# done

# for iterations in {1..500}
# do
#     sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "iwasm --heap-size=$wasm_heap_size polybench_all.aot 2>&1" | tee -a $LOGS_DIR/polybench/ree-wasm.csv
# done

wasm_heap_size=$((1 * $(mib)))
# wasm_heap_size=$((10 * $(mib)))
initial_linear_memory_size=$((42 * $(mib)))
# initial_linear_memory_size=$((10 * $(mib)))

for iterations in {1..500}
do
    sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "taskset -c 8-11 watz $wasm_heap_size $initial_linear_memory_size /root/polybench_all.aot 2>&1" | tee -a $LOGS_DIR/polybench/new_watz/tee-pinned.csv
    # sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "taskset -c 8-11 watz $wasm_heap_size /root/old_watz/polybench_all.aot 2>&1" | tee -a $LOGS_DIR/polybench/old_watz/tee-pinned.csv
done

# for iterations in {1..500}
# do
#     sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size $initial_linear_memory_size /root/polybench_all.aot 2>&1" | tee -a $LOGS_DIR/polybench/tee-unpinned.csv
# done
