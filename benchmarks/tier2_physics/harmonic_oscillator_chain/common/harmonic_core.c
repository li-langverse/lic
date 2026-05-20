#include "harmonic_core.h"

#include "bench_quick.h"

#include <string.h>

enum { LI_HC_N_MAX = 64 };
#define LI_HC_N_FULL 64
#define LI_HC_N_QUICK 32
#define LI_HC_STEPS_FULL 2000000
#define LI_HC_STEPS_QUICK 50000
#define LI_HC_DT 0.001
#define LI_HC_K 1.0
#define LI_HC_MASS 1.0
#define LI_HC_SPACING 1.0

typedef struct LiHcState {
  double x[LI_HC_N_MAX];
  double v[LI_HC_N_MAX];
  double f[LI_HC_N_MAX];
} LiHcState;

static double g_li_harmonic_checksum;

static void li_hc_init(LiHcState* s, int n) {
  for (int i = 0; i < n; ++i) {
    s->x[i] = (double)i * LI_HC_SPACING;
    s->v[i] = 0.0;
  }
  s->x[n / 2] += 0.1;
}

static void li_hc_forces(const LiHcState* s, LiHcState* out, int n) {
  memset(out->f, 0, sizeof(out->f));
  for (int i = 0; i < n - 1; ++i) {
    const double stretch = s->x[i + 1] - s->x[i] - LI_HC_SPACING;
    const double force = LI_HC_K * stretch;
    out->f[i] += force;
    out->f[i + 1] -= force;
  }
  out->f[0] = 0.0;
  out->f[n - 1] = 0.0;
}

static double li_hc_energy(const LiHcState* s, int n) {
  double ke = 0.0;
  double pe = 0.0;
  for (int i = 0; i < n; ++i) {
    ke += 0.5 * LI_HC_MASS * s->v[i] * s->v[i];
  }
  for (int i = 0; i < n - 1; ++i) {
    const double stretch = s->x[i + 1] - s->x[i] - LI_HC_SPACING;
    pe += 0.5 * LI_HC_K * stretch * stretch;
  }
  return ke + pe;
}

__attribute__((noinline)) void li_harmonic_chain_kernel(void) {
  const int n = li_bench_pick_int(LI_HC_N_QUICK, LI_HC_N_FULL);
  const int steps = li_bench_pick_int(LI_HC_STEPS_QUICK, LI_HC_STEPS_FULL);
  LiHcState s, f;
  li_hc_init(&s, n);
  li_hc_forces(&s, &f, n);
  for (int step = 0; step < steps; ++step) {
    for (int i = 0; i < n; ++i) {
      s.v[i] += 0.5 * LI_HC_DT * f.f[i] / LI_HC_MASS;
    }
    for (int i = 0; i < n; ++i) {
      s.x[i] += LI_HC_DT * s.v[i];
    }
    s.x[0] = 0.0;
    s.x[n - 1] = (double)(n - 1) * LI_HC_SPACING;
    s.v[0] = 0.0;
    s.v[n - 1] = 0.0;
    li_hc_forces(&s, &f, n);
    for (int i = 0; i < n; ++i) {
      s.v[i] += 0.5 * LI_HC_DT * f.f[i] / LI_HC_MASS;
    }
    (void)step;
  }
  g_li_harmonic_checksum = li_hc_energy(&s, n);
}

double li_harmonic_chain_checksum(void) { return g_li_harmonic_checksum; }
