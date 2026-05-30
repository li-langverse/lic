#include "robo_ik_jacobian_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { DOF = 6, SAMPLES = 20000 };
static double g_checksum;
__attribute__((noinline)) void li_robo_ik_jacobian_kernel(void) {
  double q[DOF];
  for (int i = 0; i < DOF; ++i) q[i] = 0.1 * (double)i;
  double acc = 0.0;
  for (int s = 0; s < SAMPLES; ++s) {
    double px = 0.0, py = 0.0;
    double c = 1.0;
    for (int i = 0; i < DOF; ++i) {
      const double l = 0.25;
      const double cq = cos(q[i]);
      const double sq = sin(q[i]);
      px += c * l * cq;
      py += c * l * sq;
      c *= cq;
    }
    const double eps = 1e-4;
    for (int j = 0; j < DOF; ++j) {
      double qj = q[j] + eps;
      double px2 = 0.0, py2 = 0.0;
      double c2 = 1.0;
      for (int i = 0; i < DOF; ++i) {
        const double ang = (i == j) ? qj : q[i];
        const double l = 0.25;
        px2 += c2 * l * cos(ang);
        py2 += c2 * l * sin(ang);
        c2 *= cos(ang);
      }
      acc += (px2 - px) / eps + (py2 - py) / eps;
    }
    q[s % DOF] += 1e-3 * sin(0.01 * (double)s);
  }
  g_checksum = acc;
}

double li_robo_ik_jacobian_checksum(void) { return g_checksum; }
