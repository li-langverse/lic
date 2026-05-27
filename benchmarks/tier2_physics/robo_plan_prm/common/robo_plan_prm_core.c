#include "robo_plan_prm_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { GRID = 48, EDGES = 8000 };
static double g_checksum;
__attribute__((noinline)) void li_robo_plan_prm_kernel(void) {
  double occ[GRID][GRID];
  for (int i = 0; i < GRID; ++i) {
    for (int j = 0; j < GRID; ++j) {
      const double x = (double)i / (double)GRID;
      const double y = (double)j / (double)GRID;
      occ[i][j] = (x > 0.35 && x < 0.65 && y > 0.2 && y < 0.8) ? 1.0 : 0.0;
    }
  }
  double acc = 0.0;
  for (int e = 0; e < EDGES; ++e) {
    const int i = e % (GRID - 1);
    const int j = (e * 7) % (GRID - 1);
    if (occ[i][j] < 0.5 && occ[i + 1][j] < 0.5) acc += 1.0;
    if (occ[i][j] < 0.5 && occ[i][j + 1] < 0.5) acc += 1.0;
  }
  g_checksum = acc;
}

double li_robo_plan_prm_checksum(void) { return g_checksum; }
