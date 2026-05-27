#include "robo_plan_rrt_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { NODES = 12000, DIM = 2 };
static double g_checksum;
__attribute__((noinline)) void li_robo_plan_rrt_kernel(void) {
  double x0[DIM] = {0.05, 0.05};
  const double goal[DIM] = {0.95, 0.95};
  double acc = 0.0;
  uint32_t seed = 0x9e3779b9u;
  for (int n = 0; n < NODES; ++n) {
    seed = seed * 1664525u + 1013904223u;
    double q[DIM];
    q[0] = (double)(seed & 0xffff) / 65535.0;
    q[1] = (double)((seed >> 16) & 0xffff) / 65535.0;
    const double dx = q[0] - x0[0];
    const double dy = q[1] - x0[1];
    const double dist = dx * dx + dy * dy;
    if (dist < 0.04) {
      x0[0] = q[0];
      x0[1] = q[1];
    }
    acc += dist;
  }
  const double gx = goal[0] - x0[0];
  const double gy = goal[1] - x0[1];
  g_checksum = acc + gx + gy;
}

double li_robo_plan_rrt_checksum(void) { return g_checksum; }
