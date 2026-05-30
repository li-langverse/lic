#include "am_infill_grid_lines_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { LINES = 8000 };
static double g_checksum;
__attribute__((noinline)) void li_am_infill_grid_lines_kernel(void) {
  double acc = 0.0;
  for (int i = 0; i < LINES; ++i) {
    const double t = (double)i / (double)LINES;
    acc += sin(40.0 * t) * cos(30.0 * t);
  }
  g_checksum = acc;
}

double li_am_infill_grid_lines_checksum(void) { return g_checksum; }
