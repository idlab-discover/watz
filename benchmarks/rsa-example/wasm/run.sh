#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

wasm_heap_size=$((1 * 1024 * 1024))

announcerun "rsa example"
sshpass -p "$BM_BOARD_PASS" ssh -p 2222 $BM_BOARD_USER@$BM_BOARD_HOSTNAME "watz $wasm_heap_size rsa_example.aot 2>&1"
