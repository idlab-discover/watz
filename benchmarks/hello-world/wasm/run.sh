#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

wasm_heap_size=$((1 * 1024 * 1024))

# announcerun "latencies-wasm (time in WAMR)"
# sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'iwasm hello_world.wasm 2>&1'
# sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'iwasm hello_world.aot 2>&1'

announcerun "latencies-wasm (time in WaTZ)"
sshpass -p "$BM_BOARD_PASS" ssh -p 2222 $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size hello_world.aot 2>&1"
