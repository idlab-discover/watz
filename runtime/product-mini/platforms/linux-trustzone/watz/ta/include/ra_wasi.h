#ifndef RA_WASI_H
#define RA_WASI_H

#include "wasm_export.h"

typedef size_t WASI_RA_Result;

#define WASI_RA_SUCCESS 0x000;
#define WASI_RA_GENERIC_ERROR 0x001;
#define WASI_RA_SANDBOX_VIOLATION 0x002;
#define WASI_RA_INVALID_RA_CONTEXT_HANDLE 0x003;
#define WASI_RA_INVALID_QUOTE_HANDLE 0x004;
#define WASI_RA_CONCURRENT_ERROR 0x005;

#define WASI_RA_DEFAULT_QUOTE_HANDLE 0
#define WASI_RA_DEFAULT_RA_CONTEXT_HANDLE 0

WASI_RA_Result
wasi_ra_collect_quote(wasm_exec_env_t exec_env, uint8_t *anchor,
                      int anchor_size, size_t quote_handle);
WASI_RA_Result
wasi_ra_net_dispose_quote(wasm_exec_env_t exec_env, size_t quote_handle);
WASI_RA_Result
wasi_ra_net_handshake(wasm_exec_env_t exec_env, const char *host,
                      uint8_t *ecdsa_service_public_key_x,
                      size_t ecdsa_service_public_key_x_size,
                      uint8_t *ecdsa_service_public_key_y,
                      size_t ecdsa_service_public_key_y_size,
                      uint8_t *anchor_buffer_out, size_t anchor_buffer_size,
                      size_t ra_context_handle_out);
WASI_RA_Result
wasi_ra_net_send_quote(wasm_exec_env_t exec_env, size_t ra_context_handle,
                       size_t quote_handle);
WASI_RA_Result
wasi_ra_net_receive_data(wasm_exec_env_t exec_env, size_t ra_context_handle,
                         size_t data_out, size_t data_size_inout);
WASI_RA_Result
wasi_ra_net_dispose(wasm_exec_env_t exec_env, size_t ra_context_handle);

extern NativeSymbol wasi_ra_native_symbols[];
extern const size_t wasi_ra_native_symbols_size;

#endif /*RA_WASI_H*/
