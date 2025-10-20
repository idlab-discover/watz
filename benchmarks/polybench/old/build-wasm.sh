#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/../common.sh

PLATFORM=$(uname -s | tr A-Z a-z)

OUT_DIR=$SCRIPT_DIR/out
WAMRC_CMD=$PWD/../../../wamr-compiler/build/wamrc
POLYBENCH_CASES="datamining linear-algebra medley stencils"

announcebuild "polybench (WASM)"

if [ ! -d PolyBenchC-4.2.1 ]; then
  git clone https://github.com/MatthiasJReisinger/PolyBenchC-4.2.1.git polybench-srcs
fi

mkdir -p $OUT_DIR

cd polybench-srcs

for case in $POLYBENCH_CASES; do
  files=$(find ${case} -name "*.c")
  for file in ${files}; do
    file_name=${file##*/}
    if [[ ${file_name} == "Nussinov.orig.c" ]]; then
      continue
    fi

    announce "Build ${file_name%.*}_native"
    gcc -O3 -I utilities -I ${file%/*} utilities/polybench.c ${file} \
      -DPOLYBENCH_TIME -lm -o ${OUT_DIR}/${file_name%.*}_native

    announce "Build ${file_name%.*}.wasm"
    /opt/wasi-sdk/bin/clang $BM_CFLAGS -I utilities -I ${file%/*} \
      utilities/polybench.c ${file} \
      -Wl,--export=__heap_base -Wl,--export=__data_end \
      -Wl,--export=malloc -Wl,--export=free \
      -DPOLYBENCH_TIME -D_WASI_EMULATED_PROCESS_CLOCKS \
      -o ${OUT_DIR}/${file_name%.*}.wasm

    # announce "Compile ${file_name%.*}.wasm into ${file_name%.*}.aot"
    # ${WAMRC_CMD} -o ${OUT_DIR}/${file_name%.*}.aot \
    #   ${OUT_DIR}/${file_name%.*}.wasm
    compileaot $OUT_DIR/${file_name.*}

    if [[ ${PLATFORM} == "linux" ]]; then
      announce "Compile ${file_name%.*}.wasm into ${file_name%.*}_segue.aot"
      ${WAMRC_CMD} --enable-segue -o ${OUT_DIR}/${file_name%.*}_segue.aot \
        ${OUT_DIR}/${file_name%.*}.wasm
    fi
  done
done

cd ..
