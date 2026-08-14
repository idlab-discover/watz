#!/bin/bash

# Warm up:
# vedliot_attester 12582912 launch-time/bm_launch-time_11.aot

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

announcerun "launch-time"

mkdir -p $LOGS_DIR/launch-time/
rm -f $LOGS_DIR/launch-time/general.csv

if [ "$WAMR_VERSION" == "old" ]; then
    max_size=12
elif [ "$WAMR_VERSION" == "new" ]; then
    max_size=2
fi

for size in $( seq 1 $max_size); do
  # for iterations in {1..100}; do
    if [ "$WAMR_VERSION" == "old" ]; then
        wasm_heap_size=$((($size + 4) * $(mib)))
    
        echo "$size,$(sshpass -p $BM_BOARD_PASS ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size launch-time/bm_launch-time_$size.aot 2>&1")" | tee -a $LOGS_DIR/launch-time/general.csv
    elif [ "$WAMR_VERSION" == "new" ]; then
        wasm_heap_size=$((($size + 2) * $(mib)))
        initial_linear_memory_size=$(($size * $(mib)))

        echo "$size,$(sshpass -p $BM_BOARD_PASS ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "sudo ./watz $wasm_heap_size $initial_linear_memory_size launch-time/bm_launch-time_$size.aot 2>&1")" | tee -a $LOGS_DIR/launch-time/general.csv
    fi

    safesleep
  # done
done
