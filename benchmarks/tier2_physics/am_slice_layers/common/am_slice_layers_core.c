#include "am_slice_layers_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { LAYERS = 400, SEGS = 64 };
static double g_checksum;
__attribute__((noinline)) void li_am_slice_layers_kernel(void) {
  double acc = 0.0;
  for (int L = 0; L < LAYERS; ++L) {
    const double z = 0.05 * (double)L;
    for (int s = 0; s < SEGS; ++s) {
      const double y0 = sin(0.2 * (double)s);
      const double y1 = sin(0.2 * (double)(s + 1));
      if (y0 <= z && y1 >= z) acc += 1.0;
    }
  }
  g_checksum = acc;
}

double li_am_slice_layers_checksum(void) { return g_checksum; }
