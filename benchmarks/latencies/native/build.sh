#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../../common.sh

announcebuild "latencies-native"

cd $SCRIPT_DIR
make CROSS_COMPILE=$CROSS_COMPILE \
  TEEC_EXPORT=$TEEC_EXPORT \
  TA_DEV_KIT_DIR=$TA_DEV_KIT_DIR
