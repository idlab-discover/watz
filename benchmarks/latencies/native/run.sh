#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

mkdir -p $LOGS_DIR/latencies

announcerun "latencies-native (roundtrip)"
sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'bm_latencies_native roundtrip 1000 2>&1' | tee $LOGS_DIR/latencies/native-roundtrip.csv

announcerun "latencies-native (catime)"
sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'bm_latencies_native catime 1000 2>&1' | tee $LOGS_DIR/latencies/native-catime.csv

announcerun "latencies-native (tatime)"
sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'bm_latencies_native tatime 1000 2>&1' | tee $LOGS_DIR/latencies/native-tatime.csv

announcerun "latencies-native (pinned)"
sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'taskset -c 8-11 bm_latencies_native roundtrip 1000 2>&1' | tee $LOGS_DIR/latencies/native-roundtrip-pinned.csv

sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'taskset -c 8-11 bm_latencies_native catime 1000 2>&1' | tee $LOGS_DIR/latencies/native-catime-pinned.csv

sshpass -p "$BM_BOARD_PASS" ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'taskset -c 8-11 bm_latencies_native tatime 1000 2>&1' | tee $LOGS_DIR/latencies/native-tatime-pinned.csv
