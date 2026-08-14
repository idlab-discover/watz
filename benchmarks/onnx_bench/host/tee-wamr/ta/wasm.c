#include <stdio.h>
#include "wasm.h"

wamr_context *singleton_wamr_context;

#ifdef DEBUG_MESSAGE
#define UINT8_DIGIT_MAX_SIZE 2
static void
utils_print_byte_array(uint8_t *byte_array, int byte_array_len)
{
    // +byte_array_len for spaces
    int buffer_len = UINT8_DIGIT_MAX_SIZE * byte_array_len + byte_array_len;
    char *buffer = TEE_Malloc(buffer_len, TEE_USER_MEM_HINT_NO_FILL_ZERO);

    int i, buffer_cursor = 0;
    for (i = 0; i < byte_array_len; ++i) {
        buffer_cursor +=
            snprintf(buffer + buffer_cursor, buffer_len - buffer_cursor,
                     "%02x ", byte_array[i]);
    }

    // Replace trhe last space by the string termination char
    buffer[buffer_cursor] = '\0';

    DMSG("[%s]", buffer);

    TEE_Free(buffer);
}
#endif

void
TA_SetOutputBuffer(void *output_buffer, uint64_t output_buffer_size)
{
    watz_set_output_buffer(output_buffer, output_buffer_size);
}

TEE_Result
TA_InitializeWamrRuntime(wamr_context *context, int argc, char **argv)
{
    char error_buf[128];
    uint32_t stack_size = 10 * 1024;
    uint32_t heap_size = context->initial_linear_memory_size;

    RuntimeInitArgs init_args;
    TEE_MemFill(&init_args, 0, sizeof(RuntimeInitArgs));

    /* configure the memory allocator for the runtime */
    init_args.mem_alloc_type = Alloc_With_Pool;
    init_args.mem_alloc_option.pool.heap_buf = context->heap_buf;
    init_args.mem_alloc_option.pool.heap_size = context->heap_size;

    /* configure the native functions being exported to WASM app */
    init_args.native_module_name = "env";
    init_args.n_native_symbols = 0;
    init_args.native_symbols = NULL;

    if (!wasm_runtime_full_init(&init_args)) {
        EMSG("Init runtime environment failed.\n");
        return TEE_ERROR_GENERIC;
    }
#ifdef FRIEDRICH_DEBUG
    wasm_runtime_set_log_level(WASM_LOG_LEVEL_VERBOSE);
#endif

    /* load WASM module */
    if (!(context->module = wasm_runtime_load(context->wasm_bytecode,
                                              context->wasm_bytecode_size,
                                              error_buf, sizeof(error_buf)))) {
        EMSG("Load wasm module failed. error: %s\n", error_buf);
        return TEE_ERROR_GENERIC;
    }

    /* instantiate the module */
#ifdef FRIEDRICH_DEBUG
    EMSG("INSTANTIATED STARTED");
#endif
    if (!(context->module_inst =
              wasm_runtime_instantiate(context->module, stack_size, heap_size,
                                       error_buf, sizeof(error_buf)))) {
        EMSG("Instantiate wasm module failed. error: %s\n", error_buf);
        return TEE_ERROR_GENERIC;
    }
#ifdef FRIEDRICH_DEBUG
    EMSG("INSTANTIATED ENDED");
#endif
  
    wasm_exec_env_t exec_env = wasm_runtime_create_exec_env(context->module_inst, stack_size);
    if (!exec_env) {
        printf("Create wasm execution environment failed.\n");
        return TEE_ERROR_GENERIC;
    }

    singleton_wamr_context = context;

    return TEE_SUCCESS;
}

TEE_Result
TA_ExecuteWamrRuntime(wamr_context *context)
{
    if (!wasm_application_execute_main(context->module_inst, 0, NULL)) {
        EMSG("call wasm entry point test failed. %s\n",
             wasm_runtime_get_exception(context->module_inst));
        return TEE_ERROR_GENERIC;
    }

    // wasm_function_inst_t func = NULL;
    // if (!(func = wasm_runtime_lookup_function(context->module_inst, "execute"))) {
    //   printf("could not find execute function\n");
    //   return TEE_ERROR_GENERIC;
    // }
    //
    // void* native_address_1 = NULL;
    // uint64_t wasm_input =
    //       wasm_runtime_module_malloc(context->module_inst, context->input_length, &native_address_1);
    // if(native_address_1 == NULL) {
    //   printf("wasm_runtime_module_malloc grace failed. %s\n",
    //        wasm_runtime_get_exception(context->module_inst));
    //   return TEE_ERROR_GENERIC;
    // }
    // TEE_MemMove(native_address_1, context->input, context->input_length);
    //
    // void* native_address_2 = NULL;
    // uint64_t wasm_model =
    //       wasm_runtime_module_malloc(context->module_inst, context->model_length, &native_address_2);
    // if(native_address_2 == NULL) {
    //   printf("wasm_runtime_module_malloc model failed. %s\n",
    //        wasm_runtime_get_exception(context->module_inst));
    //   return TEE_ERROR_GENERIC;
    // }
    // TEE_MemMove(native_address_2, context->model, context->model_length);
    //
    // void* native_address_3 = NULL;
    // uint64_t wasm_model_name =
    //       wasm_runtime_module_malloc(context->module_inst, context->model_name_length, &native_address_3);
    // if(native_address_3 == NULL) {
    //   printf("wasm_runtime_module_malloc model_name failed. %s\n",
    //        wasm_runtime_get_exception(context->module_inst));
    //   return TEE_ERROR_GENERIC;
    // }
    // TEE_MemMove(native_address_3, context->model_name, context->model_name_length);
    //
    // uint32_t wasm_argv[6] = { 
    //   wasm_input,
    //   context->input_length,
    //   wasm_model_name,
    //   context->model_name_length,
    //   wasm_model,
    //   context->model_length,
    // };
    //
    // if (!wasm_runtime_call_wasm(context->exec_env, func, 6, wasm_argv)) {
    //   printf("call wasm entry point failed. %s\n",
    //        wasm_runtime_get_exception(context->module_inst));
    //   return TEE_ERROR_GENERIC;
    // }
    //
    // wasm_runtime_module_free(context->module_inst, wasm_model);
    // wasm_runtime_module_free(context->module_inst, wasm_model_name);
    // wasm_runtime_module_free(context->module_inst, wasm_input);

    return TEE_SUCCESS;
}

void
TA_TearDownWamrRuntime(wamr_context *context)
{
    singleton_wamr_context = NULL;

    if (context->module_inst) {
        wasm_runtime_deinstantiate(context->module_inst);
    }

    if (context->module)
        wasm_runtime_unload(context->module);
    wasm_runtime_destroy();
}
