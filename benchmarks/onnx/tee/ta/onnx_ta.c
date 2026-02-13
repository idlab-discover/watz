#include <tee_internal_api.h>
#include <tee_internal_api_extensions.h>

#include <onnx_ta.h>

typedef int clockid_t;
struct timespec {
  long int tv_sec;  /* Seconds.  */
  long int tv_nsec; /* Nanoseconds.  */
};
int clock_gettime(clockid_t clock_id, struct timespec *tp) {
  TEE_Time time;

  TEE_GetREETime(&time);

  tp->tv_sec = time.seconds;
  tp->tv_nsec =
      time.nanos; // The GP API has been extended to retrieve nano time

  return 0;
}

float seven[1][1][28][28] = {{{
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0,   0,   0,   0,   0,   255, 255, 255, 255, 255, 255, 255,
     255, 255, 255, 255, 255, 255, 0,   0,   0,   0,   0,   0},
    {0,   0,   0,   0,   0,   255, 255, 255, 255, 255, 255, 255,
     255, 255, 255, 255, 255, 0,   0,   0,   0,   0,   0,   0},
    {0, 0, 0, 0,   0,   0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 255, 255, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0,   0,   0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0,   0,   0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0,   0,   0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0,   0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0,   0,   0,   0,   0,   0, 0, 0, 255, 255, 255, 255,
     255, 255, 255, 255, 255, 0, 0, 0, 0,   0,   0,   0},
    {0,   0,   0,   0,   0,   0, 0, 0, 255, 255, 255, 255,
     255, 255, 255, 255, 255, 0, 0, 0, 0,   0,   0,   0},
    {0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255,
     255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255,
     255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255,
     255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0,   0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0,   0},
}}};

int execute(char *benchmark_buffer, int benchmark_buffer_size,
            float input[1][1][28][28]);

/*
 * Called when the instance of the TA is created. This is the first call in
 * the TA.
 */
TEE_Result TA_CreateEntryPoint(void) {
  DMSG("has been called");

  return TEE_SUCCESS;
}

/*
 * Called when the instance of the TA is destroyed if the TA has not
 * crashed or panicked. This is the last call in the TA.
 */
void TA_DestroyEntryPoint(void) { DMSG("has been called"); }

/*
 * Called when a new session is opened to the TA. *sess_ctx can be updated
 * with a value to be able to identify this session in subsequent calls to the
 * TA. In this function you will normally do the global initialization for the
 * TA.
 */
TEE_Result TA_OpenSessionEntryPoint(uint32_t param_types,
                                    TEE_Param __maybe_unused params[4],
                                    void __maybe_unused **sess_ctx) {
  uint32_t exp_param_types =
      TEE_PARAM_TYPES(TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE,
                      TEE_PARAM_TYPE_NONE, TEE_PARAM_TYPE_NONE);

  DMSG("has been called");

  if (param_types != exp_param_types)
    return TEE_ERROR_BAD_PARAMETERS;

  /* Unused parameters */
  (void)&params;
  (void)&sess_ctx;

  /* If return value != TEE_SUCCESS the session will not be created. */
  return TEE_SUCCESS;
}

/*
 * Called when a session is closed, sess_ctx hold the value that was
 * assigned by TA_OpenSessionEntryPoint().
 */
void TA_CloseSessionEntryPoint(void __maybe_unused *sess_ctx) {
  (void)&sess_ctx; /* Unused parameter */
  IMSG("Goodbye!\n");
}

static TEE_Result call_onnx_runtime(TEE_Param *param_time,
                                    char *benchmark_buffer,
                                    int benchmark_buffer_size) {
  DMSG("has been called");

  execute(benchmark_buffer, benchmark_buffer_size, seven);

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
  case TA_ONNX_EXECUTE:
    return call_onnx_runtime(&params[0], params[0].memref.buffer,
                             params[0].memref.size);
  default:
    return TEE_ERROR_BAD_PARAMETERS;
  }
}
