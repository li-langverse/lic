#include <math.h>

enum { LI_TDSE_N = 128, LI_TDSE_STEPS = 8000 };
#define LI_TDSE_DT 0.00005
#define LI_TDSE_DX 0.08
#define LI_TDSE_V0 8.0

static double g_li_tdse_checksum;

void li_schrodinger_1d_barrier_kernel(void) {
  double re[LI_TDSE_N];
  double im[LI_TDSE_N];
  double v[LI_TDSE_N];
  const int i0 = LI_TDSE_N / 3;
  const int i1 = (2 * LI_TDSE_N) / 3;
  for (int i = 0; i < LI_TDSE_N; ++i) {
    const double x = (double)(i - LI_TDSE_N / 2) * 0.12;
    re[i] = exp(-0.5 * x * x);
    im[i] = 0.0;
    v[i] = (i > i0 && i < i1) ? LI_TDSE_V0 : 0.0;
  }
  const double inv_dx2 = 1.0 / (LI_TDSE_DX * LI_TDSE_DX);
  for (int s = 0; s < LI_TDSE_STEPS; ++s) {
    for (int i = 1; i < LI_TDSE_N - 1; ++i) {
      const double lap_re = (re[i + 1] - 2.0 * re[i] + re[i - 1]) * inv_dx2;
      const double lap_im = (im[i + 1] - 2.0 * im[i] + im[i - 1]) * inv_dx2;
      re[i] += LI_TDSE_DT * (lap_re - v[i] * re[i]);
      im[i] += LI_TDSE_DT * (lap_im - v[i] * im[i]);
    }
  }
  double n2 = 0.0;
  for (int i = 0; i < LI_TDSE_N; ++i) {
    n2 += re[i] * re[i] + im[i] * im[i];
  }
  g_li_tdse_checksum = n2;
}

double li_schrodinger_1d_barrier_checksum(void) { return g_li_tdse_checksum; }
