#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

# buildwamr
buildaotcompiler

buildwatz $((35 * 1024 * 1024)) PROFILING=LAUNCH_TIME
# if [ "$WAMR_VERSION" == "old" ]; then
#   buildwatz $((23 * 1024 * 1024)) PROFILING=LAUNCH_TIME
# elif [ "$WAMR_VERSION" == "new" ]; then
# fi
