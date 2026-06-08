#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/** 1 when LI_ARRAY_BLAS is set and OpenBLAS cblas_sgemm resolved via dlopen. */
int32_t li_rt_blas_sgemm_ready(void);

/** Row-major f32 GEMM: C = A*B with leading dimension ld. Returns 0 on success, 1 on error. */
int32_t li_rt_blas_sgemm_f32(int32_t m, int32_t n, int32_t k, int32_t ld, float* a, float* b,
                             float* c);

#ifdef __cplusplus
}
#endif
