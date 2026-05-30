#include "num_integ_symplectic_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { STEPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void li_num_integ_symplectic_kernel(void) {
  const double dt = 1e-4;
  double y = 1.0, v = 0.0;
  for (int i = 0; i < STEPS; ++i) {
    v += -y * dt;
    y += v * dt;
  }
  g_checksum = y + v;
}

double li_num_integ_symplectic_checksum(void) { return g_checksum; }
