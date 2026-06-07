#include "li_parallel.h"

#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

typedef struct {
  void (*body)(long long);
  long long begin;
  long long end;
} LiParTask;

typedef struct LiParPool LiParPool;

struct LiParPool {
  int team_size;
  int initialized;
#if defined(_WIN32)
  PTP_POOL win_pool;
  PTP_CLEANUP_GROUP cleanup_group;
  TP_CALLBACK_ENVIRON callback_env;
  volatile LONG jobs_remaining;
  CRITICAL_SECTION join_lock;
  CONDITION_VARIABLE join_cv;
#else
  pthread_t* threads;
  pthread_mutex_t mutex;
  pthread_cond_t work_cv;
  pthread_cond_t done_cv;
  int shutdown;
  int active_workers;
  int jobs_pending;
  LiParTask task;
#endif
};

static LiParPool g_li_par_pool;
static int g_li_par_pool_team = 0;

static int li_par_env_team_size(void) {
  const char* nt = getenv("LI_OMP_THREADS");
  if (nt && *nt) {
    int threads = atoi(nt);
    if (threads > 0) {
      return threads;
    }
  }
#if defined(_WIN32)
  SYSTEM_INFO info;
  GetSystemInfo(&info);
  int cores = (int)info.dwNumberOfProcessors;
#else
  long cores = sysconf(_SC_NPROCESSORS_ONLN);
#endif
  if (cores < 1) {
    return 1;
  }
  if (cores > LI_MAX_THREADS) {
    return LI_MAX_THREADS;
  }
  return (int)cores;
}

static int li_par_clamp_team(int team_size, long long trip_count) {
  if (team_size <= 0) {
    team_size = li_par_env_team_size();
  }
  if (team_size > LI_MAX_THREADS) {
    team_size = LI_MAX_THREADS;
  }
  if (trip_count < (long long)team_size) {
    team_size = (int)trip_count;
  }
  if (team_size < 1) {
    team_size = 1;
  }
  return team_size;
}

#if defined(_WIN32)

static VOID CALLBACK li_par_win_worker(PTP_CALLBACK_INSTANCE instance, PVOID context,
                                       PTP_WORK work) {
  (void)instance;
  LiParTask* task = (LiParTask*)context;
  (void)work;
  for (long long i = task->begin; i < task->end; ++i) {
    task->body(i);
  }
  if (InterlockedDecrement(&g_li_par_pool.jobs_remaining) == 0) {
    WakeAllConditionVariable(&g_li_par_pool.join_cv);
  }
}

static void li_par_pool_init_win(int team_size) {
  if (g_li_par_pool.initialized && g_li_par_pool.team_size == team_size) {
    return;
  }
  if (g_li_par_pool.initialized) {
    if (g_li_par_pool.cleanup_group) {
      CloseThreadpoolCleanupGroupMembers(g_li_par_pool.cleanup_group, FALSE, NULL);
      CloseThreadpoolCleanupGroup(g_li_par_pool.cleanup_group);
    }
    if (g_li_par_pool.win_pool) {
      CloseThreadpool(g_li_par_pool.win_pool);
    }
    DeleteCriticalSection(&g_li_par_pool.join_lock);
  }
  InitializeCriticalSection(&g_li_par_pool.join_lock);
  InitializeConditionVariable(&g_li_par_pool.join_cv);
  g_li_par_pool.win_pool = CreateThreadpool(NULL);
  if (g_li_par_pool.win_pool) {
    SetThreadpoolThreadMinimum(g_li_par_pool.win_pool, (DWORD)team_size);
    SetThreadpoolThreadMaximum(g_li_par_pool.win_pool, (DWORD)team_size);
  }
  g_li_par_pool.cleanup_group = CreateThreadpoolCleanupGroup();
  InitializeThreadpoolEnvironment(&g_li_par_pool.callback_env);
  SetThreadpoolCallbackPool(&g_li_par_pool.callback_env, g_li_par_pool.win_pool);
  SetThreadpoolCallbackCleanupGroup(&g_li_par_pool.callback_env, g_li_par_pool.cleanup_group,
                                    NULL);
  g_li_par_pool.team_size = team_size;
  g_li_par_pool.initialized = 1;
}

static void li_par_pool_run_win(LiParTask* chunks, int launched) {
  g_li_par_pool.jobs_remaining = launched;
  for (int w = 0; w < launched; ++w) {
    PTP_WORK work = CreateThreadpoolWork(li_par_win_worker, &chunks[w], &g_li_par_pool.callback_env);
    if (work) {
      SubmitThreadpoolWork(work);
      CloseThreadpoolWork(work);
    } else {
      for (long long i = chunks[w].begin; i < chunks[w].end; ++i) {
        chunks[w].body(i);
      }
      if (InterlockedDecrement(&g_li_par_pool.jobs_remaining) == 0) {
        WakeAllConditionVariable(&g_li_par_pool.join_cv);
      }
    }
  }
  EnterCriticalSection(&g_li_par_pool.join_lock);
  while (g_li_par_pool.jobs_remaining > 0) {
    SleepConditionVariableCS(&g_li_par_pool.join_cv, &g_li_par_pool.join_lock, INFINITE);
  }
  LeaveCriticalSection(&g_li_par_pool.join_lock);
}

#else

static void* li_par_ephemeral_worker(void* raw) {
  LiParTask* task = (LiParTask*)raw;
  for (long long i = task->begin; i < task->end; ++i) {
    task->body(i);
  }
  return NULL;
}

static void* li_par_pool_worker(void* raw) {
  LiParPool* pool = (LiParPool*)raw;
  for (;;) {
    pthread_mutex_lock(&pool->mutex);
    while (!pool->shutdown && pool->jobs_pending == 0) {
      pthread_cond_wait(&pool->work_cv, &pool->mutex);
    }
    if (pool->shutdown) {
      pthread_mutex_unlock(&pool->mutex);
      break;
    }
    LiParTask local = pool->task;
    pool->jobs_pending = 0;
    pthread_mutex_unlock(&pool->mutex);

    for (long long i = local.begin; i < local.end; ++i) {
      local.body(i);
    }

    pthread_mutex_lock(&pool->mutex);
    pool->active_workers -= 1;
    if (pool->active_workers == 0) {
      pthread_cond_broadcast(&pool->done_cv);
    }
    pthread_mutex_unlock(&pool->mutex);
  }
  return NULL;
}

static void li_par_pool_init_pthread(int team_size) {
  if (g_li_par_pool.initialized && g_li_par_pool.team_size == team_size) {
    return;
  }
  if (g_li_par_pool.initialized) {
    pthread_mutex_lock(&g_li_par_pool.mutex);
    g_li_par_pool.shutdown = 1;
    pthread_cond_broadcast(&g_li_par_pool.work_cv);
    pthread_mutex_unlock(&g_li_par_pool.mutex);
    for (int i = 0; i < g_li_par_pool.team_size; ++i) {
      pthread_join(g_li_par_pool.threads[i], NULL);
    }
    free(g_li_par_pool.threads);
    pthread_mutex_destroy(&g_li_par_pool.mutex);
    pthread_cond_destroy(&g_li_par_pool.work_cv);
    pthread_cond_destroy(&g_li_par_pool.done_cv);
  }
  g_li_par_pool.team_size = team_size;
  g_li_par_pool.threads = (pthread_t*)calloc((size_t)team_size, sizeof(pthread_t));
  pthread_mutex_init(&g_li_par_pool.mutex, NULL);
  pthread_cond_init(&g_li_par_pool.work_cv, NULL);
  pthread_cond_init(&g_li_par_pool.done_cv, NULL);
  g_li_par_pool.shutdown = 0;
  g_li_par_pool.active_workers = 0;
  g_li_par_pool.jobs_pending = 0;
  for (int i = 0; i < team_size; ++i) {
    pthread_create(&g_li_par_pool.threads[i], NULL, li_par_pool_worker, &g_li_par_pool);
  }
  g_li_par_pool.initialized = 1;
}

static void li_par_pool_run_pthread(LiParTask* chunks, int launched) {
  pthread_mutex_lock(&g_li_par_pool.mutex);
  g_li_par_pool.active_workers = launched;
  for (int w = 0; w < launched; ++w) {
    g_li_par_pool.task = chunks[w];
    g_li_par_pool.jobs_pending = 1;
    pthread_cond_signal(&g_li_par_pool.work_cv);
    while (g_li_par_pool.jobs_pending > 0) {
      pthread_cond_wait(&g_li_par_pool.done_cv, &g_li_par_pool.mutex);
    }
  }
  while (g_li_par_pool.active_workers > 0) {
    pthread_cond_wait(&g_li_par_pool.done_cv, &g_li_par_pool.mutex);
  }
  pthread_mutex_unlock(&g_li_par_pool.mutex);
}

#endif

void li_par_pool_set_team_size(int team_size) { g_li_par_pool_team = team_size; }

int li_par_pool_team_size(void) {
  if (g_li_par_pool_team > 0) {
    return g_li_par_pool_team;
  }
  return li_par_env_team_size();
}

void li_par_pool_fork_join(long long start, long long end, void (*body)(long long), int team_size) {
  const long long trip = end - start;
  if (trip <= 0 || body == NULL) {
    return;
  }
  if (trip == 1) {
    body(start);
    return;
  }

  team_size = li_par_clamp_team(team_size > 0 ? team_size : li_par_pool_team_size(), trip);
  if (team_size <= 1) {
    for (long long i = start; i < end; ++i) {
      body(i);
    }
    return;
  }

#if defined(_WIN32)
  li_par_pool_init_win(team_size);
#else
  li_par_pool_init_pthread(team_size);
#endif

  LiParTask chunks[LI_MAX_THREADS];
  const long long base = trip / team_size;
  const long long rem = trip % team_size;
  int launched = 0;
  long long cur = start;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < (int)rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    chunks[launched].body = body;
    chunks[launched].begin = cur;
    chunks[launched].end = cur + len;
    cur += len;
    ++launched;
  }

#if defined(_WIN32)
  li_par_pool_run_win(chunks, launched);
#else
  pthread_t threads[LI_MAX_THREADS];
  for (int w = 0; w < launched; ++w) {
    LiParTask* arg = &chunks[w];
    if (pthread_create(&threads[w], NULL, li_par_ephemeral_worker, arg) != 0) {
      for (long long i = arg->begin; i < arg->end; ++i) {
        arg->body(i);
      }
      threads[w] = (pthread_t)0;
    }
  }
  for (int w = 0; w < launched; ++w) {
    if (threads[w]) {
      pthread_join(threads[w], NULL);
    }
  }
#endif
}

void li_par_pool_shutdown(void) {
  if (!g_li_par_pool.initialized) {
    return;
  }
#if defined(_WIN32)
  if (g_li_par_pool.cleanup_group) {
    CloseThreadpoolCleanupGroupMembers(g_li_par_pool.cleanup_group, FALSE, NULL);
    CloseThreadpoolCleanupGroup(g_li_par_pool.cleanup_group);
    g_li_par_pool.cleanup_group = NULL;
  }
  if (g_li_par_pool.win_pool) {
    CloseThreadpool(g_li_par_pool.win_pool);
    g_li_par_pool.win_pool = NULL;
  }
  DeleteCriticalSection(&g_li_par_pool.join_lock);
#else
  pthread_mutex_lock(&g_li_par_pool.mutex);
  g_li_par_pool.shutdown = 1;
  pthread_cond_broadcast(&g_li_par_pool.work_cv);
  pthread_mutex_unlock(&g_li_par_pool.mutex);
  for (int i = 0; i < g_li_par_pool.team_size; ++i) {
    pthread_join(g_li_par_pool.threads[i], NULL);
  }
  free(g_li_par_pool.threads);
  g_li_par_pool.threads = NULL;
  pthread_mutex_destroy(&g_li_par_pool.mutex);
  pthread_cond_destroy(&g_li_par_pool.work_cv);
  pthread_cond_destroy(&g_li_par_pool.done_cv);
#endif
  g_li_par_pool.initialized = 0;
  g_li_par_pool.team_size = 0;
}
