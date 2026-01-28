#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

announcebuild "launch-time"
mkdir -p $SCRIPT_DIR/out
cd $SCRIPT_DIR/out

# Prototype: build <size_in_MB>
build() {
  /opt/wasi-sdk/bin/clang -O3 \
    --target=wasm32-wasi \
    --sysroot=/opt/wasi-sdk/share/wasi-sysroot/ \
    -Wl,--strip-all \
    -Wl,--allow-undefined-file=/opt/wasi-sdk/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt \
    -I $SCRIPT_DIR/app \
    -o bm_launch-time_$1.wasm $SCRIPT_DIR/app/bm_launch-time_$1.c

  compileaot $SCRIPT_DIR/out/bm_launch-time_$1
}

# build 1
for MB in {1..8}; do # for MB in {1..2}
  build $MB #&
done

# echo "Waiting on the end of compilation..."
# wait
