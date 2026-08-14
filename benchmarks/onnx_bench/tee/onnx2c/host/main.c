// Standard C library headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

// BSD headers
#include <err.h>

// GlobalPlatform Client API
#include <tee_client_api.h>

// GlobalPlatfrom TA
#include <onnx2c_ta.h>

typedef struct {
  TEEC_Context context;
  TEEC_Session session;
} tee_context;

static void initialize_context(tee_context *tee) {
  TEEC_Result res;

  res = TEEC_InitializeContext(NULL, &tee->context);
  if (res != TEEC_SUCCESS)
    errx(EXIT_FAILURE, "TEEC_InitializeContext failed with code %#x", res);
}

static void open_session(tee_context *tee) {
  TEEC_Result res;
  TEEC_UUID uuid = TA_ONNX2C_UUID;
  uint32_t err_origin;

  res = TEEC_OpenSession(&tee->context, &tee->session, &uuid, TEEC_LOGIN_PUBLIC,
                         NULL, NULL, &err_origin);
  if (res != TEEC_SUCCESS)
    errx(EXIT_FAILURE, "TEEC_OpenSession failed with code %#x origin %#x", res,
         err_origin);
}

static void close_session(tee_context *tee) {
  TEEC_CloseSession(&tee->session);
}

static void finalize_context(tee_context *tee) {
  TEEC_FinalizeContext(&tee->context);
}

int compare(const void * a, const void * b)
{
  return ( *(float*)a - *(float*)b );
}

static void execute(tee_context *tee) {
  TEEC_Result res;
  TEEC_Operation op;
  uint32_t err_origin;

  memset(&op, 0, sizeof(op));

  uint8_t repetition = 10;
  float *samples = malloc(repetition * sizeof(float));

  op.paramTypes =
      TEEC_PARAM_TYPES(TEEC_MEMREF_TEMP_OUTPUT, TEEC_NONE, TEEC_NONE, TEEC_NONE);
  op.params[0].tmpref.buffer = samples;
  op.params[0].tmpref.size = repetition;

  res =
      TEEC_InvokeCommand(&tee->session, COMMAND_RUN, &op, &err_origin);

  if (res != TEEC_SUCCESS) {
    printf("TEEC_InvokeCommand failed with code %#x origin %#x\n", res,
           err_origin);
    return;
  }

  qsort(samples, repetition, sizeof(float), compare);

  float min_val = samples[0];
  float median = samples[repetition / 2];
  float max_val = samples[repetition - 1];
  float pct_spread = (max_val - min_val) / min_val * 100;

  printf("[tee] mobilenet: min=%f median=%f max=%f ns/inference (spread %f, n=%d)\n", min_val, median, max_val, pct_spread, repetition);
}

int main(int argc, char *argv[]) {
  tee_context tee;

  initialize_context(&tee);
  open_session(&tee);

  execute(&tee);

  close_session(&tee);
  finalize_context(&tee);

  return 0;
}

