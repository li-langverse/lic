#include "num_cg_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 64, ITERS = 120 };
static double g_checksum;
__attribute__((noinline)) void li_num_cg_kernel(void) {
  double x[N], b[N], r[N], p[N], Ap[N];
  for (int i = 0; i < N; ++i) {
    b[i] = (double)(i + 1);
    x[i] = 0.0;
    r[i] = b[i];
    p[i] = r[i];
  }
  double rsold = 0.0;
  for (int i = 0; i < N; ++i) rsold += r[i] * r[i];
  for (int it = 0; it < ITERS; ++it) {
    for (int i = 0; i < N; ++i) {
      double sum = 0.0;
      for (int j = 0; j < N; ++j) {
        const double aij = (i == j) ? (double)N + 4.0 : 0.001;
        sum += aij * p[j];
      }
      Ap[i] = sum;
    }
    double alpha_den = 0.0;
    for (int i = 0; i < N; ++i) alpha_den += p[i] * Ap[i];
    if (alpha_den <= 0.0) break;
    const double alpha = rsold / alpha_den;
    for (int i = 0; i < N; ++i) x[i] += alpha * p[i];
    double rsnew = 0.0;
    for (int i = 0; i < N; ++i) {
      r[i] -= alpha * Ap[i];
      rsnew += r[i] * r[i];
    }
    if (rsold <= 0.0) break;
    const double beta = rsnew / rsold;
    rsold = rsnew;
    for (int i = 0; i < N; ++i) p[i] = r[i] + beta * p[i];
  }
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += x[i];
  g_checksum = acc;
}

double li_num_cg_checksum(void) { return g_checksum; }
