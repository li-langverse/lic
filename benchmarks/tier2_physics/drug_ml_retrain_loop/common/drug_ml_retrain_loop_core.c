#include "drug_ml_retrain_loop_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { FEAT = 64, BATCH = 128, EPOCHS = 800 };
static double g_checksum;
__attribute__((noinline)) void li_drug_ml_retrain_loop_kernel(void) {
  double w[FEAT];
  for (int i = 0; i < FEAT; ++i) w[i] = 0.001 * (double)i;
  double acc = 0.0;
  for (int e = 0; e < EPOCHS; ++e) {
    for (int b = 0; b < BATCH; ++b) {
      double x[FEAT];
      for (int i = 0; i < FEAT; ++i) x[i] = sin(0.1 * (double)(b + i + e));
      double y = 0.0;
      for (int i = 0; i < FEAT; ++i) y += w[i] * x[i];
      const double err = y - 1.0;
      for (int i = 0; i < FEAT; ++i) w[i] -= 1e-4 * err * x[i];
      acc += err * err;
    }
  }
  g_checksum = acc;
}

double li_drug_ml_retrain_loop_checksum(void) { return g_checksum; }
