/* Phase H: optional OpenBLAS cblas_sgemm hook for li-array matmul (dlopen, no link-time dep). */
#include "li_rt_blas.h"
#include "li_rt_dl_compat.h"

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum CBLAS_ORDER { CblasRowMajor = 101, CblasColMajor = 102 };
enum CBLAS_TRANSPOSE { CblasNoTrans = 111, CblasTrans = 112 };

typedef void (*cblas_dgemm_fn)(enum CBLAS_ORDER Order, enum CBLAS_TRANSPOSE TransA,
                               enum CBLAS_TRANSPOSE TransB, const int M, const int N, const int K,
                               const double alpha, const double* A, const int lda, const double* B,
                               const int ldb, const double beta, double* C, const int ldc);

static void* g_openblas_lib;
static cblas_dgemm_fn p_cblas_dgemm;
static int g_blas_init_done;
static int g_blas_ready;

static int li_rt_blas_env_wanted(void) {
  const char* v = getenv("LI_ARRAY_BLAS");
  if (v == NULL || v[0] == '\0') {
    return 0;
  }
  if (v[0] == '0' && v[1] == '\0') {
    return 0;
  }
  if (strcasecmp(v, "off") == 0 || strcasecmp(v, "false") == 0 || strcasecmp(v, "no") == 0) {
    return 0;
  }
  return 1;
}

static void li_rt_blas_init_once(void) {
  static const char* lib_names[] = {
#if defined(_WIN32)
      "libopenblas.dll",
      "openblas.dll",
#else
      "libopenblas.so.0",
      "libopenblas.so",
#endif
      NULL,
  };
  int i;

  if (g_blas_init_done) {
    return;
  }
  g_blas_init_done = 1;
  if (!li_rt_blas_env_wanted()) {
    return;
  }
  for (i = 0; lib_names[i] != NULL; ++i) {
    g_openblas_lib = li_rt_dlopen(lib_names[i], RTLD_NOW | RTLD_LOCAL);
    if (g_openblas_lib != NULL) {
      break;
    }
  }
  if (g_openblas_lib == NULL) {
    return;
  }
  p_cblas_dgemm = (cblas_dgemm_fn)li_rt_dlsym(g_openblas_lib, "cblas_dgemm");
  if (p_cblas_dgemm != NULL) {
    g_blas_ready = 1;
    /* Tiny GEMMs pay OpenBLAS thread/dispatch overhead; keep user override if set. */
    (void)setenv("OPENBLAS_NUM_THREADS", "1", 0);
  }
}

/** Li codegen stores `float` as f64; skip BLAS below 16³ — 8×8 pilot is faster on @vectorized CPU. */
static int li_rt_blas_size_ok(int32_t m, int32_t n, int32_t k) {
  const int64_t mnk = (int64_t)m * (int64_t)n * (int64_t)k;
  return mnk >= 4096;
}

int32_t li_rt_blas_sgemm_ready(void) {
  li_rt_blas_init_once();
  return g_blas_ready ? 1 : 0;
}

int32_t li_rt_blas_sgemm_f32(int32_t m, int32_t n, int32_t k, int32_t ld, double* a, double* b,
                             double* c) {
  if (a == NULL || b == NULL || c == NULL) {
    return 1;
  }
  if (m <= 0 || n <= 0 || k <= 0 || ld <= 0) {
    return 1;
  }
  /* Row-major: lda/ldb/ldc must cover inner/outer dims (shared ld for square pilot tiles). */
  if (k > ld || n > ld) {
    return 1;
  }
  if (!li_rt_blas_env_wanted() || !li_rt_blas_size_ok(m, n, k)) {
    return 1;
  }
  li_rt_blas_init_once();
  if (!g_blas_ready || p_cblas_dgemm == NULL) {
    return 1;
  }
  p_cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, (int)m, (int)n, (int)k, 1.0, a, (int)ld,
                b, (int)ld, 0.0, c, (int)ld);
  return 0;
}