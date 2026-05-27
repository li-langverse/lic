#include "num_opt_bfgs_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { REPS = 20000, DIM = 4 };
static double g_checksum;
__attribute__((noinline)) void li_num_opt_bfgs_kernel(void) {
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {
    double x[DIM] = {0.5, -1.0, 0.25, 0.75};
    for (int it = 0; it < 12; ++it) {
      double g[DIM];
      for (int i = 0; i < DIM; ++i) {
        double gi = 0.0;
        for (int j = 0; j < DIM; ++j) gi += 2.0 * x[j] * (j == i ? 1.0 : 0.1);
        g[i] = gi + 1.0;
      }
      double step = 0.01;
      for (int i = 0; i < DIM; ++i) x[i] -= step * g[i];
    }
    for (int i = 0; i < DIM; ++i) acc += x[i];
  }
  g_checksum = acc;
}

double li_num_opt_bfgs_checksum(void) { return g_checksum; }
