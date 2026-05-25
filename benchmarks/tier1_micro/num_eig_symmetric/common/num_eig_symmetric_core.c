#include "num_eig_symmetric_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 32, STEPS = 200 };
static double g_checksum;
__attribute__((noinline)) void li_num_eig_symmetric_kernel(void) {
  double A[N][N], v[N], w[N];
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      A[i][j] = (i == j) ? (double)(N + i + 1) : 0.02 * (double)((i + j) % 7);
    }
    v[i] = 1.0 / (double)N;
  }
  double lambda = 0.0;
  for (int s = 0; s < STEPS; ++s) {
    for (int i = 0; i < N; ++i) {
      double sum = 0.0;
      for (int j = 0; j < N; ++j) sum += A[i][j] * v[j];
      w[i] = sum;
    }
    double norm = 0.0;
    for (int i = 0; i < N; ++i) norm += w[i] * w[i];
    norm = sqrt(norm);
    lambda = 0.0;
    for (int i = 0; i < N; ++i) {
      v[i] = w[i] / norm;
      lambda += v[i] * w[i];
    }
  }
  g_checksum = lambda;
}

double li_num_eig_symmetric_checksum(void) { return g_checksum; }
