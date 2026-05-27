#include "am_plane_mesh_intersect_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { TRIS = 2000, PLANES = 200 };
static double g_checksum;
__attribute__((noinline)) void li_am_plane_mesh_intersect_kernel(void) {
  double acc = 0.0;
  for (int p = 0; p < PLANES; ++p) {
    const double z = 0.01 * (double)p;
    for (int t = 0; t < TRIS; ++t) {
      const double z0 = 0.001 * (double)(t % 50);
      const double z1 = 0.001 * (double)((t + 17) % 50);
      const double z2 = 0.001 * (double)((t + 31) % 50);
      const double zm = (z0 + z1 + z2) / 3.0;
      if ((z0 - z) * (z2 - z) <= 0.0) acc += zm;
    }
  }
  g_checksum = acc;
}

double li_am_plane_mesh_intersect_checksum(void) { return g_checksum; }
