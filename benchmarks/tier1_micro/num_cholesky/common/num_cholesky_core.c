#include "num_cholesky_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 64 };
static double g_checksum;
__attribute__((noinline)) void li_num_cholesky_kernel(void) {
  double L[N][N];
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      L[i][j] = (i >= j) ? 0.01 * (double)((i + j) % 11 + 1) : 0.0;
    }
    L[i][i] += (double)N;
  }
  for (int rep = 0; rep < 8; ++rep) {
    for (int i = 0; i < N; ++i) {
      for (int j = 0; j <= i; ++j) {
        double sum = L[i][j];
        for (int k = 0; k < j; ++k) sum -= L[i][k] * L[j][k];
        if (i == j) {
          L[i][j] = sqrt(sum);
        } else {
          L[i][j] = sum / L[j][j];
        }
      }
    }
  }
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += L[i][i];
  g_checksum = acc;
}

double li_num_cholesky_checksum(void) { return g_checksum; }
