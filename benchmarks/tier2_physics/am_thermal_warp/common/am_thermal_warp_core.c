#include "am_thermal_warp_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { VOX = 48, STEPS = 3000 };
static double g_checksum;
__attribute__((noinline)) void li_am_thermal_warp_kernel(void) {
  double t[VOX][VOX][VOX];
  for (int i = 0; i < VOX; ++i) {
    for (int j = 0; j < VOX; ++j) {
      for (int k = 0; k < VOX; ++k) t[i][j][k] = 20.0;
    }
  }
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {
    for (int i = 1; i < VOX - 1; ++i) {
      for (int j = 1; j < VOX - 1; ++j) {
        for (int k = 1; k < VOX - 1; ++k) {
          const double lap = t[i + 1][j][k] + t[i - 1][j][k] + t[i][j + 1][k] + t[i][j - 1][k]
                             + t[i][j][k + 1] + t[i][j][k - 1] - 6.0 * t[i][j][k];
          t[i][j][k] += 0.02 * lap;
          acc += t[i][j][k];
        }
      }
    }
  }
  g_checksum = acc;
}

double li_am_thermal_warp_checksum(void) { return g_checksum; }
