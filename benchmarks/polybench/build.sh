#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

# ./build-native.sh
./build-runtime.sh
# ./build-wasm.sh

# PLATFORM=$(uname -s | tr A-Z a-z)

OUT_DIR=$SCRIPT_DIR/out
WAMRC_CMD=$WATZ_RUNTIME_DIR/wamr-compiler/build/wamrc
# POLYBENCH_CASES="datamining linear-algebra medley stencils"
# POLYBENCH_CASES="medley"

# announcebuild "polybench (WASM)"

if [ ! -d polybench-srcs ]; then
  git clone https://github.com/MatthiasJReisinger/PolyBenchC-4.2.1.git polybench-srcs
fi

mkdir -p $OUT_DIR

cd polybench-srcs/

rm -r build
mkdir build
cd build

announcebuild "polybench-native"
cmake .. -G Ninja \
  -DCMAKE_C_COMPILER="${CROSS_COMPILE}gcc" \
  -DCMAKE_C_FLAGS="-lm" 
ninja
cp polybench $OUT_DIR/polybench

cd ..
rm -r build
mkdir build
cd build

announcebuild "polybench-wasm"
cmake .. -G Ninja \
  -DCMAKE_C_COMPILER="/opt/wasi-sdk/bin/clang" \
  -DCMAKE_C_FLAGS="--target=wasm32-wasi --sysroot=/opt/wasi-sdk/share/wasi-sysroot/ -Wl,--strip-all -D_WASI_EMULATED_PROCESS_CLOCKS -Wl,--allow-undefined-file=/opt/wasi-sdk/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt"
ninja
cp polybench $OUT_DIR/polybench_all.wasm

announcebuild "polybench-aot"
compileaot $OUT_DIR/polybench_all

# for case in $POLYBENCH_CASES; do
#   files=$(find ${case} -name "*.c")
#   for file in ${files}; do
#     file_name=${file##*/}
#     if [[ ${file_name} == "Nussinov.orig.c" ]]; then
#       continue
#     fi
#
#     announce "Build ${file_name%.*}_native"
#     # gcc -O3 -I utilities -I ${file%/*} utilities/polybench.c ${file} \
#     #   -DPOLYBENCH_TIME -lm -o ${OUT_DIR}/${file_name%.*}_native
#     /home/zelzahn/jetson/jetson-toolchain/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-gcc -O3 -I utilities -I ${file%/*} utilities/polybench.c ${file} \
#       -DMEDIUM_DATASET -DPOLYBENCH_CLOCK_TIMER -lm -o ${OUT_DIR}/native/${file_name%.*}_native
#
#       # -Wl,--export=__heap_base -Wl,--export=__data_end \
#       # -Wl,--export=malloc -Wl,--export=free \
#     announce "Build ${file_name%.*}.wasm"
#     /opt/wasi-sdk/bin/clang $BM_CFLAGS -I utilities -I ${file%/*} \
#       utilities/polybench.c ${file} \
#       --target=wasm32-wasi \
#       --sysroot=/opt/wasi-sdk/share/wasi-sysroot/ \
#       -Wl,--strip-all \
#       -DMEDIUM_DATASET \
#       -DPOLYBENCH_TIME  -DPOLYBENCH_CLOCK_TIMER -D_WASI_EMULATED_PROCESS_CLOCKS \
#       -Wl,--allow-undefined-file=/opt/wasi-sdk/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt \
#       -o ${OUT_DIR}/wasm/${file_name%.*}.wasm
#
#     announce "Compile ${file_name%.*}.wasm into ${file_name%.*}.aot"
#     # ${WAMRC_CMD} -o ${OUT_DIR}/${file_name%.*}.aot \
#     #   ${OUT_DIR}/${file_name%.*}.wasm
#     compileaot $OUT_DIR/wasm/${file_name%.*}
#   done
# done

cd ..
