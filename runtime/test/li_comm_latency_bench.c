/* WP-PAR-74 — programmed cluster latency bench (barrier RTT proxy). */
#include "li_dpar.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

enum { ROUNDS = 20 };

static double now_sec(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

int main(void) {
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  double total = 0.0;

  for (int i = 0; i < ROUNDS; ++i) {
    const double t0 = now_sec();
    li_dpar_barrier();
    total += now_sec() - t0;
  }

  const double avg_ms = (total / (double)ROUNDS) * 1000.0;
  if (rank == 0) {
    printf("li_comm_latency_bench: ok (world=%d avg_barrier_ms=%.3f rounds=%d)\n", world, avg_ms,
           ROUNDS);
  }
  li_dpar_finalize();
  return 0;
}
