#include "am_support_tree_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { NODES = 5000 };
static double g_checksum;
__attribute__((noinline)) void li_am_support_tree_kernel(void) {
  double x[NODES], y[NODES];
  for (int i = 0; i < NODES; ++i) {
    x[i] = 0.01 * (double)(i % 70);
    y[i] = 0.01 * (double)((i * 3) % 70);
  }
  double acc = 0.0;
  for (int i = 1; i < NODES; ++i) {
    const int p = (i * 7) % i;
    const double dx = x[i] - x[p];
    const double dy = y[i] - y[p];
    acc += sqrt(dx * dx + dy * dy);
  }
  g_checksum = acc;
}

double li_am_support_tree_checksum(void) { return g_checksum; }
