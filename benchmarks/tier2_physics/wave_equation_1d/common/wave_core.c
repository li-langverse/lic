#include "wave_core.h"

#include "bench_quick.h"

#include <math.h>
#include <string.h>

enum { LI_WV_N_MAX = 8192 };
#define LI_WV_N_FULL 8192
#define LI_WV_N_QUICK 2048
#define LI_WV_STEPS_FULL 400000
#define LI_WV_STEPS_QUICK 20000
#define LI_WV_C 1.0
#define LI_WV_DX 0.01
#define LI_WV_DT 0.004
#define LI_WV_R (LI_WV_C * LI_WV_DT / LI_WV_DX)

typedef struct LiWvState {
  double u0[LI_WV_N_MAX];
  double u1[LI_WV_N_MAX];
  double u2[LI_WV_N_MAX];
} LiWvState;

static double g_li_wave_checksum;

static void li_wv_init(LiWvState* s, int n) {
  const double center = 0.5 * (double)(n - 1) * LI_WV_DX;
  const double width = 0.15;
  for (int i = 0; i < n; ++i) {
    const double x = (double)i * LI_WV_DX;
    const double d = (x - center) / width;
    s->u1[i] = exp(-d * d);
    s->u0[i] = s->u1[i];
    s->u2[i] = s->u1[i];
  }
  s->u0[0] = s->u0[n - 1] = 0.0;
  s->u1[0] = s->u1[n - 1] = 0.0;
}

static double li_wv_energy(const LiWvState* s, int n) {
  double e = 0.0;
  const double r2 = LI_WV_R * LI_WV_R;
  for (int i = 1; i < n - 1; ++i) {
    const double v = (s->u1[i] - s->u0[i]) / LI_WV_DT;
    const double du = (s->u1[i + 1] - s->u1[i - 1]) / (2.0 * LI_WV_DX);
    e += 0.5 * (v * v + LI_WV_C * LI_WV_C * du * du);
  }
  (void)r2;
  return e;
}

__attribute__((noinline)) void li_wave_1d_kernel(void) {
  const int n = li_bench_pick_int(LI_WV_N_QUICK, LI_WV_N_FULL);
  const int steps = li_bench_pick_int(LI_WV_STEPS_QUICK, LI_WV_STEPS_FULL);
  LiWvState s;
  li_wv_init(&s, n);
  const double r2 = LI_WV_R * LI_WV_R;
  for (int step = 0; step < steps; ++step) {
    for (int i = 1; i < n - 1; ++i) {
      s.u2[i] = 2.0 * s.u1[i] - s.u0[i] + r2 * (s.u1[i + 1] - 2.0 * s.u1[i] + s.u1[i - 1]);
    }
    s.u2[0] = 0.0;
    s.u2[n - 1] = 0.0;
    memcpy(s.u0, s.u1, (size_t)n * sizeof(s.u0[0]));
    memcpy(s.u1, s.u2, (size_t)n * sizeof(s.u1[0]));
    (void)step;
  }
  g_li_wave_checksum = li_wv_energy(&s, n);
}

double li_wave_1d_checksum(void) { return g_li_wave_checksum; }
