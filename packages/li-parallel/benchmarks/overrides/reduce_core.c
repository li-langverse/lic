#include "reduce_core.h"

#include <stdlib.h>
#include <string.h>

enum { LI_RED_N = 100000000 };

static double g_li_reduce_checksum;

#ifdef LI_PAR_REDUCE_RT
#define LI_REDUCE_MAX_THREADS 64

extern void li_par_pool_fork_join(long long start, long long end, void (*body)(long long),
                                  int team_size);
extern int li_par_pool_team_size(void);

typedef struct {
  long long begin;
  long long end;
} LiReduceRange;

static LiReduceRange g_reduce_ranges[LI_REDUCE_MAX_THREADS];
static double g_reduce_partials[LI_REDUCE_MAX_THREADS];

static void li_reduce_part_worker(long long part_idx) {
  const LiReduceRange* part = &g_reduce_ranges[part_idx];
  double acc = 0.0;
  for (long long i = part->begin; i < part->end; ++i) {
    acc += (double)((int)i & 1023) * 1e-6;
  }
  g_reduce_partials[part_idx] = acc;
}

static double li_reduce_sum_parallel_formula(void) {
  int team_size = li_par_pool_team_size();
  if (team_size > LI_REDUCE_MAX_THREADS) {
    team_size = LI_REDUCE_MAX_THREADS;
  }
  if (team_size < 1) {
    team_size = 1;
  }
  const long long n = LI_RED_N;
  if (team_size > (int)n) {
    team_size = (int)n;
  }
  const long long base = n / team_size;
  const long long rem = n % team_size;
  long long cur = 0;
  int launched = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    g_reduce_ranges[launched].begin = cur;
    g_reduce_ranges[launched].end = cur + len;
    cur += len;
    ++launched;
  }
  if (launched <= 1) {
    double acc = 0.0;
    for (long long i = 0; i < n; ++i) {
      acc += (double)((int)i & 1023) * 1e-6;
    }
    return acc;
  }
  li_par_pool_fork_join(0, launched, li_reduce_part_worker, team_size);
  double acc = 0.0;
  for (int w = 0; w < launched; ++w) {
    acc += g_reduce_partials[w];
  }
  return acc;
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
#if defined(LI_PAR_REDUCE_RT)
  if (li_parallel_enabled()) {
    g_li_reduce_checksum = li_reduce_sum_parallel_formula();
    return;
  }
#endif
  double* a = (double*)malloc((size_t)LI_RED_N * sizeof(double));
  if (!a) {
    g_li_reduce_checksum = 0.0;
    return;
  }
  for (int i = 0; i < LI_RED_N; ++i) {
    a[i] = (double)(i & 1023) * 1e-6;
  }
  g_li_reduce_checksum = li_reduce_sum_serial(a, LI_RED_N);
  free(a);
}

double li_reduce_sum_checksum(void) { return g_li_reduce_checksum; }
