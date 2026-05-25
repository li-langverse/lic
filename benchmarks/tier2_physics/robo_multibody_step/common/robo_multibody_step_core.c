#include "robo_multibody_step_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { LINKS = 8, STEPS = 6000 };
#define DT 0.002
#define LEN 0.4
static double g_checksum;
__attribute__((noinline)) void li_robo_multibody_step_kernel(void) {
  double th[LINKS], w[LINKS];
  for (int i = 0; i < LINKS; ++i) {
    th[i] = 0.05 * (double)i;
    w[i] = 0.0;
  }
  for (int s = 0; s < STEPS; ++s) {
    double tau = 0.0;
    for (int i = LINKS - 1; i >= 0; --i) {
      tau += 2.0 * sin(th[i]) - 0.1 * w[i];
      w[i] += tau * DT;
      th[i] += w[i] * DT;
    }
    (void)s;
  }
  g_checksum = th[LINKS - 1];
}

double li_robo_multibody_step_checksum(void) { return g_checksum; }
