#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

mkdir -p $LOGS_DIR/polybench/

wasm_heap_size=$((1 * $(mib)))
initial_linear_memory_size=$((42 * $(mib)))
# polybench_files=$SCRIPT_DIR/out/wasm/*.aot


# for file in $polybench_files
# do
    # local_file=$(basename $file)
    # announcerun "polybench TEE ($local_file)"

for iterations in {1..50}
do
    sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size $initial_linear_memory_size /root/polybench_all.aot 2>&1" | tee -a $LOGS_DIR/polybench/tee.csv
done
# done
