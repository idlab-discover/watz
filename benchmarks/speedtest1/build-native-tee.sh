#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../common.sh

announcebuild "SQLite (Native TEE)"
mkdir -p $SCRIPT_DIR/out

cd $SCRIPT_DIR/native_tee
# make clean
# Voor QEMU
# OPTEE_DIR=$ROOT_DIR/../../
# CROSS_COMPILE=$OPTEE_DIR/toolchains/aarch64/bin/aarch64-linux-gnu-
# TEEC_EXPORT=$OPTEE_DIR/out-br/host/aarch64-buildroot-linux-gnu/sysroot/usr
# TA_DEV_KIT_DIR=$OPTEE_DIR/optee_os/out/arm/export-ta_arm64

make CROSS_COMPILE=/home/zelzahn/jetson/jetson-toolchain/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu- \
    TEEC_EXPORT=/home/zelzahn/jetson/jetson-public-srcs/Linux_for_Tegra/source/jetson-optee-srcs/optee/install/t234/usr \
    TA_DEV_KIT_DIR=/home/zelzahn/jetson/jetson-public-srcs/Linux_for_Tegra/source/jetson-optee-srcs/optee/build/t234/export-ta_arm64

cp -r out/* ../out/
