#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

deploywatz
deploywamr

announcedeploy "Genann"
cd $SCRIPT_DIR
sshpass -p "$BM_BOARD_PASS" rsync --progress -r out/ $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/root/genann
