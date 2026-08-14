#include <tee_internal_api.h>
#include <tee_internal_api_extensions.h>

#include <onnx2c_ta.h>
#include "input.h"
#include "lib/math.c"

#define CLOCK_REALTIME           0
#define CLOCK_MONOTONIC          1

typedef int clockid_t;
struct timespec {
  long int tv_sec;  /* Seconds.  */
  long int tv_nsec; /* Nanoseconds.  */
};
int clock_gettime(__maybe_unused clockid_t clock_id, struct timespec *tp) {
  TEE_Time time;

  TEE_GetREETime(&time);

  tp->tv_sec = time.seconds;
  // The GP API has been extended to retrieve nano time 
  tp->tv_nsec = time.nanos;

  return 0;
}

#define timespec_diff(a, b, result)                                            \
  do {                                                                         \
    (result)->tv_sec = (a)->tv_sec - (b)->tv_sec;                              \
    (result)->tv_nsec = (a)->tv_nsec - (b)->tv_nsec;                           \
    if ((result)->tv_nsec < 0) {                                               \
      --(result)->tv_sec;                                                      \
      (result)->tv_nsec += 1000000000;                                         \
    }                                                                          \
  } while (0)

#define timespec_to_micro(t) t.tv_sec * 1000 * 1000 + t.tv_nsec / 1000

#define BENCHMARK_START(X)                                                     \
  struct timespec start_##X, end_##X, X;                                       \
  clock_gettime(CLOCK_MONOTONIC, &start_##X)

#define BENCHMARK_STOP(X)                                                      \
  do {                                                                         \
    clock_gettime(CLOCK_MONOTONIC, &end_##X);                                  \
    timespec_diff(&end_##X, &start_##X, &X);                                   \
  } while (0)

void entry(const float tensor_data[1][3][224][224],
           float tensor_mobilenetv20_output_flatten0_reshape0[1][1000]);

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
TA_Execute(uint32_t param_types, TEE_Param params[4])
{
  DMSG("has been called");
    
  uint32_t exp_param_types =
     TEE_PARAM_TYPES(TEE_PARAM_TYPE_MEMREF_OUTPUT, TEE_PARAM_TYPE_NONE,
              TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE);
  if (exp_param_types != param_types)
    return TEE_ERROR_BAD_PARAMETERS;

  float output[1][1000];

  uint8_t warmup_iters = 20;
  uint8_t timed_iters = 50;

  for (uint8_t i = 0; i < warmup_iters; i++) {
    entry(input, output);
  }

  uint32_t results_buffer_size = params[0].memref.size;
  float samples[results_buffer_size];
  for (uint8_t i = 0; i < results_buffer_size; i++) {
    BENCHMARK_START(nanos);

    for (uint8_t j = 0; j < timed_iters; j++) {
      entry(input, output);
    }

    BENCHMARK_STOP(nanos);
    float ns_per_call = timespec_to_micro(nanos) / timed_iters * 1000;
    samples[i] = ns_per_call;
  }

  params[0].memref.buffer = samples;

  return TEE_SUCCESS;
}

/*
 * Called when a TA is invoked. sess_ctx hold that value that was
 * assigned by TA_OpenSessionEntryPoint(). The rest of the paramters
 * comes from normal world.
 */
TEE_Result TA_InvokeCommandEntryPoint(void __maybe_unused *sess_ctx,
                                      uint32_t cmd_id, uint32_t param_types,
                                      TEE_Param params[4]) {
  (void)&sess_ctx; /* Unused parameter */
  (void)&param_types;
  (void)&params;

  switch (cmd_id) {
  case COMMAND_RUN:
    TA_Execute(param_types, params);
    return TEE_SUCCESS;
  default:
    return TEE_ERROR_BAD_PARAMETERS;
  }
}

