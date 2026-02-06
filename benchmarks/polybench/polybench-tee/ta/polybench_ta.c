#include <tee_internal_api.h>
#include <tee_internal_api_extensions.h>

#include <polybench_ta.h>

#include "lib/math.c"

int fprintf(void *stream, const char *format, ...) { return 0; }

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

void *polybench_alloc_data(unsigned long long int n, int elt_size) {
  size_t val = n;
  val *= elt_size;

  return TEE_Malloc(val, 0);
}

int all(char *benchmark_buffer, int benchmark_buffer_size);

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

static TEE_Result execute(TEE_Param *param_time, char *benchmark_buffer,
                          int benchmark_buffer_size) {
  DMSG("has been called");

  all(benchmark_buffer, benchmark_buffer_size);

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
  case TA_POLYBENCH_EXECUTE:
    return execute(&params[0], params[0].memref.buffer, params[0].memref.size);
  default:
    return TEE_ERROR_BAD_PARAMETERS;
  }
}
