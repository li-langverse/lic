#include "num_integ_rk4_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { STEPS = 200000 };
static double g_checksum;
__attribute__((noinline)) void li_num_integ_rk4_kernel(void) {
  const double dt = 2e-4;
  double y = 1.0, v = 0.0;
  for (int i = 0; i < STEPS; ++i) {
    const double k1y = v;
    const double k1v = -y;
    const double k2y = v + 0.5 * dt * k1v;
    const double k2v = -(y + 0.5 * dt * k1y);
    const double k3y = v + 0.5 * dt * k2v;
    const double k3v = -(y + 0.5 * dt * k2y);
    const double k4y = v + dt * k3v;
    const double k4v = -(y + dt * k3y);
    y += dt * (k1y + 2.0 * k2y + 2.0 * k3y + k4y) / 6.0;
    v += dt * (k1v + 2.0 * k2v + 2.0 * k3v + k4v) / 6.0;
  }
  g_checksum = y + v;
}

double li_num_integ_rk4_checksum(void) { return g_checksum; }
