#!/bin/env bash

WATZ_RUNTIME_DIR=/home/zelzahn/Onderzoek/optee/watz/wamr/2.4.1

$WATZ_RUNTIME_DIR/wamr-compiler/build/wamrc \
    --target=aarch64 \
    --bounds-checks=0 \
    --size-level=0 \
    -o $1.aot \
    $1.wasm
