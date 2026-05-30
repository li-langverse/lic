#include "num_gmres_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 48, KRYLOV = 12, OUTER = 20 };
static double g_checksum;
__attribute__((noinline)) void li_num_gmres_kernel(void) {
  double x[N], b[N], r[N];
  for (int i = 0; i < N; ++i) {
    b[i] = (double)(i + 1);
    x[i] = 0.0;
    r[i] = b[i];
  }
  for (int outer = 0; outer < OUTER; ++outer) {
    double V[KRYLOV + 1][N];
    double H[KRYLOV + 1][KRYLOV];
    for (int i = 0; i < N; ++i) V[0][i] = r[i];
    double beta = 0.0;
    for (int i = 0; i < N; ++i) beta += V[0][i] * V[0][i];
    beta = sqrt(beta);
    for (int i = 0; i < N; ++i) V[0][i] /= beta;
    for (int j = 0; j < KRYLOV; ++j) {
      double w[N];
      for (int i = 0; i < N; ++i) {
        double sum = 0.0;
        for (int k = 0; k < N; ++k) {
          double aik = (i == k) ? (double)N + 1.0 : 0.005;
          sum += aik * V[j][k];
        }
        w[i] = sum;
      }
      for (int i = 0; i <= j; ++i) {
        H[i][j] = 0.0;
        for (int k = 0; k < N; ++k) H[i][j] += w[k] * V[i][k];
        for (int k = 0; k < N; ++k) w[k] -= H[i][j] * V[i][k];
      }
      double hn1 = 0.0;
      for (int k = 0; k < N; ++k) hn1 += w[k] * w[k];
      H[j + 1][j] = sqrt(hn1);
      for (int k = 0; k < N; ++k) V[j + 1][k] = w[k] / H[j + 1][j];
    }
    for (int i = 0; i < N; ++i) x[i] += 0.01 * V[0][i];
    for (int i = 0; i < N; ++i) {
      double sum = 0.0;
      for (int k = 0; k < N; ++k) {
        double aik = (i == k) ? (double)N + 1.0 : 0.005;
        sum += aik * x[k];
      }
      r[i] = b[i] - sum;
    }
  }
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += x[i];
  g_checksum = acc;
}

double li_num_gmres_checksum(void) { return g_checksum; }
