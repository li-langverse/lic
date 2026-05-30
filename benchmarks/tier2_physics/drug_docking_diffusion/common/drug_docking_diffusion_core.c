#include "drug_docking_diffusion_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { STEPS = 20000, DIM = 16 };
static double g_checksum;
__attribute__((noinline)) void li_drug_docking_diffusion_kernel(void) {
  double x[DIM];
  for (int i = 0; i < DIM; ++i) x[i] = 0.01 * (double)i;
  uint32_t seed = 0x12345678u;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {
    seed = seed * 1664525u + 1013904223u;
    const double noise = ((double)(seed & 0xffff) / 32768.0) - 1.0;
    x[s % DIM] += 0.02 * noise;
    double n2 = 0.0;
    for (int i = 0; i < DIM; ++i) n2 += x[i] * x[i];
    acc += n2;
  }
  g_checksum = acc;
}

double li_drug_docking_diffusion_checksum(void) { return g_checksum; }
