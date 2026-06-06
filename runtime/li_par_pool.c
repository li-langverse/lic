#include "li_parallel.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#else
#include <pthread.h>
#include <sched.h>
#include <unistd.h>
#endif

typedef struct {
  void (*body)(long long);
  long long begin;
  long long end;
} LiParTask;

typedef struct LiParPool LiParPool;

#if !defined(_WIN32)
typedef struct {
  LiParPool* pool;
  int worker_id;
} LiParWorkerArg;
#endif

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
  LiParWorkerArg* worker_args;
  pthread_mutex_t mutex;
  pthread_cond_t work_cv;
  pthread_cond_t done_cv;
  pthread_cond_t ready_cv;
  int shutdown;
  int jobs_pending;
  LiParTask batch[LI_MAX_THREADS];
  int batch_size;
  int workers_done;
  int workers_ready;
  LiParScheduleKind schedule;
  void (*job_body)(long long);
  long long job_start;
  long long job_trip;
  volatile long long job_next;
  long long job_chunk;
  long long steal_begin[LI_MAX_THREADS];
  long long steal_end[LI_MAX_THREADS];
  long long steal_cursor[LI_MAX_THREADS];
#endif
};

static LiParPool g_li_par_pool;
static int g_li_par_pool_team = 0;
static LiParScheduleKind g_li_par_schedule = LI_PAR_SCHED_STATIC;
static long long g_li_par_chunk_size = 0;

static LiParScheduleKind li_par_env_schedule(void) {
  const char* sched = getenv("LI_PAR_SCHEDULE");
  if (sched && *sched) {
    if (strcmp(sched, "dynamic") == 0) {
      return LI_PAR_SCHED_DYNAMIC;
    }
    if (strcmp(sched, "guided") == 0) {
      return LI_PAR_SCHED_GUIDED;
    }
    if (strcmp(sched, "steal") == 0) {
      return LI_PAR_SCHED_STEAL;
    }
  }
  return g_li_par_schedule;
}

static long long li_par_env_chunk_size(void) {
  const char* cs = getenv("LI_PAR_CHUNK_SIZE");
  if (cs && *cs) {
    long long chunk = atoll(cs);
    if (chunk > 0) {
      return chunk;
    }
  }
  return g_li_par_chunk_size;
}

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

typedef struct {
  void (*body)(long long);
  long long start;
  long long trip;
  volatile LONG64 next;
  long long chunk;
  int team_size;
  LiParScheduleKind schedule;
  long long steal_begin[LI_MAX_THREADS];
  long long steal_end[LI_MAX_THREADS];
  volatile LONG64 steal_cursor[LI_MAX_THREADS];
} LiParWinSharedJob;

static void li_par_win_run_dynamic(LiParWinSharedJob* job) {
  const long long chunk = job->chunk > 0 ? job->chunk : 1;
  for (;;) {
    const long long begin = InterlockedAdd64((LONG64*)&job->next, chunk) - chunk;
    if (begin >= job->trip) {
      return;
    }
    long long end = begin + chunk;
    if (end > job->trip) {
      end = job->trip;
    }
    for (long long i = job->start + begin; i < job->start + end; ++i) {
      job->body(i);
    }
  }
}

static int li_par_win_steal_claim(LiParWinSharedJob* job, int victim_id, long long* out_begin,
                                  long long* out_end) {
  const long long chunk = job->chunk > 0 ? job->chunk : 1;
  EnterCriticalSection(&g_li_par_pool.join_lock);
  const long long vcur = job->steal_cursor[victim_id];
  const long long vend = job->steal_end[victim_id];
  if (vcur >= vend) {
    LeaveCriticalSection(&g_li_par_pool.join_lock);
    return 0;
  }
  long long end = vcur + chunk;
  if (end > vend) {
    end = vend;
  }
  job->steal_cursor[victim_id] = end;
  *out_begin = vcur;
  *out_end = end;
  LeaveCriticalSection(&g_li_par_pool.join_lock);
  return 1;
}

static void li_par_win_run_steal(LiParWinSharedJob* job, int worker_id) {
  const long long start = job->start;

  for (;;) {
    long long begin;
    long long end;
    if (li_par_win_steal_claim(job, worker_id, &begin, &end)) {
      for (long long i = start + begin; i < start + end; ++i) {
        job->body(i);
      }
      continue;
    }
    int stole = 0;
    for (int v = 0; v < job->team_size; ++v) {
      if (v == worker_id) {
        continue;
      }
      if (li_par_win_steal_claim(job, v, &begin, &end)) {
        for (long long i = start + begin; i < start + end; ++i) {
          job->body(i);
        }
        stole = 1;
        break;
      }
    }
    if (!stole) {
      int done = 1;
      EnterCriticalSection(&g_li_par_pool.join_lock);
      for (int v = 0; v < job->team_size; ++v) {
        if (job->steal_cursor[v] < job->steal_end[v]) {
          done = 0;
          break;
        }
      }
      LeaveCriticalSection(&g_li_par_pool.join_lock);
      if (done) {
        return;
      }
      SwitchToThread();
    }
  }
}

static void li_par_win_run_guided(LiParWinSharedJob* job) {
  for (;;) {
    long long begin;
    long long chunk;
    EnterCriticalSection(&g_li_par_pool.join_lock);
    begin = job->next;
    if (begin >= job->trip) {
      LeaveCriticalSection(&g_li_par_pool.join_lock);
      return;
    }
    const long long rem = job->trip - begin;
    chunk = rem / job->team_size;
    if (chunk < 1) {
      chunk = 1;
    }
    job->next = begin + chunk;
    LeaveCriticalSection(&g_li_par_pool.join_lock);
    for (long long i = job->start + begin; i < job->start + begin + chunk; ++i) {
      job->body(i);
    }
  }
}

typedef struct {
  LiParWinSharedJob* job;
  int worker_id;
} LiParWinStealArg;

static VOID CALLBACK li_par_win_steal_worker(PTP_CALLBACK_INSTANCE instance, PVOID context,
                                             PTP_WORK work) {
  (void)instance;
  (void)work;
  LiParWinStealArg* arg = (LiParWinStealArg*)context;
  li_par_win_run_steal(arg->job, arg->worker_id);
  if (InterlockedDecrement(&g_li_par_pool.jobs_remaining) == 0) {
    WakeAllConditionVariable(&g_li_par_pool.join_cv);
  }
}

static VOID CALLBACK li_par_win_shared_worker(PTP_CALLBACK_INSTANCE instance, PVOID context,
                                              PTP_WORK work) {
  (void)instance;
  (void)work;
  LiParWinSharedJob* job = (LiParWinSharedJob*)context;
  if (job->schedule == LI_PAR_SCHED_GUIDED) {
    li_par_win_run_guided(job);
  } else {
    li_par_win_run_dynamic(job);
  }
  if (InterlockedDecrement(&g_li_par_pool.jobs_remaining) == 0) {
    WakeAllConditionVariable(&g_li_par_pool.join_cv);
  }
}

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

static void li_par_pool_run_win_shared(void (*body)(long long), long long start, long long trip,
                                       int team_size, LiParScheduleKind schedule,
                                       long long chunk_size) {
  LiParWinSharedJob job;
  job.body = body;
  job.start = start;
  job.trip = trip;
  job.next = 0;
  job.chunk = chunk_size;
  job.team_size = team_size;
  job.schedule = schedule;
  g_li_par_pool.jobs_remaining = team_size;
  for (int w = 0; w < team_size; ++w) {
    PTP_WORK work =
        CreateThreadpoolWork(li_par_win_shared_worker, &job, &g_li_par_pool.callback_env);
    if (work) {
      SubmitThreadpoolWork(work);
      CloseThreadpoolWork(work);
    } else {
      if (schedule == LI_PAR_SCHED_GUIDED) {
        li_par_win_run_guided(&job);
      } else {
        li_par_win_run_dynamic(&job);
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

static void li_par_pool_run_dynamic_pthread(LiParPool* pool) {
  const long long trip = pool->job_trip;
  const long long start = pool->job_start;
  void (*body)(long long) = pool->job_body;
  const long long chunk = pool->job_chunk > 0 ? pool->job_chunk : 1;

  for (;;) {
    long long begin;
    pthread_mutex_lock(&pool->mutex);
    begin = pool->job_next;
    if (begin >= trip) {
      pthread_mutex_unlock(&pool->mutex);
      return;
    }
    long long end = begin + chunk;
    if (end > trip) {
      end = trip;
    }
    pool->job_next = end;
    pthread_mutex_unlock(&pool->mutex);
    for (long long i = start + begin; i < start + end; ++i) {
      body(i);
    }
  }
}

static int li_par_steal_claim(LiParPool* pool, int victim_id, long long* out_begin,
                              long long* out_end) {
  const long long chunk = pool->job_chunk > 0 ? pool->job_chunk : 1;
  pthread_mutex_lock(&pool->mutex);
  const long long vcur = pool->steal_cursor[victim_id];
  const long long vend = pool->steal_end[victim_id];
  if (vcur >= vend) {
    pthread_mutex_unlock(&pool->mutex);
    return 0;
  }
  long long end = vcur + chunk;
  if (end > vend) {
    end = vend;
  }
  pool->steal_cursor[victim_id] = end;
  *out_begin = vcur;
  *out_end = end;
  pthread_mutex_unlock(&pool->mutex);
  return 1;
}

static void li_par_pool_run_steal_pthread(LiParPool* pool, int worker_id) {
  const long long start = pool->job_start;
  void (*body)(long long) = pool->job_body;

  for (;;) {
    long long begin;
    long long end;
    if (li_par_steal_claim(pool, worker_id, &begin, &end)) {
      for (long long i = start + begin; i < start + end; ++i) {
        body(i);
      }
      continue;
    }
    int stole = 0;
    for (int v = 0; v < pool->batch_size; ++v) {
      if (v == worker_id) {
        continue;
      }
      if (li_par_steal_claim(pool, v, &begin, &end)) {
        for (long long i = start + begin; i < start + end; ++i) {
          body(i);
        }
        stole = 1;
        break;
      }
    }
    if (!stole) {
      int done = 1;
      pthread_mutex_lock(&pool->mutex);
      for (int v = 0; v < pool->batch_size; ++v) {
        if (pool->steal_cursor[v] < pool->steal_end[v]) {
          done = 0;
          break;
        }
      }
      pthread_mutex_unlock(&pool->mutex);
      if (done) {
        return;
      }
      sched_yield();
    }
  }
}

static void li_par_pool_run_guided_pthread(LiParPool* pool) {
  const long long trip = pool->job_trip;
  const long long start = pool->job_start;
  void (*body)(long long) = pool->job_body;
  const int team = pool->batch_size;

  for (;;) {
    long long begin;
    long long chunk;
    pthread_mutex_lock(&pool->mutex);
    begin = pool->job_next;
    if (begin >= trip) {
      pthread_mutex_unlock(&pool->mutex);
      return;
    }
    const long long rem = trip - begin;
    chunk = rem / team;
    if (chunk < 1) {
      chunk = 1;
    }
    pool->job_next = begin + chunk;
    pthread_mutex_unlock(&pool->mutex);
    for (long long i = start + begin; i < start + begin + chunk; ++i) {
      body(i);
    }
  }
}

static void* li_par_pool_worker(void* raw) {
  LiParWorkerArg* warg = (LiParWorkerArg*)raw;
  LiParPool* pool = warg->pool;
  const int worker_id = warg->worker_id;

  for (;;) {
    pthread_mutex_lock(&pool->mutex);
    while (!pool->shutdown && pool->jobs_pending == 0) {
      pthread_cond_wait(&pool->work_cv, &pool->mutex);
    }
    if (pool->shutdown) {
      pthread_mutex_unlock(&pool->mutex);
      break;
    }
    const int batch_size = pool->batch_size;
    const LiParScheduleKind schedule = pool->schedule;
    pthread_mutex_unlock(&pool->mutex);

    if (schedule == LI_PAR_SCHED_STATIC) {
      if (worker_id < batch_size) {
        LiParTask local = pool->batch[worker_id];
        for (long long i = local.begin; i < local.end; ++i) {
          local.body(i);
        }
      }
    } else if (schedule == LI_PAR_SCHED_STEAL) {
      li_par_pool_run_steal_pthread(pool, worker_id);
    } else if (schedule == LI_PAR_SCHED_GUIDED) {
      li_par_pool_run_guided_pthread(pool);
    } else {
      li_par_pool_run_dynamic_pthread(pool);
    }

    pthread_mutex_lock(&pool->mutex);
    pool->workers_done += 1;
    if (pool->workers_done >= batch_size) {
      pthread_cond_broadcast(&pool->done_cv);
    }
    while (pool->jobs_pending && !pool->shutdown) {
      pthread_cond_wait(&pool->work_cv, &pool->mutex);
    }
    pool->workers_ready += 1;
    if (pool->workers_ready >= pool->batch_size) {
      pthread_cond_broadcast(&pool->ready_cv);
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
    free(g_li_par_pool.worker_args);
    pthread_mutex_destroy(&g_li_par_pool.mutex);
    pthread_cond_destroy(&g_li_par_pool.work_cv);
    pthread_cond_destroy(&g_li_par_pool.done_cv);
    pthread_cond_destroy(&g_li_par_pool.ready_cv);
  }
  g_li_par_pool.team_size = team_size;
  g_li_par_pool.threads = (pthread_t*)calloc((size_t)team_size, sizeof(pthread_t));
  g_li_par_pool.worker_args = (LiParWorkerArg*)calloc((size_t)team_size, sizeof(LiParWorkerArg));
  pthread_mutex_init(&g_li_par_pool.mutex, NULL);
  pthread_cond_init(&g_li_par_pool.work_cv, NULL);
  pthread_cond_init(&g_li_par_pool.done_cv, NULL);
  pthread_cond_init(&g_li_par_pool.ready_cv, NULL);
  g_li_par_pool.shutdown = 0;
  g_li_par_pool.jobs_pending = 0;
  g_li_par_pool.batch_size = 0;
  g_li_par_pool.workers_done = 0;
  g_li_par_pool.workers_ready = 0;
  for (int i = 0; i < team_size; ++i) {
    g_li_par_pool.worker_args[i].pool = &g_li_par_pool;
    g_li_par_pool.worker_args[i].worker_id = i;
    pthread_create(&g_li_par_pool.threads[i], NULL, li_par_pool_worker,
                   &g_li_par_pool.worker_args[i]);
  }
  g_li_par_pool.initialized = 1;
}

static void li_par_pool_run_pthread(LiParTask* chunks, int launched, LiParScheduleKind schedule,
                                    void (*body)(long long), long long start, long long trip,
                                    long long chunk_size) {
  pthread_mutex_lock(&g_li_par_pool.mutex);
  g_li_par_pool.schedule = schedule;
  if (schedule == LI_PAR_SCHED_STATIC) {
    for (int w = 0; w < launched; ++w) {
      g_li_par_pool.batch[w] = chunks[w];
    }
  } else {
    g_li_par_pool.job_body = body;
    g_li_par_pool.job_start = start;
    g_li_par_pool.job_trip = trip;
    g_li_par_pool.job_next = 0;
    g_li_par_pool.job_chunk = chunk_size;
    if (schedule == LI_PAR_SCHED_STEAL) {
      const long long base = trip / launched;
      const long long rem = trip % launched;
      long long cur = 0;
      for (int w = 0; w < launched; ++w) {
        const long long len = base + (w < rem ? 1 : 0);
        g_li_par_pool.steal_begin[w] = cur;
        g_li_par_pool.steal_end[w] = cur + len;
        g_li_par_pool.steal_cursor[w] = cur;
        cur += len;
      }
    }
  }
  g_li_par_pool.batch_size = launched;
  g_li_par_pool.workers_done = 0;
  g_li_par_pool.jobs_pending = 1;
  pthread_cond_broadcast(&g_li_par_pool.work_cv);
  while (g_li_par_pool.workers_done < launched) {
    pthread_cond_wait(&g_li_par_pool.done_cv, &g_li_par_pool.mutex);
  }
  g_li_par_pool.workers_ready = 0;
  g_li_par_pool.jobs_pending = 0;
  pthread_cond_broadcast(&g_li_par_pool.work_cv);
  while (g_li_par_pool.workers_ready < launched) {
    pthread_cond_wait(&g_li_par_pool.ready_cv, &g_li_par_pool.mutex);
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

void li_par_pool_set_schedule(LiParScheduleKind schedule) { g_li_par_schedule = schedule; }

LiParScheduleKind li_par_pool_schedule(void) { return li_par_env_schedule(); }

void li_par_pool_set_chunk_size(long long chunk_size) { g_li_par_chunk_size = chunk_size; }

long long li_par_pool_chunk_size(void) { return li_par_env_chunk_size(); }

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

  const LiParScheduleKind schedule = li_par_env_schedule();
  const long long chunk_size = li_par_env_chunk_size();

#if defined(_WIN32)
  li_par_pool_init_win(team_size);
#else
  li_par_pool_init_pthread(team_size);
#endif

  if (schedule == LI_PAR_SCHED_DYNAMIC || schedule == LI_PAR_SCHED_GUIDED ||
      schedule == LI_PAR_SCHED_STEAL) {
#if defined(_WIN32)
    if (schedule == LI_PAR_SCHED_STEAL) {
      LiParWinSharedJob job;
      LiParWinStealArg args[LI_MAX_THREADS];
      job.body = body;
      job.start = start;
      job.trip = trip;
      job.chunk = chunk_size;
      job.team_size = team_size;
      job.schedule = schedule;
      const long long base = trip / team_size;
      const long long rem = trip % team_size;
      long long cur = 0;
      for (int w = 0; w < team_size; ++w) {
        const long long len = base + (w < rem ? 1 : 0);
        job.steal_begin[w] = cur;
        job.steal_end[w] = cur + len;
        job.steal_cursor[w] = cur;
        cur += len;
        args[w].job = &job;
        args[w].worker_id = w;
      }
      g_li_par_pool.jobs_remaining = team_size;
      for (int w = 0; w < team_size; ++w) {
        PTP_WORK work =
            CreateThreadpoolWork(li_par_win_steal_worker, &args[w], &g_li_par_pool.callback_env);
        if (work) {
          SubmitThreadpoolWork(work);
          CloseThreadpoolWork(work);
        } else {
          li_par_win_run_steal(&job, w);
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
    } else {
      li_par_pool_run_win_shared(body, start, trip, team_size, schedule, chunk_size);
    }
#else
    li_par_pool_run_pthread(NULL, team_size, schedule, body, start, trip, chunk_size);
#endif
    return;
  }

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
  li_par_pool_run_pthread(chunks, launched, LI_PAR_SCHED_STATIC, body, start, trip, chunk_size);
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
  free(g_li_par_pool.worker_args);
  g_li_par_pool.worker_args = NULL;
  pthread_mutex_destroy(&g_li_par_pool.mutex);
  pthread_cond_destroy(&g_li_par_pool.work_cv);
  pthread_cond_destroy(&g_li_par_pool.done_cv);
  pthread_cond_destroy(&g_li_par_pool.ready_cv);
#endif
  g_li_par_pool.initialized = 0;
  g_li_par_pool.team_size = 0;
}

static int li_warn_omp_alias_once(void) {
  static int warned = 0;
  if (!warned) {
    fprintf(stderr,
            "lic: warning: li_omp_parallel_for_i64 is deprecated; use li_parallel_for_i64 "
            "(native pthread pool)\n");
    warned = 1;
  }
  return 0;
}

void li_parallel_for_i64(long long start, long long end, void (*body)(long long), int team_size) {
  li_par_pool_fork_join(start, end, body, li_par_clamp_team(team_size, end - start));
}

void li_omp_parallel_for_i64(long long start, long long end, void (*body)(long long)) {
  (void)li_warn_omp_alias_once();
  li_parallel_for_i64(start, end, body, 0);
}
