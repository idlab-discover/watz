#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

mkdir -p $LOGS_DIR/speedtest1/

wasm_heap_size=$((1 * $(mib)))
initial_linear_memory_size=$((20 * $(mib)))

for iterations in {1..50}
do
    sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size bm_speedtest1.aot 2>&1" | tee -a $LOGS_DIR/speedtest1/tee-wasm.csv
done
