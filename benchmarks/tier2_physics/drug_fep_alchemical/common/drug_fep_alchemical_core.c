#include "drug_fep_alchemical_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { LAMBDA_STEPS = 32, SAMPLES = 3000 };
static double g_checksum;
__attribute__((noinline)) void li_drug_fep_alchemical_kernel(void) {
  double acc = 0.0;
  for (int s = 0; s < SAMPLES; ++s) {
    for (int l = 0; l < LAMBDA_STEPS; ++l) {
      const double lam = (double)l / (double)(LAMBDA_STEPS - 1);
      double u = 0.0;
      for (int i = 0; i < 20; ++i) {
        const double ri = 0.1 * (double)i;
        u += (1.0 - lam) * exp(-ri) + lam * exp(-2.0 * ri);
      }
      acc += u;
    }
  }
  g_checksum = acc;
}

double li_drug_fep_alchemical_checksum(void) { return g_checksum; }
