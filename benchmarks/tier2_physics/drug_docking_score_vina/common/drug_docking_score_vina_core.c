#include "drug_docking_score_vina_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { POSES = 5000, ATOMS = 24 };
static double g_checksum;
__attribute__((noinline)) void li_drug_docking_score_vina_kernel(void) {
  double lig[ATOMS][3];
  for (int a = 0; a < ATOMS; ++a) {
    lig[a][0] = 0.1 * (double)a;
    lig[a][1] = 0.05 * (double)a;
    lig[a][2] = 0.02 * (double)a;
  }
  double acc = 0.0;
  for (int p = 0; p < POSES; ++p) {
    double e = 0.0;
    for (int i = 0; i < ATOMS; ++i) {
      for (int j = i + 1; j < ATOMS; ++j) {
        double dx = lig[i][0] - lig[j][0];
        double dy = lig[i][1] - lig[j][1];
        double dz = lig[i][2] - lig[j][2];
        const double r2 = dx * dx + dy * dy + dz * dz + 1e-3;
        e += 1.0 / r2;
      }
    }
    acc += e;
    lig[p % ATOMS][0] += 1e-4;
  }
  g_checksum = acc;
}

double li_drug_docking_score_vina_checksum(void) { return g_checksum; }
