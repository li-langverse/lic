#include "li_parallel.h"

#include <float.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#else
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

#if defined(_WIN32)
static __declspec(thread) double* g_li_par_reduce_tls = NULL;
#else
static __thread double* g_li_par_reduce_tls = NULL;
#endif

void li_par_reduce_acc_add_f64(double delta) {
  if (g_li_par_reduce_tls != NULL) {
    *g_li_par_reduce_tls += delta;
  }
}

void li_par_reduce_acc_min_f64(double delta) {
  if (g_li_par_reduce_tls != NULL && delta < *g_li_par_reduce_tls) {
    *g_li_par_reduce_tls = delta;
  }
}

void li_par_reduce_acc_max_f64(double delta) {
  if (g_li_par_reduce_tls != NULL && delta > *g_li_par_reduce_tls) {
    *g_li_par_reduce_tls = delta;
  }
}

typedef struct {
  void (*body)(long long);
  long long begin;
  long long end;
  double* partial;
} LiParReduceWorkerTask;

#if defined(_WIN32)

static DWORD WINAPI li_par_reduce_win_thread(LPVOID raw) {
  LiParReduceWorkerTask* task = (LiParReduceWorkerTask*)raw;
  g_li_par_reduce_tls = task->partial;
  for (long long i = task->begin; i < task->end; ++i) {
    task->body(i);
  }
  g_li_par_reduce_tls = NULL;
  return 0;
}

#else

static void* li_par_reduce_pthread_worker(void* raw) {
  LiParReduceWorkerTask* task = (LiParReduceWorkerTask*)raw;
  g_li_par_reduce_tls = task->partial;
  for (long long i = task->begin; i < task->end; ++i) {
    task->body(i);
  }
  g_li_par_reduce_tls = NULL;
  return NULL;
}

#endif

typedef void (*LiParReduceCombineFn)(double* accum, double partial);

static void li_par_reduce_combine_add(double* accum, double partial) {
  *accum += partial;
}

static void li_par_reduce_combine_min(double* accum, double partial) {
  if (partial < *accum) {
    *accum = partial;
  }
}

static void li_par_reduce_combine_max(double* accum, double partial) {
  if (partial > *accum) {
    *accum = partial;
  }
}

static void li_parallel_for_reduce_f64(long long start, long long end, void (*body)(long long),
                                       double* accum, int team_size, double partial_init,
                                       LiParReduceCombineFn combine) {
  if (body == NULL || accum == NULL || combine == NULL || start >= end) {
    return;
  }
  const long long trip = end - start;
  if (team_size <= 0) {
    team_size = li_par_pool_team_size();
  }
  if (team_size > LI_MAX_THREADS) {
    team_size = LI_MAX_THREADS;
  }
  if (trip < (long long)team_size) {
    team_size = (int)trip;
  }
  if (team_size < 1) {
    team_size = 1;
  }

  if (team_size <= 1) {
    g_li_par_reduce_tls = accum;
    for (long long i = start; i < end; ++i) {
      body(i);
    }
    g_li_par_reduce_tls = NULL;
    return;
  }

  double partials[LI_MAX_THREADS];
  LiParReduceWorkerTask tasks[LI_MAX_THREADS];
  const long long base = trip / team_size;
  const long long rem = trip % team_size;
  long long cur = start;
  int launched = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    partials[launched] = partial_init;
    tasks[launched].body = body;
    tasks[launched].begin = cur;
    tasks[launched].end = cur + len;
    tasks[launched].partial = &partials[launched];
    cur += len;
    ++launched;
  }

#if defined(_WIN32)
  HANDLE handles[LI_MAX_THREADS];
  for (int w = 0; w < launched; ++w) {
    handles[w] = CreateThread(NULL, 0, li_par_reduce_win_thread, &tasks[w], 0, NULL);
  }
  WaitForMultipleObjects((DWORD)launched, handles, TRUE, INFINITE);
  for (int w = 0; w < launched; ++w) {
    if (handles[w]) {
      CloseHandle(handles[w]);
    }
  }
#else
  pthread_t threads[LI_MAX_THREADS];
  for (int w = 0; w < launched; ++w) {
    pthread_create(&threads[w], NULL, li_par_reduce_pthread_worker, &tasks[w]);
  }
  for (int w = 0; w < launched; ++w) {
    pthread_join(threads[w], NULL);
  }
#endif

  for (int w = 0; w < launched; ++w) {
    combine(accum, partials[w]);
  }
}

void li_parallel_for_reduce_add_f64(long long start, long long end, void (*body)(long long),
                                    double* accum, int team_size) {
  li_parallel_for_reduce_f64(start, end, body, accum, team_size, 0.0, li_par_reduce_combine_add);
}

void li_parallel_for_reduce_min_f64(long long start, long long end, void (*body)(long long),
                                    double* accum, int team_size) {
  li_parallel_for_reduce_f64(start, end, body, accum, team_size, DBL_MAX, li_par_reduce_combine_min);
}

void li_parallel_for_reduce_max_f64(long long start, long long end, void (*body)(long long),
                                    double* accum, int team_size) {
  li_parallel_for_reduce_f64(start, end, body, accum, team_size, -DBL_MAX,
                             li_par_reduce_combine_max);
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
