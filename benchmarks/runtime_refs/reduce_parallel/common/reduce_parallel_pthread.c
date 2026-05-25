#include "reduce_parallel_core.h"

#include <pthread.h>
#include <stdlib.h>

enum { LI_RED_PAR_N = 100000000 };

static double g_li_reduce_par_checksum;
static double* g_buf;

static void* fill_chunk(void* arg) {
  const int tid = *(int*)arg;
  const int nthreads = *(int*)((char*)arg + sizeof(int));
  const int chunk = (LI_RED_PAR_N + nthreads - 1) / nthreads;
  const int begin = tid * chunk;
  int end = begin + chunk;
  if (end > LI_RED_PAR_N) {
    end = LI_RED_PAR_N;
  }
  for (int i = begin; i < end; ++i) {
    g_buf[i] = (double)(i & 1023) * 1e-6;
  }
  return NULL;
}

static void* sum_chunk(void* arg) {
  const int tid = *(int*)arg;
  const int nthreads = *(int*)((char*)arg + sizeof(int));
  const int chunk = (LI_RED_PAR_N + nthreads - 1) / nthreads;
  const int begin = tid * chunk;
  int end = begin + chunk;
  if (end > LI_RED_PAR_N) {
    end = LI_RED_PAR_N;
  }
  double local = 0.0;
  for (int i = begin; i < end; ++i) {
    local += g_buf[i];
  }
  *(double*)((char*)arg + 2 * sizeof(int)) = local;
  return NULL;
}

__attribute__((noinline)) void li_reduce_parallel_kernel(unsigned threads) {
  const int nthreads = threads > 0 ? (int)threads : 1;
  g_buf = (double*)malloc((size_t)LI_RED_PAR_N * sizeof(double));
  if (!g_buf) {
    g_li_reduce_par_checksum = 0.0;
    return;
  }
  pthread_t* th = (pthread_t*)calloc((size_t)nthreads, sizeof(pthread_t));
  char* args = (char*)calloc((size_t)nthreads, 3 * sizeof(int) + sizeof(double));
  for (int t = 0; t < nthreads; ++t) {
    int* tid = (int*)(args + (size_t)t * (3 * sizeof(int) + sizeof(double)));
    tid[0] = t;
    tid[1] = nthreads;
    pthread_create(&th[t], NULL, fill_chunk, tid);
  }
  for (int t = 0; t < nthreads; ++t) {
    pthread_join(th[t], NULL);
  }
  double acc = 0.0;
  for (int t = 0; t < nthreads; ++t) {
    int* tid = (int*)(args + (size_t)t * (3 * sizeof(int) + sizeof(double)));
    tid[0] = t;
    tid[1] = nthreads;
    pthread_create(&th[t], NULL, sum_chunk, tid);
  }
  for (int t = 0; t < nthreads; ++t) {
    pthread_join(th[t], NULL);
    double* part = (double*)(args + (size_t)t * (3 * sizeof(int) + sizeof(double)) + 2 * sizeof(int));
    acc += *part;
  }
  g_li_reduce_par_checksum = acc;
  free(th);
  free(args);
  free(g_buf);
  g_buf = NULL;
}

double li_reduce_parallel_checksum(void) { return g_li_reduce_par_checksum; }
