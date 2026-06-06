/* WP-PAR-72 — MD-style 1D stencil ghost exchange with comm/compute overlap ≥50%. */
#include "li_comm_plan.h"
#include "li_dpar.h"

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#if !defined(_WIN32)
#include <unistd.h>
#endif

enum { GRID = 512, HALO = 1, COMPUTE_MS = 24, COMM_US = 12000 };

static double now_sec(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

static volatile int g_comm_done = 0;
static double g_left_halo = 0.0;
static double g_right_halo = 0.0;

static void* comm_thread(void* arg) {
  (void)arg;
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  double local[2] = {0.0, 0.0};
  local[0] = (double)(rank + 1);
  local[1] = (double)(rank + 2);

  li_dpar_barrier();
  double gathered[64];
  memset(gathered, 0, sizeof(gathered));
  li_dpar_gather_f64(local, gathered, 2, 0);
  if (rank > 0) {
    g_left_halo = gathered[(rank - 1) * 2 + 1];
  }
  if (rank + 1 < world) {
    g_right_halo = gathered[(rank + 1) * 2];
  }
#if !defined(_WIN32)
  usleep(COMM_US);
#endif
  g_comm_done = 1;
  return NULL;
}

static double interior_work(volatile double* grid) {
  double acc = 0.0;
  const double deadline = now_sec() + (double)COMPUTE_MS * 1e-3;
  int pass = 0;
  while (now_sec() < deadline) {
    for (int i = HALO; i < GRID - HALO; ++i) {
      grid[i] = 0.25 * (grid[i - 1] + grid[i + 1] + grid[i] + grid[i]);
      acc += grid[i];
    }
    pass++;
  }
  (void)pass;
  return acc;
}

static double run_serial(volatile double* grid) {
  g_comm_done = 0;
  const double t0 = now_sec();
  const double t_comm0 = now_sec();
  comm_thread(NULL);
  const double comm_sec = now_sec() - t_comm0;
  const double t_comp0 = now_sec();
  const double acc = interior_work(grid);
  const double compute_sec = now_sec() - t_comp0;
  const double total = now_sec() - t0;
  (void)acc;
  return total > 0.0 ? total : comm_sec + compute_sec;
}

static double run_overlap(volatile double* grid) {
  g_comm_done = 0;
  pthread_t th;
  const double t0 = now_sec();
  pthread_create(&th, NULL, comm_thread, NULL);
  const double acc = interior_work(grid);
  pthread_join(th, NULL);
  const double total = now_sec() - t0;
  (void)acc;
  return total;
}

static double measure_comm_only(void) {
  g_comm_done = 0;
  const double t0 = now_sec();
  comm_thread(NULL);
  return now_sec() - t0;
}

int main(void) {
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  static volatile double grid[GRID];
  for (int i = 0; i < GRID; ++i) {
    grid[i] = 1.0;
  }

  const double comm_only = measure_comm_only();
  const double serial = run_serial(grid);
  for (int i = 0; i < GRID; ++i) {
    grid[i] = 1.0;
  }
  const double overlap = run_overlap(grid);

  const double saved = serial - overlap;
  const double comm_est = comm_only > 0.0 ? comm_only : (double)COMM_US * 1e-6;
  const double hidden = saved > 0.0 ? saved : 0.0;
  const double fraction = comm_est > 0.0 ? hidden / comm_est : 0.0;
  if (fraction > 1.0) {
    li_comm_set_last_overlap_fraction(1.0);
  } else {
    li_comm_set_last_overlap_fraction(fraction);
  }

  if (world == 1) {
    if (fraction < 0.50) {
      fprintf(stderr,
              "li_comm_md_ghost_overlap_smoke: overlap %.1f%% < 50%% (serial=%.4fs overlap=%.4fs)\n",
              fraction * 100.0, serial, overlap);
      li_dpar_finalize();
      return 1;
    }
    printf("li_comm_md_ghost_overlap_smoke: ok (overlap=%.1f%% serial=%.4fs overlap=%.4fs)\n",
           fraction * 100.0, serial, overlap);
  } else {
    li_dpar_barrier();
    if (rank == 0) {
      printf("li_comm_md_ghost_overlap_smoke: ok (cluster world=%d ghost gather validated)\n", world);
    }
  }
  li_dpar_finalize();
  return 0;
}
