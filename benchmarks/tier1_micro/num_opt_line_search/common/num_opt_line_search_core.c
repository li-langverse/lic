#include "num_opt_line_search_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { REPS = 50000 };
static double g_checksum;
__attribute__((noinline)) void li_num_opt_line_search_kernel(void) {
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {
    double x = 2.0;
    for (int it = 0; it < 16; ++it) {
      const double f = (x - 1.0) * (x - 1.0) + 0.1;
      const double df = 2.0 * (x - 1.0);
      double alpha = 1.0;
      for (int ls = 0; ls < 8; ++ls) {
        const double x_try = x - alpha * df;
        const double f_try = (x_try - 1.0) * (x_try - 1.0) + 0.1;
        if (f_try < f) break;
        alpha *= 0.5;
      }
      x -= alpha * df;
    }
    acc += x;
  }
  g_checksum = acc;
}

double li_num_opt_line_search_checksum(void) { return g_checksum; }
