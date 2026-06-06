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
  long long begin;
  long long end;
} LiParF64Part;

typedef struct {
  const long long* data;
  long long begin;
  long long end;
} LiParI64Part;

static LiParF64Part g_f64_parts[LI_MAX_THREADS];
static double g_f64_partials[LI_MAX_THREADS];
static LiParI64Part g_i64_parts[LI_MAX_THREADS];
static long long g_i64_partials[LI_MAX_THREADS];

static int li_par_clamp_team(long long n, int team_size) {
  if (team_size <= 0) {
    team_size = li_par_pool_team_size();
  }
  if (team_size > LI_MAX_THREADS) {
    team_size = LI_MAX_THREADS;
  }
  if (n < (long long)team_size) {
    team_size = (int)n;
  }
  if (team_size < 1) {
    team_size = 1;
  }
  return team_size;
}

static int li_par_partition_f64(const double* data, long long n, int team_size) {
  const long long base = n / team_size;
  const long long rem = n % team_size;
  long long cur = 0;
  int launched = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    g_f64_parts[launched].data = data;
    g_f64_parts[launched].begin = cur;
    g_f64_parts[launched].end = cur + len;
    cur += len;
    ++launched;
  }
  return launched;
}

static int li_par_partition_i64(const long long* data, long long n, int team_size) {
  const long long base = n / team_size;
  const long long rem = n % team_size;
  long long cur = 0;
  int launched = 0;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    g_i64_parts[launched].data = data;
    g_i64_parts[launched].begin = cur;
    g_i64_parts[launched].end = cur + len;
    cur += len;
    ++launched;
  }
  return launched;
}

static void li_par_sum_part_worker(long long part_idx) {
  const LiParF64Part* part = &g_f64_parts[part_idx];
  double acc = 0.0;
  for (long long i = part->begin; i < part->end; ++i) {
    acc += part->data[i];
  }
  g_f64_partials[part_idx] = acc;
}

static void li_par_min_part_worker(long long part_idx) {
  const LiParF64Part* part = &g_f64_parts[part_idx];
  double best = part->data[part->begin];
  for (long long i = part->begin + 1; i < part->end; ++i) {
    if (part->data[i] < best) {
      best = part->data[i];
    }
  }
  g_f64_partials[part_idx] = best;
}

static void li_par_max_part_worker(long long part_idx) {
  const LiParF64Part* part = &g_f64_parts[part_idx];
  double best = part->data[part->begin];
  for (long long i = part->begin + 1; i < part->end; ++i) {
    if (part->data[i] > best) {
      best = part->data[i];
    }
  }
  g_f64_partials[part_idx] = best;
}

static void li_par_sum_i64_part_worker(long long part_idx) {
  const LiParI64Part* part = &g_i64_parts[part_idx];
  long long acc = 0;
  for (long long i = part->begin; i < part->end; ++i) {
    acc += part->data[i];
  }
  g_i64_partials[part_idx] = acc;
}

double li_par_reduce_sum_f64(const double* data, long long n, int team_size) {
  if (n <= 0 || data == NULL) {
    return 0.0;
  }
  team_size = li_par_clamp_team(n, team_size);
  if (team_size <= 1) {
    double acc = 0.0;
    for (long long i = 0; i < n; ++i) {
      acc += data[i];
    }
    return acc;
  }
  const int launched = li_par_partition_f64(data, n, team_size);
  li_par_pool_fork_join(0, launched, li_par_sum_part_worker, team_size);
  double acc = 0.0;
  for (int w = 0; w < launched; ++w) {
    acc += g_f64_partials[w];
  }
  return acc;
}

double li_par_reduce_min_f64(const double* data, long long n, int team_size) {
  if (n <= 0 || data == NULL) {
    return 0.0;
  }
  team_size = li_par_clamp_team(n, team_size);
  if (team_size <= 1) {
    double best = data[0];
    for (long long i = 1; i < n; ++i) {
      if (data[i] < best) {
        best = data[i];
      }
    }
    return best;
  }
  const int launched = li_par_partition_f64(data, n, team_size);
  li_par_pool_fork_join(0, launched, li_par_min_part_worker, team_size);
  double best = g_f64_partials[0];
  for (int w = 1; w < launched; ++w) {
    if (g_f64_partials[w] < best) {
      best = g_f64_partials[w];
    }
  }
  return best;
}

double li_par_reduce_max_f64(const double* data, long long n, int team_size) {
  if (n <= 0 || data == NULL) {
    return 0.0;
  }
  team_size = li_par_clamp_team(n, team_size);
  if (team_size <= 1) {
    double best = data[0];
    for (long long i = 1; i < n; ++i) {
      if (data[i] > best) {
        best = data[i];
      }
    }
    return best;
  }
  const int launched = li_par_partition_f64(data, n, team_size);
  li_par_pool_fork_join(0, launched, li_par_max_part_worker, team_size);
  double best = g_f64_partials[0];
  for (int w = 1; w < launched; ++w) {
    if (g_f64_partials[w] > best) {
      best = g_f64_partials[w];
    }
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
  team_size = li_par_clamp_team(n, team_size);
  if (team_size <= 1) {
    long long acc = 0;
    for (long long i = 0; i < n; ++i) {
      acc += data[i];
    }
    return acc;
  }
  const int launched = li_par_partition_i64(data, n, team_size);
  li_par_pool_fork_join(0, launched, li_par_sum_i64_part_worker, team_size);
  long long acc = 0;
  for (int w = 0; w < launched; ++w) {
    acc += g_i64_partials[w];
  }
  return acc;
}
