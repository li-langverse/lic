#include "am_infill_gyroid_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { SAMPLES = 60000 };
static double g_checksum;
__attribute__((noinline)) void li_am_infill_gyroid_kernel(void) {
  double acc = 0.0;
  for (int i = 0; i < SAMPLES; ++i) {
    const double x = 0.02 * (double)(i % 100);
    const double y = 0.02 * (double)((i / 100) % 100);
    const double z = 0.02 * (double)(i / 10000);
    acc += sin(x) * cos(y) + sin(y) * cos(z) + sin(z) * cos(x);
  }
  g_checksum = acc;
}

double li_am_infill_gyroid_checksum(void) { return g_checksum; }
