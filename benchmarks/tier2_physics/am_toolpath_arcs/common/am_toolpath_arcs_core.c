#include "am_toolpath_arcs_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { ARCS = 12000 };
static double g_checksum;
__attribute__((noinline)) void li_am_toolpath_arcs_kernel(void) {
  double acc = 0.0;
  for (int a = 0; a < ARCS; ++a) {
    const double r = 0.1 + 0.001 * (double)(a % 100);
    const double th0 = 0.01 * (double)a;
    const double th1 = th0 + 0.2;
    acc += r * (th1 - th0) + 0.001 * sin(th0 + th1);
  }
  g_checksum = acc;
}

double li_am_toolpath_arcs_checksum(void) { return g_checksum; }
