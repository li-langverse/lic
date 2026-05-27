#include "robo_traj_opt_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { KNOTS = 32, ITERS = 5000 };
static double g_checksum;
__attribute__((noinline)) void li_robo_traj_opt_kernel(void) {
  double t[KNOTS];
  for (int i = 0; i < KNOTS; ++i) t[i] = (double)i / (double)(KNOTS - 1);
  for (int it = 0; it < ITERS; ++it) {
    double cost = 0.0;
    for (int i = 1; i < KNOTS; ++i) {
      const double v = t[i] - t[i - 1];
      cost += v * v;
    }
    for (int i = 1; i < KNOTS - 1; ++i) {
      t[i] -= 0.001 * (2.0 * t[i] - t[i - 1] - t[i + 1]);
    }
    (void)cost;
  }
  g_checksum = t[KNOTS - 1];
}

double li_robo_traj_opt_checksum(void) { return g_checksum; }
