#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/** 1 when LI_ARRAY_BLAS is set and OpenBLAS cblas_dgemm resolved via dlopen. */
int32_t li_rt_blas_sgemm_ready(void);

/** Row-major Li-float (f64) GEMM: C = A*B with leading dimension ld. Returns 0 on success, 1 on error. */
int32_t li_rt_blas_sgemm_f32(int32_t m, int32_t n, int32_t k, int32_t ld, double* a, double* b,
                             double* c);

/** Phase I: blocked GEMM micro-tile size from LI_ARRAY_GEMM_TILE (8 default, 16 optional). */
int32_t li_rt_gemm_tile_env(void);

/** Phase I: full 32×32 identity GEMM via OpenBLAS; writes C[0] for smoke corner check. */
int32_t li_rt_blas_matmul_dense32_identity(double* out_c00);

#ifdef __cplusplus
}
#endif