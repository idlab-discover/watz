#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

mkdir -p $LOGS_DIR/onnx/

ITER=1

announcerun "native"

for iterations in $(seq $ITER)
do
    sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "/root/onnx_native 2>&1" | tee -a $LOGS_DIR/onnx/ree-native.csv 
done

announcerun "tee native"

for iterations in $(seq $ITER)
do
    sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "/root/onnx_native_tee 2>&1" | tee -a $LOGS_DIR/onnx/tee-native.csv 
done

announcerun "wasm"
wasm_heap_size=$((1 * $(mib)))

for iterations in $(seq $ITER)
do
    sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "iwasm --heap-size=$wasm_heap_size onnx.aot 2>&1" | tee -a $LOGS_DIR/onnx/ree-wasm.csv
done

announcerun "tee wasm"
wasm_heap_size=$((1 * $(mib)))
# initial_linear_memory_size=$((42 * $(mib)))
initial_linear_memory_size=$((10 * $(mib)))
#
# for iterations in {1..500}
# do
#     sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "taskset -c 8-11 watz $wasm_heap_size $initial_linear_memory_size /root/onnx.aot 2>&1" | tee -a $LOGS_DIR/onnx/tee-pinned.csv
# done
#
for iterations in $(seq $ITER)
do
    sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size $initial_linear_memory_size /root/onnx.aot 2>&1" | tee -a $LOGS_DIR/onnx/tee-unpinned.csv
done
