#include "num_sparse_mv_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 256, NNZ_ROW = 7 };
static double g_checksum;
__attribute__((noinline)) void li_num_sparse_mv_kernel(void) {
  double x[N], y[N];
  int col[NNZ_ROW];
  double val[NNZ_ROW];
  for (int j = 0; j < NNZ_ROW; ++j) {
    col[j] = (j * 37) % N;
    val[j] = 0.01 * (double)(j + 1);
  }
  for (int i = 0; i < N; ++i) x[i] = (double)(i % 17) * 0.001;
  for (int rep = 0; rep < 8000; ++rep) {
    for (int i = 0; i < N; ++i) {
      double sum = 0.0;
      for (int k = 0; k < NNZ_ROW; ++k) {
        const int c = (i + col[k]) % N;
        sum += val[k] * x[c];
      }
      y[i] = sum;
    }
    for (int i = 0; i < N; ++i) x[i] = y[i];
  }
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += x[i];
  g_checksum = acc;
}

double li_num_sparse_mv_checksum(void) { return g_checksum; }
