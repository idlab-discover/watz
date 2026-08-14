#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "wasm_export.h"

int read_file_to_buffer(uint8_t** buffer, uint32_t* buffer_size, const char* path) {
  FILE* file = fopen(path, "rb");
  if (file == NULL) {
      printf("ERROR: the file %s cannot be opened.\n", path);
      return -1;
  }
  // Jump to the end of the file
  fseek(file, 0, SEEK_END);
  // Get the current byte offset in the file
  long file_length = ftell(file);
  // Allocate the buffer for the bytecode with the size of the file
  uint8_t* bytecode = malloc(ftell(file) * sizeof(unsigned char));
  if (bytecode == NULL) {
    printf("wasm_bytecode  malloc failed\n");
    return -1;
  }
  // Jump back to the beginning of the file
  rewind(file);
  // Dump the bytecode into the buffer
  fread(bytecode, file_length, 1,file);
  // Close the file
  fclose(file);

  *buffer_size = (uint32_t) file_length;
  *buffer = bytecode;

  return 0;
}

int run_model(
  const char* model_name,
  const char* model_path,
  const uint64_t wasm_grace,
  const uint32_t grace_hopper_file_length,
  wasm_module_inst_t module_inst,
  wasm_exec_env_t exec_env,
  wasm_function_inst_t func
) {
  uint32_t model_length = 0;
  uint8_t* model_bytecode = NULL;
  read_file_to_buffer(&model_bytecode, &model_length, model_path);

  uint8_t* native_address_2 = NULL;
  uint64_t wasm_model =
        wasm_runtime_module_malloc(module_inst, model_length, (void **)&native_address_2);
  if(native_address_2 == NULL) {
    printf("wasm_runtime_module_malloc model failed. %s\n",
         wasm_runtime_get_exception(module_inst));
    return -1;
  }
  memcpy(native_address_2, model_bytecode, model_length);

  uint32_t model_name_size = strlen(model_name);

  uint8_t* native_address_3 = NULL;
  uint64_t wasm_model_name =
        wasm_runtime_module_malloc(module_inst, model_name_size, (void **)&native_address_3);
  if(native_address_3 == NULL) {
    printf("wasm_runtime_module_malloc model_name failed. %s\n",
         wasm_runtime_get_exception(module_inst));
    return -1;
  }
  memcpy(native_address_3, model_name, model_name_size);

  uint32_t wasm_argv[6] = { 
    wasm_grace,
    grace_hopper_file_length,
    wasm_model_name,
    model_name_size,
    wasm_model,
    model_length,
  };

  if (!wasm_runtime_call_wasm(exec_env, func, 6, wasm_argv)) {
    printf("call wasm entry point failed. %s\n",
         wasm_runtime_get_exception(module_inst));
    return -1;
  }
  
  wasm_runtime_module_free(module_inst, wasm_model);
  wasm_runtime_module_free(module_inst, wasm_model_name);
  free(model_bytecode);

  return 0;
}

int main(int argc, char *argv[])
{
  char error_buf[128];
  uint32_t stack_size = 10 * 1024;
  uint32_t heap_size = 36 * 1024 * 1024;
  uint8_t* heap_buf  = malloc(heap_size);
  // 32 MiB
  uint32_t initial_linear_memory = 32 * 1024 * 1024;

  if (heap_buf == NULL) {
    printf("heap_buf malloc failed\n");
    return -1;
  }
    
  RuntimeInitArgs init_args;
  memset(&init_args, 0, sizeof(RuntimeInitArgs));

  /* configure the memory allocator for the runtime */
  init_args.mem_alloc_type = Alloc_With_Pool;
  init_args.mem_alloc_option.pool.heap_buf = heap_buf;
  init_args.mem_alloc_option.pool.heap_size = heap_size;

  /* configure the native functions being exported to WASM app */
  init_args.native_module_name = "env";
  init_args.n_native_symbols = 0;
  init_args.native_symbols = NULL;

  if (!wasm_runtime_full_init(&init_args)) {
      printf("Init runtime environment failed.\n");
      return -1;
  }
    
  // wasm_runtime_set_log_level(WASM_LOG_LEVEL_VERBOSE);
    
  /* load WASM module */
  char* wasm_path = "out/onnx_bench.aot";
  uint32_t wasm_file_length = 0;
  uint8_t* wasm_bytecode = NULL;

  read_file_to_buffer(&wasm_bytecode, &wasm_file_length, wasm_path);

  wasm_module_t module;
  if (!(module = wasm_runtime_load(wasm_bytecode,
                                          wasm_file_length,
                                          error_buf, sizeof(error_buf)))) {
    printf("Load wasm module failed. error: %s\n", error_buf);
    return -1;
  }
    
  wasm_module_inst_t module_inst;
  if (!(module_inst =
          wasm_runtime_instantiate(module, stack_size, initial_linear_memory,
                                   error_buf, sizeof(error_buf)))) {
    printf("Instantiate wasm module failed. error: %s\n", error_buf);
    return -1;
  }

  
  wasm_exec_env_t exec_env = wasm_runtime_create_exec_env(module_inst, stack_size);
  if (!exec_env) {
    printf("Create wasm execution environment failed.\n");
    return -1;
  }
   
  wasm_function_inst_t func = NULL;
  if (!(func = wasm_runtime_lookup_function(module_inst, "execute"))) {
    printf("could not find hello function\n");
    return -1;
  }

  char* grace_hopper_path = "data/grace_hopper.jpg";
  uint32_t grace_hopper_file_length = 0;
  uint8_t* grace_hopper_bytecode = NULL;
  read_file_to_buffer(&grace_hopper_bytecode, &grace_hopper_file_length, grace_hopper_path);

  uint8_t* native_address_1 = NULL;
  uint64_t wasm_grace =
        wasm_runtime_module_malloc(module_inst, grace_hopper_file_length, (void **)&native_address_1);
  if(native_address_1 == NULL) {
    printf("wasm_runtime_module_malloc grace failed. %s\n",
         wasm_runtime_get_exception(module_inst));
    return -1;
  }
  memcpy(native_address_1, grace_hopper_bytecode, grace_hopper_file_length);

  run_model(
    "mobilenet",
    "data/mobilenetv2-7.onnx",
    wasm_grace,
    grace_hopper_file_length,
    module_inst,
    exec_env,
    func
  );

  run_model(
    "yolo",
    "data/yolov8n-face.onnx",
    wasm_grace,
    grace_hopper_file_length,
    module_inst,
    exec_env,
    func
  );

  wasm_runtime_module_free(module_inst, wasm_grace);
  free(grace_hopper_bytecode);
 
  wasm_runtime_deinstantiate(module_inst);
  wasm_runtime_unload(module);
  wasm_runtime_destroy();

  free(heap_buf);

  return 0;
}
