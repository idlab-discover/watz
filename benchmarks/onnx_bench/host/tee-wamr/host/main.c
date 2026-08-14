// Standard C library headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// BSD headers
#include <err.h>

// GlobalPlatform Client API
#include <tee_client_api.h>

// GlobalPlatfrom TA
#include <wamr_ta.h>

#define timespec_to_micro(t) t.tv_sec * 1000 * 1000 + t.tv_nsec / 1000

/* TEE resources */
typedef struct _tee_ctx {
    TEEC_Context ctx;
    TEEC_Session sess;
    uint8_t *output_buffer;
    uint64_t output_buffer_size;
} tee_ctx;

static void
prepare_tee_session(tee_ctx *ctx)
{
    TEEC_UUID uuid = TA_WAMR_UUID;
    uint32_t origin;
    TEEC_Result res;

    /* Initialize a context connecting us to the TEE */
    res = TEEC_InitializeContext(NULL, &ctx->ctx);
    if (res != TEEC_SUCCESS)
        errx(1, "TEEC_InitializeContext failed with code 0x%x", res);

    /* Open a session with the TA */
    res = TEEC_OpenSession(&ctx->ctx, &ctx->sess, &uuid, TEEC_LOGIN_PUBLIC,
                           NULL, NULL, &origin);
    if (res != TEEC_SUCCESS)
        errx(1, "TEEC_Opensession failed with code 0x%x origin 0x%x", res,
             origin);
}

static void
configure_heap_size(tee_ctx *ctx, uint32_t size)
{
    TEEC_Operation op;
    uint32_t origin;
    TEEC_Result res;

    memset(&op, 0, sizeof(op));
    op.paramTypes =
        TEEC_PARAM_TYPES(TEEC_VALUE_INPUT, TEEC_NONE, TEEC_NONE, TEEC_NONE);
    op.params[0].value.a = size;

    res = TEEC_InvokeCommand(&ctx->sess, COMMAND_CONFIGURE_HEAP, &op, &origin);
    if (res != TEEC_SUCCESS) {
        printf("The heap size of WaTZ cannot be configured. Error: %x", res);
    }
}

static void
configure_linear_memory(tee_ctx *ctx, uint32_t size)
{
    TEEC_Operation op;
    uint32_t origin;
    TEEC_Result res;

    memset(&op, 0, sizeof(op));
    op.paramTypes =
        TEEC_PARAM_TYPES(TEEC_VALUE_INPUT, TEEC_NONE, TEEC_NONE, TEEC_NONE);
    op.params[0].value.a = size;

    res = TEEC_InvokeCommand(&ctx->sess, COMMAND_CONFIGURE_LINEAR_MEMORY, &op, &origin);
    if (res != TEEC_SUCCESS) {
        printf("The initial_linear_memory of the Wasm-binary cannot be configured. Error: %x", res);
    }
}

static void
configure_output_buffer(tee_ctx *ctx) {
    TEEC_Operation op;
    uint32_t origin;
    TEEC_Result res;

    memset(&op, 0, sizeof(op));
    op.paramTypes =
        TEEC_PARAM_TYPES(TEEC_MEMREF_TEMP_INOUT, TEEC_NONE,
                         TEEC_NONE, TEEC_NONE);
    op.params[0].tmpref.buffer = ctx->output_buffer;
    op.params[0].tmpref.size = ctx->output_buffer_size;

    res = TEEC_InvokeCommand(&ctx->sess, COMMAND_CONFIGURE_OUT, &op, &origin);

    if (res != TEEC_SUCCESS) {
        printf("TEEC_InvokeCommand(COMMAND_CONFIGURE_MODEL) failed. Errror: %x", res);
    }
}

static bool
start_wasm(
    tee_ctx *ctx,
    uint8_t *wasm_bytecode,
    uint32_t wasm_file_length,
    char *model_name,
    uint8_t *model_bytecode,
    uint32_t model_length,
    uint8_t *input,
    uint32_t input_length
) {
    TEEC_Operation op;
    uint32_t origin;
    TEEC_Result res;

    memset(&op, 0, sizeof(op));
    op.paramTypes =
        TEEC_PARAM_TYPES(TEEC_MEMREF_TEMP_INPUT, TEEC_MEMREF_TEMP_INPUT,
                         TEEC_MEMREF_TEMP_INPUT, TEEC_MEMREF_TEMP_INPUT);
    op.params[0].tmpref.buffer = wasm_bytecode;
    op.params[0].tmpref.size = wasm_file_length;
    // op.params[1].tmpref.buffer = model_name;
    // op.params[1].tmpref.size = strlen(model_name);
    // op.params[2].tmpref.buffer = model_bytecode;
    // op.params[2].tmpref.size = model_length;
    // op.params[3].tmpref.buffer = input;
    // op.params[3].tmpref.size = input_length;

    res = TEEC_InvokeCommand(&ctx->sess, COMMAND_RUN_WASM, &op, &origin);

    if (res != TEEC_SUCCESS) {
        errx(1, "TEEC_InvokeCommand(START_WASM) failed 0x%x origin 0x%x", res,
             origin);
        return false;
    }

    return true;
}

static void
allocate_buffers(tee_ctx *ctx, uint64_t buffers_size)
{
    // The output buffer is used to capture writes to stdout from the WASM
    ctx->output_buffer = malloc(buffers_size);
    ctx->output_buffer_size = buffers_size;
}

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

static void
terminate_tee_session(tee_ctx *ctx)
{
    TEEC_CloseSession(&ctx->sess);
    TEEC_FinalizeContext(&ctx->ctx);
}

static void
print_buffers(tee_ctx *ctx)
{
    printf("%s", ctx->output_buffer);
}

static void
free_buffers(tee_ctx *ctx)
{
    ctx->output_buffer_size = 0;
    free(ctx->output_buffer);
}

int
main(int argc, char *argv[])
{
    if (argc < 7) {
        printf("ERROR: The number of arguments does not match.\n");
        printf("SYNTAX: %s heap_size initial_linear_memory wasm_path model_name model_path input_image_path\n", argv[0]);
        exit(1);
    }

    tee_ctx ctx;
    bool success = true;
    uint32_t heap_size = atoi(argv[1]);
    uint32_t initial_linear_memory = atoi(argv[2]);
    char *wasm_path = argv[3];
    char *model_name = argv[4];
    char *model_path = argv[5];
    char *input_image_path = argv[6];

#ifdef FRIEDRICH_DEBUG
    printf("ALLOCATE BUFFERS\n");
#endif
    allocate_buffers(&ctx, 5 * 1024);
#ifdef FRIEDRICH_DEBUG
    printf("Buffers allocated\n");
#endif

    prepare_tee_session(&ctx);
#ifdef FRIEDRICH_DEBUG
    printf("Tee session prepared\n");
#endif
    configure_heap_size(&ctx, heap_size);
    configure_linear_memory(&ctx, initial_linear_memory);
#ifdef FRIEDRICH_DEBUG
    printf("Heap and linear memory size configured\n");
#endif
    configure_output_buffer(&ctx);

    uint32_t input_image_file_length = 0;
    uint8_t* input_image_bytecode = NULL;
    read_file_to_buffer(&input_image_bytecode, &input_image_file_length, input_image_path);

    uint32_t wasm_file_length = 0;
    uint8_t* wasm_bytecode = NULL;
    read_file_to_buffer(&wasm_bytecode, &wasm_file_length, wasm_path);

    uint32_t model_length = 0;
    uint8_t* model_bytecode = NULL;
    read_file_to_buffer(&model_bytecode, &model_length, model_path);

    success = start_wasm(&ctx,
                    wasm_bytecode,
                    wasm_file_length,
                    model_name,
                    model_bytecode,
                    model_length,
                    input_image_bytecode,
                    input_image_file_length
    );

    terminate_tee_session(&ctx);

    print_buffers(&ctx);
    free_buffers(&ctx);

    return success ? EXIT_SUCCESS : 1;
}

