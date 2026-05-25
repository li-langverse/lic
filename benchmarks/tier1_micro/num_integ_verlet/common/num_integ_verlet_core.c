#include "num_integ_verlet_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { STEPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void li_num_integ_verlet_kernel(void) {
  const double dt = 1e-4;
  double y = 1.0, v = 0.0;
  double a = -y;
  for (int i = 0; i < STEPS; ++i) {
    y += dt * v + 0.5 * dt * dt * a;
    const double a_new = -y;
    v += 0.5 * dt * (a + a_new);
    a = a_new;
  }
  g_checksum = y + v;
}

double li_num_integ_verlet_checksum(void) { return g_checksum; }
