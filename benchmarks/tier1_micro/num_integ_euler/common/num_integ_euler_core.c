#include "num_integ_euler_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { STEPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void li_num_integ_euler_kernel(void) {
  const double dt = 1e-4;
  double y = 1.0, v = 0.0;
  for (int i = 0; i < STEPS; ++i) {
    const double a = -y;
    v += dt * a;
    y += dt * v;
  }
  g_checksum = y + v;
}

double li_num_integ_euler_checksum(void) { return g_checksum; }
