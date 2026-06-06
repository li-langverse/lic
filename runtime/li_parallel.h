#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LI_MAX_THREADS 64

typedef enum {
  LI_PAR_SCHED_STATIC = 0,
  LI_PAR_SCHED_DYNAMIC = 1,
  LI_PAR_SCHED_GUIDED = 2,
} LiParScheduleKind;

void li_parallel_for_i64(long long start, long long end, void (*body)(long long), int team_size);

/* Persistent thread pool (WP-PAR-10). */
void li_par_pool_set_team_size(int team_size);
int li_par_pool_team_size(void);
void li_par_pool_set_schedule(LiParScheduleKind schedule);
LiParScheduleKind li_par_pool_schedule(void);
void li_par_pool_set_chunk_size(long long chunk_size);
long long li_par_pool_chunk_size(void);
void li_par_pool_fork_join(long long start, long long end, void (*body)(long long), int team_size);
void li_par_pool_shutdown(void);

/* Tree reductions (WP-PAR-13). */
double li_par_reduce_sum_f64(const double* data, long long n, int team_size);
double li_par_reduce_min_f64(const double* data, long long n, int team_size);
double li_par_reduce_max_f64(const double* data, long long n, int team_size);
long long li_par_reduce_sum_i64(const long long* data, long long n, int team_size);

#ifdef __cplusplus
}
#endif
