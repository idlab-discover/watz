#!/bin/bash

# USER SETTINGS
BM_BOARD_HOSTNAME="localhost"
BM_BOARD_USER="root"
BM_BOARD_PASS="root"
BM_SSH_PORT=2222

# exit when any command fails
set -e

# Common settings
TA_LOG_LEVEL=2

# define common paths
BM_CFLAGS="-O3"
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# OPTEE_DIR=/opt/watz
# OPTEE_OS_DIR=$OPTEE_DIR/optee_os
# OPTEE_TOOLCHAINS_DIR=$OPTEE_DIR/toolchains
# OPTEE_BR_OUT_DIR=$OPTEE_DIR/out-br
WATZ_RUNTIME_DIR=$ROOT_DIR/../runtime
OPTEE_DIR=$ROOT_DIR/../../
BM_BUILDER_PATH="$ROOT_DIR"
# WATZ_RUNTIME_DIR=~/Downloads/unine-watz/runtime/
DIST_DIR=$ROOT_DIR/dist
LOGS_DIR=$ROOT_DIR/logs
TARGET="QEMU"
# define variables

if [ "$TARGET" == "JETSON" ]; then
  CROSS_COMPILE=~/jetson/jetson-toolchain/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
  TEEC_EXPORT=~/jetson/jetson-public-srcs/Linux_for_Tegra/source/jetson-optee-srcs/optee/install/t234/usr
  TA_DEV_KIT_DIR=/home/zelzahn/jetson/jetson-public-srcs/Linux_for_Tegra/source/jetson-optee-srcs/optee/build/t234/export-ta_arm64
elif [ "$TARGET" == "QEMU" ]; then
  CROSS_COMPILE=$OPTEE_DIR/toolchains/aarch64/bin/aarch64-linux-gnu-
  TEEC_EXPORT=$OPTEE_DIR/out-br/host/aarch64-buildroot-linux-gnu/sysroot/usr
  TA_DEV_KIT_DIR=$OPTEE_DIR/optee_os/out/arm/export-ta_arm64
fi

# Macros
announce() {
  echo "$(tput smso 2>/dev/null)>>> $1$(tput rmso 2>/dev/null)"
}

announcebuild() {
  announce "Building WaTZ benchmark: $1"
}

announcedeploy() {
  announce "Deploying WaTZ benchmark: $1"
}

announcerun() {
  announce "Running WaTZ benchmark: $1"
}

safesleep() {
  sleep 2
}

# Define the functions to build and deploy WaTZ (for TEE)
# Prototype: buildwatz <attester_data_size> <verifier_data_size> [make param1]
buildwatz() {
  announcebuild "vmlib"
  mkdir -p $WATZ_RUNTIME_DIR/product-mini/platforms/linux-trustzone/build
  cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux-trustzone/build
  cmake .. -DCROSS_COMPILE=$CROSS_COMPILE
  make

  announcebuild "WaTZ"
  cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux-trustzone/watz
  make clean
  make CROSS_COMPILE=$CROSS_COMPILE \
    TEEC_EXPORT=$TEEC_EXPORT \
    TA_DEV_KIT_DIR=$TA_DEV_KIT_DIR TA_DATA_SIZE=$1 CFG_TEE_TA_LOG_LEVEL=$TA_LOG_LEVEL $3
}

deploywatz() {
  cd $ROOT_DIR/build
  announcedeploy "WaTZ"
  mkdir -p $ROOT_DIR/build
  mkdir -p out/
  OUT_PATH=$BM_BUILDER_PATH/../runtime/product-mini/platforms/linux-trustzone/watz/out
  if [ "$TARGET" == "JETSON" ]; then
    sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH/ca/watz $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin
    sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH/ta/bc20728a-6a28-49d8-98d8-f22e7535f137.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
    sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/bc20728a-6a28-49d8-98d8-f22e7535f137.ta'
  elif [ "$TARGET" == "QEMU" ]; then
    sshpass -p $BM_BOARD_PASS scp -P $BM_SSH_PORT $OUT_PATH/ca/watz $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin
    sshpass -p $BM_BOARD_PASS scp -P $BM_SSH_PORT $OUT_PATH/ta/bc20728a-6a28-49d8-98d8-f22e7535f137.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
    sshpass -p "$BM_BOARD_PASS" /usr/bin/ssh -p $BM_SSH_PORT $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/bc20728a-6a28-49d8-98d8-f22e7535f137.ta'
  fi
}

# Define the functions to build and deploy WAMR (for REE)
buildwamr() {
  announcebuild "WAMR runtime"
  mkdir -p $WATZ_RUNTIME_DIR/product-mini/platforms/linux/build
  cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux/build
  # NOTE(Friedrich) For `runtime-old`
  # cp ../CMakeLists-aarch64.txt ../CMakeLists.txt
  cmake .. -G Ninja
  ninja clean
  ninja
  # rm ../CMakeLists.txt
}

deploywamr() {
  announcedeploy "WAMR runtime"
  mkdir -p $WATZ_RUNTIME_DIR/product-mini/platforms/linux/build
  cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux/build
  OUT_PATH=$BM_BUILDER_PATH/../runtime/product-mini/platforms/linux/build/iwasm-2.4.1
  # NOTE(Friedrich) For `wasi-sdk/12`
  # OUT_PATH=$BM_BUILDER_PATH/../runtime/product-mini/platforms/linux/build/iwasm
  if [ "$TARGET" == "JETSON" ]; then
    sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin/iwasm
  elif [ "$TARGET" == "QEMU" ]; then
    sshpass -p $BM_BOARD_PASS scp -P $BM_SSH_PORT $OUT_PATH $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin/iwasm
  fi
}

buildaotcompiler() {
  cd $WATZ_RUNTIME_DIR/wamr-compiler

  if [ ! -d "../core/deps/llvm" ]; then
    announce "Building LLVM"
    ./build_llvm.sh
  fi

  announce "Building AoT compiler"
  mkdir -p build
  cd build
  cmake .. -G Ninja
  ninja
}

compileaot() {
  # Configure the bounds checks similarly to SGX.
  # Use the large size; small and tiny cannot be properly compiled.
  $WATZ_RUNTIME_DIR/wamr-compiler/build/wamrc \
    --target=aarch64 \
    --bounds-checks=0 \
    --size-level=0 \
    -o $1.aot \
    $1.wasm
}

# Set up the common environment
mkdir -p $LOGS_DIR
