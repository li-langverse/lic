#include "bio_rfdiffusion_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { STEPS = 4000, DIM = 32 };
static double g_checksum;
__attribute__((noinline)) void li_bio_rfdiffusion_kernel(void) {
  double x[DIM];
  for (int i = 0; i < DIM; ++i) x[i] = 0.0;
  uint32_t seed = 0xdeadbeefu;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {
    seed = seed * 1664525u + 1013904223u;
    const double z = ((double)(seed & 0xffff) / 32768.0) - 1.0;
    for (int i = 0; i < DIM; ++i) {
      x[i] = 0.98 * x[i] + 0.15 * z;
      acc += x[i] * x[i];
    }
  }
  g_checksum = acc;
}

double li_bio_rfdiffusion_checksum(void) { return g_checksum; }
