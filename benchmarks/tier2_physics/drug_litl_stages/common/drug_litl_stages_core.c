#include "drug_litl_stages_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { STAGES = 8, MOLS = 256, STEPS = 4000 };
static double g_checksum;
__attribute__((noinline)) void li_drug_litl_stages_kernel(void) {
  double score[MOLS];
  for (int m = 0; m < MOLS; ++m) score[m] = 0.1 * (double)m;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {
    const int stage = s % STAGES;
    for (int m = 0; m < MOLS; ++m) {
      score[m] += 0.01 * sin((double)stage * score[m]);
      acc += score[m];
    }
  }
  g_checksum = acc;
}

double li_drug_litl_stages_checksum(void) { return g_checksum; }
