#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

# announcerun "latencies-wasm (time in WAMR)"
# sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'iwasm bm_latencies.aot 1000 2>&1' | tee $LOGS_DIR/latencies/wasm-catime.csv

announcerun "latencies-wasm (time in WaTZ)"
if [ "$WAMR_VERSION" == "old" ]; then
  wasm_heap_size=$((1 * $(mib)))

  sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size bm_latencies.aot 1000 2>&1" | tee $LOGS_DIR/latencies/wasm-tatime.csv
elif [ "$WAMR_VERSION" == "new" ]; then
  wasm_heap_size=$((492 * 1024))
  initial_linear_memory_size=$((40 * 1024))

  sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size $initial_linear_memory_size bm_latencies.aot 1000 2>&1" | tee $LOGS_DIR/latencies/wasm-tatime.csv

  sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME "taskset -c 8-11 watz $wasm_heap_size $initial_linear_memory_size bm_latencies.aot 1000 2>&1" | tee $LOGS_DIR/latencies/wasm-tatime-pinned.csv
fi
