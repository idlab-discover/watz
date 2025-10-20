#!/bin/bash

# USER SETTINGS
# BM_BOARD_HOSTNAME="10.10.129.204"
BM_BOARD_HOSTNAME="192.168.0.116"
BM_BOARD_USER="root"
BM_BOARD_PASS="orin"
BM_BUILDER_PATH="/opt/watz/benchmarks"

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
# WATZ_RUNTIME_DIR=~/Downloads/unine-watz/runtime/
DIST_DIR=$ROOT_DIR/dist
LOGS_DIR=$ROOT_DIR/logs

# define variables
CROSS_COMPILE=/home/zelzahn/jetson/jetson-toolchain/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
TEEC_EXPORT=/home/zelzahn/jetson/jetson-public-srcs/Linux_for_Tegra/source/jetson-optee-srcs/optee/install/t234/usr
TA_DEV_KIT_DIR=/home/zelzahn/jetson/jetson-public-srcs/Linux_for_Tegra/source/jetson-optee-srcs/optee/build/t234/export-ta_arm64

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
  announcebuild "WaTZ runtime"
  mkdir -p $WATZ_RUNTIME_DIR/product-mini/platforms/linux-trustzone/build
  cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux-trustzone/build
  cmake .. # -DCMAKE_CXX_COMPILER=/usr/bin/g++-8 -DCMAKE_C_COMPILER=/usr/bin/gcc-8
  make

  announcebuild "WaTZ attester"
  cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux-trustzone/vedliot_attester
  make clean
  make CROSS_COMPILE=$CROSS_COMPILE \
    TEEC_EXPORT=$TEEC_EXPORT \
    TA_DEV_KIT_DIR=$TA_DEV_KIT_DIR TA_DATA_SIZE=$1 CFG_TEE_TA_LOG_LEVEL=$TA_LOG_LEVEL $3

  # announcebuild "WaTZ verifier"
  # cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux-trustzone/vedliot_verifier
  # make clean
  # make CROSS_COMPILE=$CROSS_COMPILE \
  #   TEEC_EXPORT=$TEEC_EXPORT \
  #   TA_DEV_KIT_DIR=$TA_DEV_KIT_DIR TA_DATA_SIZE=$2 CFG_TEE_TA_LOG_LEVEL=$TA_LOG_LEVEL $3
}

deploywatz() {
  cd $ROOT_DIR/build
  announcedeploy "WaTZ attester"
  mkdir -p $ROOT_DIR/build
  mkdir -p out/
  OUT_PATH=$BM_BUILDER_PATH/../runtime/product-mini/platforms/linux-trustzone/vedliot_attester/out
  sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH/ca/vedliot_attester $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin
  sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH/ta/bc20728a-6a28-49d8-98d8-f22e7535f137.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/bc20728a-6a28-49d8-98d8-f22e7535f137.ta'

  # announcedeploy "WaTZ verifier"
  # cd $ROOT_DIR/build
  # OUT_PATH=$BM_BUILDER_PATH/../runtime/product-mini/platforms/linux-trustzone/vedliot_verifier/out
  # sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH/ca/vedliot_verifier $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin
  # sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH/ta/526461e2-d34a-4d96-8ca3-7fb9f4b898ef.ta $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/lib/optee_armtz
  # sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME 'chmod 666 /lib/optee_armtz/526461e2-d34a-4d96-8ca3-7fb9f4b898ef.ta'
}

# Define the functions to build and deploy WAMR (for REE)
buildwamr() {
  announcebuild "WAMR runtime"
  mkdir -p $WATZ_RUNTIME_DIR/product-mini/platforms/linux/build
  cd $WATZ_RUNTIME_DIR/product-mini/platforms/linux/build
  # NOTE(Friedrich) Nodig voor `runtime-old`
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
  # NOTE(Friedrich) Voor `wasi-sdk/12`
  # OUT_PATH=$BM_BUILDER_PATH/../runtime/product-mini/platforms/linux/build/iwasm
  sshpass -p "$BM_BOARD_PASS" rsync --progress $OUT_PATH $BM_BOARD_USER@$BM_BOARD_HOSTNAME:/usr/sbin/iwasm
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

restart_tee_supplicant() {
  # sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "killall tee-supplicant"
  # safesleep
  # sspass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "/etc/init.d/S30optee start"
  sshpass -p "$BM_BOARD_PASS" ssh $BM_BOARD_USER@$BM_BOARD_HOSTNAME "systemctl restart nv-tee-supplicant"
  safesleep
}

# Set up the common environment
mkdir -p $LOGS_DIR
