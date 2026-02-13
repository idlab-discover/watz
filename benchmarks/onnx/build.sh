#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

OUT_DIR=$SCRIPT_DIR/out
WAMRC_CMD=$WATZ_RUNTIME_DIR/wamr-compiler/build/wamrc

if [ ! -d $DIST_DIR/onnx2c-srcs ]; then
  git clone https://github.com/kraiskil/onnx2c.git $DIST_DIR/onnx2c-srcs

  cd onnx2c-srcs/
  mkdir -p build
  cd build
  
  cmake .. -G Ninja
  ninja
  cp onnx2c $SCRIPT_DIR/native
  cd $SCRIPT_DIR
fi

mkdir -p $OUT_DIR

announcebuild "onnx-native"
cd $SCRIPT_DIR/native/
mkdir -p build
cd build

cmake .. -G Ninja \
  -DCMAKE_C_COMPILER="${CROSS_COMPILE}gcc" \
  -DBUILD_LIB=OFF
ninja
cp onnx $OUT_DIR/onnx_native

announcebuild "onnx-tee"

cmake .. -G Ninja \
  -DCMAKE_C_COMPILER="${CROSS_COMPILE}gcc" \
  -DBUILD_LIB=ON
ninja
cp libonnx.a $SCRIPT_DIR/tee/ta/lib

cd $SCRIPT_DIR/tee/

make CROSS_COMPILE=$CROSS_COMPILE \
    TEEC_EXPORT=$TEEC_EXPORT \
    TA_DEV_KIT_DIR=$TA_DEV_KIT_DIR

announcebuild "onnx-wasm"

cd $SCRIPT_DIR/native/
mkdir -p build
cd build

cmake .. -G Ninja \
  -DCMAKE_C_COMPILER="/opt/wasi-sdk/bin/clang" \
  -DCMAKE_C_FLAGS="--target=wasm32-wasi --sysroot=/opt/wasi-sdk/share/wasi-sysroot/ -Wl,--strip-all -D_WASI_EMULATED_PROCESS_CLOCKS -Wl,--allow-undefined-file=/opt/wasi-sdk/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt"
ninja
cp onnx $OUT_DIR/onnx.wasm

announcebuild "onnx-aot"

buildaotcompiler
buildwatz $((5 * 1024 * 1024))
buildwamr

compileaot $OUT_DIR/onnx

