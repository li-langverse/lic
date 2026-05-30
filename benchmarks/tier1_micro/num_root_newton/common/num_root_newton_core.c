#include "num_root_newton_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { REPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void li_num_root_newton_kernel(void) {
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {
    double x = 1.0;
    for (int i = 0; i < 12; ++i) {
      const double fx = x * x - 2.0;
      const double dfx = 2.0 * x;
      x = x - fx / dfx;
    }
    acc += x;
  }
  g_checksum = acc;
}

double li_num_root_newton_checksum(void) { return g_checksum; }
