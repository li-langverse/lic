#include "sph_dam_core.h"

#include "bench_quick.h"

#include <math.h>
#include <string.h>

/* SPH v0: column IC, gravity, O(N^2) repulsion — density/pressure kernels TBD. */
enum { LI_SPH_N_MAX = 512 };
#define LI_SPH_N_FULL 512
#define LI_SPH_N_QUICK 48
#define LI_SPH_STEPS_FULL 10000
#define LI_SPH_STEPS_QUICK 3000
#define LI_SPH_BOX 1.0
#define LI_SPH_H 0.08
#define LI_SPH_MASS 1.0
#define LI_SPH_DT 0.00025
#define LI_SPH_G 9.81
#define LI_SPH_K 500.0

typedef struct LiSphParticle {
  double x[2];
  double v[2];
  double a[2];
} LiSphParticle;

typedef struct LiSphState {
  LiSphParticle p[LI_SPH_N_MAX];
} LiSphState;

static double g_li_sph_dam_checksum;

static void li_sph_init(LiSphState* s, int n) {
  int idx = 0;
  const int nx = 32;
  const int ny = 16;
  const double dx = 0.03;
  for (int j = 0; j < ny && idx < n; ++j) {
    for (int i = 0; i < nx && idx < n; ++i) {
      s->p[idx].x[0] = 0.05 + (double)i * dx;
      s->p[idx].x[1] = 0.05 + (double)j * dx;
      s->p[idx].v[0] = 0.0;
      s->p[idx].v[1] = 0.0;
      s->p[idx].a[0] = 0.0;
      s->p[idx].a[1] = -LI_SPH_G;
      ++idx;
    }
  }
  for (; idx < LI_SPH_N_MAX; ++idx) {
    memset(&s->p[idx], 0, sizeof(s->p[idx]));
  }
}

static double li_sph_sum_y(const LiSphState* s, int n) {
  double acc = 0.0;
  for (int i = 0; i < n; ++i) {
    acc += s->p[i].x[1];
  }
  return acc;
}

static void li_sph_forces(LiSphState* s, int n) {
  for (int i = 0; i < n; ++i) {
    s->p[i].a[0] = 0.0;
    s->p[i].a[1] = -LI_SPH_G;
  }
  for (int i = 0; i < n; ++i) {
    for (int j = i + 1; j < n; ++j) {
      const double rx = s->p[j].x[0] - s->p[i].x[0];
      const double ry = s->p[j].x[1] - s->p[i].x[1];
      const double r2 = rx * rx + ry * ry + 1e-12;
      const double r = sqrt(r2);
      if (r >= LI_SPH_H) {
        continue;
      }
      const double q = 1.0 - r / LI_SPH_H;
      const double f = LI_SPH_K * q * q / r;
      const double fx = f * rx;
      const double fy = f * ry;
      s->p[i].a[0] -= fx;
      s->p[i].a[1] -= fy;
      s->p[j].a[0] += fx;
      s->p[j].a[1] += fy;
    }
  }
  for (int i = 0; i < n; ++i) {
    if (s->p[i].x[0] < 0.0) {
      s->p[i].x[0] = 0.0;
      s->p[i].v[0] = 0.0;
    }
    if (s->p[i].x[0] > LI_SPH_BOX) {
      s->p[i].x[0] = LI_SPH_BOX;
      s->p[i].v[0] = 0.0;
    }
    if (s->p[i].x[1] < 0.0) {
      s->p[i].x[1] = 0.0;
      s->p[i].v[1] = 0.0;
    }
    if (s->p[i].x[1] > LI_SPH_BOX) {
      s->p[i].x[1] = LI_SPH_BOX;
      s->p[i].v[1] = 0.0;
    }
  }
}

__attribute__((noinline)) void li_sph_dam_2d_kernel(void) {
  const int n = li_bench_pick_int(LI_SPH_N_QUICK, LI_SPH_N_FULL);
  const int steps = li_bench_pick_int(LI_SPH_STEPS_QUICK, LI_SPH_STEPS_FULL);
  LiSphState s;
  li_sph_init(&s, n);
  for (int step = 0; step < steps; ++step) {
    li_sph_forces(&s, n);
    for (int i = 0; i < n; ++i) {
      s.p[i].v[0] += 0.5 * LI_SPH_DT * s.p[i].a[0];
      s.p[i].v[1] += 0.5 * LI_SPH_DT * s.p[i].a[1];
      s.p[i].x[0] += LI_SPH_DT * s.p[i].v[0];
      s.p[i].x[1] += LI_SPH_DT * s.p[i].v[1];
    }
    li_sph_forces(&s, n);
    for (int i = 0; i < n; ++i) {
      s.p[i].v[0] += 0.5 * LI_SPH_DT * s.p[i].a[0];
      s.p[i].v[1] += 0.5 * LI_SPH_DT * s.p[i].a[1];
    }
    (void)step;
  }
  g_li_sph_dam_checksum = li_sph_sum_y(&s, n);
}

double li_sph_dam_2d_checksum(void) { return g_li_sph_dam_checksum; }
