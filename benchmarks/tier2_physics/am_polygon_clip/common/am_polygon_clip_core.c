#include "am_polygon_clip_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { VERT = 8, CLIPS = 25000 };
static double g_checksum;
__attribute__((noinline)) void li_am_polygon_clip_kernel(void) {
  double px[VERT], py[VERT];
  for (int i = 0; i < VERT; ++i) {
    const double a = 6.283185307179586 * (double)i / (double)VERT;
    px[i] = cos(a);
    py[i] = sin(a);
  }
  double acc = 0.0;
  for (int c = 0; c < CLIPS; ++c) {
    const double x = -0.5 + 0.02 * (double)(c % 50);
    int n = VERT;
    for (int i = 0, j = VERT - 1; i < VERT; j = i++) {
      const double cross = (x - px[i]) * (py[j] - py[i]) - (py[i] - py[j]) * (px[j] - px[i]);
      if (cross > 0.0) {
        px[n] = px[i];
        py[n] = py[i];
        ++n;
      }
    }
    acc += (double)n;
  }
  g_checksum = acc;
}

double li_am_polygon_clip_checksum(void) { return g_checksum; }
