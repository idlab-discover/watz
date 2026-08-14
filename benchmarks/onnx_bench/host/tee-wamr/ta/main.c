#include <tee_internal_api.h>
#include <tee_internal_api_extensions.h>
#include <string.h>

#include "wasm_export.h"

#include <wamr_ta.h>
#include <wasm.h>

static uint32_t heap_size;
static uint32_t initial_linear_memory_size;

TEE_Result
TA_CreateEntryPoint(void)
{
    DMSG("has been called");
    return TEE_SUCCESS;
}

void
TA_DestroyEntryPoint(void)
{
    DMSG("has been called");
}

TEE_Result
TA_OpenSessionEntryPoint(uint32_t param_types,
                         TEE_Param __maybe_unused params[4],
                         void __maybe_unused **sess_ctx)
{
    uint32_t exp_param_types =
        TEE_PARAM_TYPES(TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE,
                        TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE);
    DMSG("has been called");

    if (param_types != exp_param_types)
        return TEE_ERROR_BAD_PARAMETERS;

    (void)&params;
    (void)&sess_ctx;

    return TEE_SUCCESS;
}

void
TA_CloseSessionEntryPoint(void __maybe_unused *sess_ctx)
{
    (void)&sess_ctx;
    DMSG("Goodbye!");
}

static TEE_Result
TA_SetHeapSize(uint32_t size)
{
    heap_size = size;
    DMSG("The heap set is set to %u", heap_size);

    return TEE_SUCCESS;
}

static TEE_Result
TA_SetLinearMemory(uint32_t size)
{
    initial_linear_memory_size = size;
    DMSG("The initial Wasm linear memory is set to %u", initial_linear_memory_size);

    return TEE_SUCCESS;
}

static TEE_Result
TA_RunWasm(
    uint8_t *wasm_bytecode,
    uint32_t wasm_bytecode_size,
    uint8_t *model_name,
    uint32_t model_name_length,
    uint8_t *model_bytecode,
    uint32_t model_length,
    uint8_t *input,
    uint32_t input_length
) {
    DMSG("has been called");

    // Allocate secure memory locations
    uint8_t *global_heap_buf =
        TEE_Malloc(heap_size, TEE_USER_MEM_HINT_NO_FILL_ZERO);
    if (global_heap_buf == NULL) {
        EMSG("global_heap_buf malloc failed");
        return TEE_ERROR_GENERIC;
    }
    uint8_t *trusted_wasm_bytecode =
        TEE_Malloc(wasm_bytecode_size, TEE_USER_MEM_HINT_NO_FILL_ZERO);
    if (trusted_wasm_bytecode == NULL) {
        EMSG("trusted_wasm_bytecode  malloc failed");
        return TEE_ERROR_GENERIC;
    }
    // uint8_t *trusted_model_name =
    //     TEE_Malloc(model_name_length, TEE_USER_MEM_HINT_NO_FILL_ZERO);
    // uint8_t *trusted_model =
    //     TEE_Malloc(model_length, TEE_USER_MEM_HINT_NO_FILL_ZERO);
    // uint8_t *trusted_input =
    //     TEE_Malloc(input_length, TEE_USER_MEM_HINT_NO_FILL_ZERO);

#ifdef FRIEDRICH_DEBUG
    EMSG("TA_RunWasm Heap size: %d (%p)", heap_size, global_heap_buf);
    // EMSG("TA_RunWasm Wasm bytecode size: %d (%p)", wasm_bytecode_size, trusted_wasm_bytecode);
#endif

    // Copy the shared memory that contains the WASM bytecode into the secure
    // memory
    TEE_MemMove(trusted_wasm_bytecode, wasm_bytecode, wasm_bytecode_size);
    // TEE_MemMove(trusted_model_name, model_name, model_name_length);
    // TEE_MemMove(trusted_model, model_bytecode, model_length);
    // TEE_MemMove(trusted_input, input, input_length);

    // General settings for the runtime
    TEE_Result result;
    wamr_context context = { .heap_buf = global_heap_buf,
                             .heap_size = heap_size,
                             .initial_linear_memory_size = initial_linear_memory_size,
                             .wasm_bytecode = trusted_wasm_bytecode,
                             // .wasm_bytecode = wasm_bytecode,
                             .wasm_bytecode_size = wasm_bytecode_size,
                             .model_name = model_name,
                             .model_name_length = model_name_length,
                             .model = model_bytecode,
                             .model_length = model_length,
                             .input = input,
                             .input_length = input_length,
    };

    DMSG("TA_InitializeWamrRuntime\n");
    int argc = 1;
    char *argv[] = { (char *)"" };
    result = TA_InitializeWamrRuntime(&context, argc, argv);
    if (result != TEE_SUCCESS)
        goto error;

    DMSG("TA_ExecuteWamrRuntime\n");
    result = TA_ExecuteWamrRuntime(&context);
    if (result != TEE_SUCCESS)
        goto error;

error:
    DMSG("TA_TearDownWamrRuntime\n");
    TA_TearDownWamrRuntime(&context);

    // Free up the allocated resources
    TEE_Free(global_heap_buf);
    TEE_Free(trusted_wasm_bytecode);
    // TEE_Free(trusted_model_name);
    // TEE_Free(trusted_model);
    // TEE_Free(trusted_input);

    return result;
}

TEE_Result
TA_InvokeCommandEntryPoint(void __maybe_unused *sess_ctx, uint32_t cmd_id,
                           uint32_t param_types, TEE_Param params[4])
{
    (void)&sess_ctx;
    uint32_t exp_param_types = 0;

    switch (cmd_id) {
        case COMMAND_RUN_WASM:
            exp_param_types = TEE_PARAM_TYPES(
                TEE_PARAM_TYPE_MEMREF_INPUT, TEE_PARAM_TYPE_MEMREF_INPUT,
                TEE_PARAM_TYPE_MEMREF_INPUT, TEE_PARAM_TYPE_MEMREF_INPUT);
            if (exp_param_types != param_types)
                return TEE_ERROR_BAD_PARAMETERS;

            return TA_RunWasm((unsigned char *)params[0].memref.buffer, params[0].memref.size,
                              (unsigned char *)params[1].memref.buffer, params[1].memref.size,
                              (unsigned char *)params[2].memref.buffer, params[2].memref.size,
                              (unsigned char *)params[3].memref.buffer, params[3].memref.size);

        case COMMAND_CONFIGURE_HEAP:
            exp_param_types =
                TEE_PARAM_TYPES(TEE_PARAM_TYPE_VALUE_INPUT, TEE_PARAM_TYPE_NONE,
                                TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE);
            if (exp_param_types != param_types)
                return TEE_ERROR_BAD_PARAMETERS;

            return TA_SetHeapSize(params[0].value.a);
        case COMMAND_CONFIGURE_LINEAR_MEMORY:
            exp_param_types =
                TEE_PARAM_TYPES(TEE_PARAM_TYPE_VALUE_INPUT, TEE_PARAM_TYPE_NONE,
                                TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE);
            if (exp_param_types != param_types)
                return TEE_ERROR_BAD_PARAMETERS;

            return TA_SetLinearMemory(params[0].value.a);
        case COMMAND_CONFIGURE_OUT:
            exp_param_types =
                TEE_PARAM_TYPES(TEE_PARAM_TYPE_MEMREF_INOUT, TEE_PARAM_TYPE_NONE,
                         TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE);
            if (exp_param_types != param_types)
                return TEE_ERROR_BAD_PARAMETERS;

            TA_SetOutputBuffer(params[0].memref.buffer, params[0].memref.size);
            return TEE_SUCCESS;
        default:
            return TEE_ERROR_BAD_PARAMETERS;
    }
}
