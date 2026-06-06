#include "reduce_core.h"

#include <stdlib.h>
#include <string.h>

enum { LI_RED_N = 100000000 };

static double g_li_reduce_checksum;

#ifdef LI_PAR_REDUCE_RT
extern void li_parallel_for_i64(long long start, long long end, void (*body)(long long),
                                int team_size);
extern double li_par_reduce_sum_f64(const double* data, long long n, int team_size);

static double* g_li_reduce_buf;

static void li_reduce_init_elem(long long i) {
  g_li_reduce_buf[i] = (double)(i & 1023) * 1e-6;
}
#endif

static int li_parallel_enabled(void) {
  const char* flag = getenv("LI_PARALLEL");
  return flag != NULL && strcmp(flag, "0") != 0;
}

static double li_reduce_sum_serial(const double* a, int n) {
  double acc = 0.0;
  for (int i = 0; i < n; ++i) {
    acc += a[i];
  }
  return acc;
}

__attribute__((noinline)) void li_reduce_sum_kernel(void) {
  double* a = (double*)malloc((size_t)LI_RED_N * sizeof(double));
  if (!a) {
    g_li_reduce_checksum = 0.0;
    return;
  }
#if defined(LI_PAR_REDUCE_RT)
  if (li_parallel_enabled()) {
    g_li_reduce_buf = a;
    li_parallel_for_i64(0, LI_RED_N, li_reduce_init_elem, 0);
    g_li_reduce_checksum = li_par_reduce_sum_f64(a, LI_RED_N, 0);
    g_li_reduce_buf = NULL;
  } else {
    for (int i = 0; i < LI_RED_N; ++i) {
      a[i] = (double)(i & 1023) * 1e-6;
    }
    g_li_reduce_checksum = li_reduce_sum_serial(a, LI_RED_N);
  }
#else
  for (int i = 0; i < LI_RED_N; ++i) {
    a[i] = (double)(i & 1023) * 1e-6;
  }
  g_li_reduce_checksum = li_reduce_sum_serial(a, LI_RED_N);
#endif
  free(a);
}

double li_reduce_sum_checksum(void) { return g_li_reduce_checksum; }
