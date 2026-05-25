#include "am_offset_perimeters_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { PTS = 2000, OFF = 0.02 };
static double g_checksum;
__attribute__((noinline)) void li_am_offset_perimeters_kernel(void) {
  double acc = 0.0;
  for (int i = 0; i < PTS; ++i) {
    const double a = 6.283185307179586 * (double)i / (double)PTS;
    const double nx = cos(a);
    const double ny = sin(a);
    acc += (cos(a + OFF) - nx) * (cos(a + OFF) - nx) + (sin(a + OFF) - ny) * (sin(a + OFF) - ny);
  }
  g_checksum = acc;
}

double li_am_offset_perimeters_checksum(void) { return g_checksum; }
