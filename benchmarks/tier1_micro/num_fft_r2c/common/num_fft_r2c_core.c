#include "num_fft_r2c_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 512 };
static double g_checksum;
__attribute__((noinline)) void li_num_fft_r2c_kernel(void) {
  double re[N], im[N], out_re[N];
  for (int k = 0; k < N; ++k) {
    re[k] = sin(0.013 * (double)k);
    im[k] = 0.0;
  }
  for (int rep = 0; rep < 4; ++rep) {
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

double li_num_fft_r2c_checksum(void) { return g_checksum; }
