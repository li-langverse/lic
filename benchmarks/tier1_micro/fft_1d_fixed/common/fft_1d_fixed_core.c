#include "fft_1d_fixed_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 1024 };
static double g_checksum;
__attribute__((noinline)) void li_fft_1d_fixed_kernel(void) {
  double re[N], out_re[N];
  for (int n = 0; n < N; ++n) re[n] = cos(0.007 * (double)n) + 0.25 * sin(0.019 * (double)n);
  for (int rep = 0; rep < 2; ++rep) {
    for (int k = 0; k < N; ++k) {
      double sum = 0.0;
      for (int n = 0; n < N; ++n) {
        const double ang = -2.0 * 3.141592653589793 * (double)k * (double)n / (double)N;
        sum += re[n] * cos(ang);
      }
      out_re[k] = sum;
    }
    for (int k = 0; k < N; ++k) re[k] = out_re[k];
  }
  double acc = 0.0;
  for (int k = 0; k < N; ++k) acc += re[k];
  g_checksum = acc;
}

double li_fft_1d_fixed_checksum(void) { return g_checksum; }
