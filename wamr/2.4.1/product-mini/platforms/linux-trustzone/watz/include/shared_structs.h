#ifndef SHARED_STRUCTS_H
#define SHARED_STRUCTS_H

typedef struct wasm_binary_ {
    unsigned char *bytecode;
    long file_length;
    struct wasm_binary_ *next;
} wasm_binary;
#endif
