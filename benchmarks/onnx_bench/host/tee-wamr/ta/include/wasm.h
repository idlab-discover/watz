#ifndef WASM_H
#define WASM_H

#include <tee_internal_api.h>

#include "wasm_export.h"

typedef struct wamr_context_
{
    uint8_t *wasm_bytecode;
    size_t wasm_bytecode_size;
    uint8_t *model_name;
    size_t model_name_length;
    uint8_t *model;
    size_t model_length;
    uint8_t *input;
    size_t input_length;
    void *heap_buf;
    size_t heap_size;
    uint32_t initial_linear_memory_size;
    wasm_module_t module;
    wasm_module_inst_t module_inst;
    wasm_exec_env_t exec_env;
} wamr_context;

extern wamr_context *singleton_wamr_context;

void TA_SetOutputBuffer(void *output_buffer, uint64_t output_buffer_size);
TEE_Result TA_HashWasmBytecode(wamr_context *ctx);
TEE_Result TA_InitializeWamrRuntime(wamr_context* context, int argc, char** argv);
TEE_Result TA_ExecuteWamrRuntime(wamr_context* context);
void TA_TearDownWamrRuntime(wamr_context* context);

#endif /* WASM_H */
