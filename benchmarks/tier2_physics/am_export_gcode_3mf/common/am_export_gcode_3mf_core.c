#include "am_export_gcode_3mf_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { MOVES = 25000 };
static double g_checksum;
__attribute__((noinline)) void li_am_export_gcode_3mf_kernel(void) {
  double x = 0.0, y = 0.0, e = 0.0;
  double acc = 0.0;
  for (int m = 0; m < MOVES; ++m) {
    const double nx = x + 0.01 * sin(0.1 * (double)m);
    const double ny = y + 0.01 * cos(0.1 * (double)m);
    const double de = sqrt((nx - x) * (nx - x) + (ny - y) * (ny - y));
    e += de;
    x = nx;
    y = ny;
    acc += e;
  }
  g_checksum = acc;
}

double li_am_export_gcode_3mf_checksum(void) { return g_checksum; }
