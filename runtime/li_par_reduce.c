#include "li_parallel.h"

#include <float.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32)
#include <pthread.h>
#endif

typedef struct {
  const double* data;
  long long n;
  double partial;
} LiParReduceSumCtx;

typedef void (*LiParReduceBody)(void* ctx, long long begin, long long end);

static void li_par_reduce_sum_body(void* raw, long long begin, long long end) {
  LiParReduceSumCtx* ctx = (LiParReduceSumCtx*)raw;
  double acc = 0.0;
  for (long long i = begin; i < end; ++i) {
    acc += ctx->data[i];
  }
  ctx->partial = acc;
}

static double li_par_tree_reduce_f64(LiParReduceBody body, void* ctx, long long n, int team_size) {
  if (n <= 0) {
    return 0.0;
  }
  if (n == 1) {
    LiParReduceSumCtx one = {(const double*)ctx, 1, 0.0};
    body(&one, 0, 1);
    return one.partial;
  }
  if (team_size <= 0) {
    team_size = li_par_pool_team_size();
  }
  if (team_size > LI_MAX_THREADS) {
    team_size = LI_MAX_THREADS;
  }
  if ((long long)team_size > n) {
    team_size = (int)n;
  }
  if (team_size <= 1) {
    LiParReduceSumCtx single = {(const double*)((LiParReduceSumCtx*)ctx)->data, n, 0.0};
    body(&single, 0, n);
    return single.partial;
  }

  LiParReduceSumCtx parts[LI_MAX_THREADS];
  const double* data = ((LiParReduceSumCtx*)ctx)->data;
  const long long base = n / team_size;
  const long long rem = n % team_size;
  long long cur = 0;
  int launched = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < (int)rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    parts[launched].data = data;
    parts[launched].n = len;
    parts[launched].partial = 0.0;
    body(&parts[launched], cur, cur + len);
    cur += len;
    ++launched;
  }
  double acc = 0.0;
  for (int w = 0; w < launched; ++w) {
    acc += parts[w].partial;
  }
  return acc;
}

double li_par_reduce_sum_f64(const double* data, long long n, int team_size) {
  LiParReduceSumCtx root = {data, n, 0.0};
  return li_par_tree_reduce_f64(li_par_reduce_sum_body, &root, n, team_size);
}

double li_par_reduce_min_f64(const double* data, long long n, int team_size) {
  if (n <= 0 || data == NULL) {
    return 0.0;
  }
  if (team_size <= 0) {
    team_size = li_par_pool_team_size();
  }
  double best = data[0];
  const long long base = n / team_size;
  const long long rem = n % team_size;
  long long cur = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < (int)rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    for (long long i = cur; i < cur + len; ++i) {
      if (data[i] < best) {
        best = data[i];
      }
    }
    cur += len;
  }
  return best;
}

double li_par_reduce_max_f64(const double* data, long long n, int team_size) {
  if (n <= 0 || data == NULL) {
    return 0.0;
  }
  if (team_size <= 0) {
    team_size = li_par_pool_team_size();
  }
  double best = data[0];
  const long long base = n / team_size;
  const long long rem = n % team_size;
  long long cur = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < (int)rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    for (long long i = cur; i < cur + len; ++i) {
      if (data[i] > best) {
        best = data[i];
      }
    }
    cur += len;
  }
  return best;
}

long long li_par_reduce_sum_i64(const long long* data, long long n, int team_size) {
  if (n <= 0 || data == NULL) {
    return 0;
  }
  if (team_size <= 0) {
    team_size = li_par_pool_team_size();
  }
  long long acc = 0;
  const long long base = n / team_size;
  const long long rem = n % team_size;
  long long cur = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < (int)rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    for (long long i = cur; i < cur + len; ++i) {
      acc += data[i];
    }
    cur += len;
  }
  return acc;
}
