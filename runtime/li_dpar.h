#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

int li_dpar_rank(void);
int li_dpar_world_size(void);
void li_dpar_barrier(void);

int li_dpar_init_from_env(void);
void li_dpar_finalize(void);

void li_dpar_bcast_f64(double* buf, long long count, int root);
double li_dpar_allreduce_sum_f64(double local, int root);
long long li_dpar_allreduce_sum_i64(long long local, int root);

long long li_dpar_block_partition_begin(long long global_n, int rank, int world);
long long li_dpar_block_partition_end(long long global_n, int rank, int world);

/** Block-partitioned loop body over [start, end); rank/world from env (WP-PAR-23). */
void li_distributed_for_i64(long long start, long long end, void (*body)(long long));

int li_dpar_peer_fd(int peer);

#ifdef __cplusplus
}
#endif
