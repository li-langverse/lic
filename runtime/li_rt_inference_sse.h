#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Stage 8: native Li inference SSE backend (replaces Python mock in test-m15-inference-live). */
int32_t li_rt_inference_native_weights_ready(void);
int32_t li_rt_inference_native_decode_steps(void);
int32_t li_rt_inference_native_backend_run(int32_t port, const char* cancel_mark_path);

#ifdef __cplusplus
}
#endif
