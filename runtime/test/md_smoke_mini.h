/* Mini Lennard-Jones kernel for distributed weak-scaling smoke (WP-PAR-20/22). */
#pragma once

#include <math.h>
#include <stdint.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

enum {
  LI_MD_SMOKE_N = 64,
  LI_MD_SMOKE_STEPS = 200,
};
#define LI_MD_SMOKE_BOX 10.0
#define LI_MD_SMOKE_RC 2.5
#define LI_MD_SMOKE_DT 0.001
#define LI_MD_SMOKE_TEMP 1.0
#define LI_MD_SMOKE_SEED UINT64_C(7)

typedef struct LiMdSmokeRng {
  uint64_t state;
} LiMdSmokeRng;

typedef struct LiMdSmokeState {
  double px[LI_MD_SMOKE_N];
  double py[LI_MD_SMOKE_N];
  double pz[LI_MD_SMOKE_N];
  double vx[LI_MD_SMOKE_N];
  double vy[LI_MD_SMOKE_N];
  double vz[LI_MD_SMOKE_N];
  double fx[LI_MD_SMOKE_N];
  double fy[LI_MD_SMOKE_N];
  double fz[LI_MD_SMOKE_N];
} LiMdSmokeState;

static inline void li_md_smoke_rng_init(LiMdSmokeRng* rng, uint64_t seed) { rng->state = seed; }

static inline double li_md_smoke_rng_next(LiMdSmokeRng* rng) {
  rng->state = rng->state * UINT64_C(6364136223846793005) + UINT64_C(1);
  return (double)(rng->state >> 11) / (double)(1ULL << 53);
}

static inline double li_md_smoke_rng_normal(LiMdSmokeRng* rng) {
  double u1 = li_md_smoke_rng_next(rng);
  if (u1 < 1e-12) u1 = 1e-12;
  const double u2 = li_md_smoke_rng_next(rng);
  return sqrt(-2.0 * log(u1)) * cos(2.0 * 3.14159265358979323846 * u2);
}

static inline double li_md_smoke_mic(double d) {
  const double half = 0.5 * LI_MD_SMOKE_BOX;
  if (d > half) return d - LI_MD_SMOKE_BOX;
  if (d < -half) return d + LI_MD_SMOKE_BOX;
  return d;
}

static inline double li_md_smoke_wrap(double x) {
  x = fmod(x, LI_MD_SMOKE_BOX);
  if (x < 0.0) x += LI_MD_SMOKE_BOX;
  return x;
}

static inline void li_md_smoke_kinetic(const LiMdSmokeState* s, double* ke_out) {
  double ke = 0.0;
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    ke += 0.5 * (s->vx[i] * s->vx[i] + s->vy[i] * s->vy[i] + s->vz[i] * s->vz[i]);
  }
  *ke_out = ke;
}

static inline void li_md_smoke_init_fcc(LiMdSmokeState* s, LiMdSmokeRng* rng) {
  static const double basis[4][3] = {
      {0.0, 0.0, 0.0}, {0.0, 0.5, 0.5}, {0.5, 0.0, 0.5}, {0.5, 0.5, 0.0}};
  const int ncell = 4;
  const double a = LI_MD_SMOKE_BOX / (double)ncell;
  int idx = 0;
  for (int ix = 0; ix < ncell && idx < LI_MD_SMOKE_N; ++ix) {
    for (int iy = 0; iy < ncell && idx < LI_MD_SMOKE_N; ++iy) {
      for (int iz = 0; iz < ncell && idx < LI_MD_SMOKE_N; ++iz) {
        for (int b = 0; b < 4 && idx < LI_MD_SMOKE_N; ++b) {
          s->px[idx] = ((double)ix + basis[b][0]) * a;
          s->py[idx] = ((double)iy + basis[b][1]) * a;
          s->pz[idx] = ((double)iz + basis[b][2]) * a;
          ++idx;
        }
      }
    }
  }
  const double scale = sqrt(LI_MD_SMOKE_TEMP);
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    s->vx[i] = scale * li_md_smoke_rng_normal(rng);
    s->vy[i] = scale * li_md_smoke_rng_normal(rng);
    s->vz[i] = scale * li_md_smoke_rng_normal(rng);
  }
  double px_sum = 0.0, py_sum = 0.0, pz_sum = 0.0;
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    px_sum += s->vx[i];
    py_sum += s->vy[i];
    pz_sum += s->vz[i];
  }
  const double inv_n = 1.0 / (double)LI_MD_SMOKE_N;
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    s->vx[i] -= px_sum * inv_n;
    s->vy[i] -= py_sum * inv_n;
    s->vz[i] -= pz_sum * inv_n;
  }
  double ke = 0.0;
  li_md_smoke_kinetic(s, &ke);
  const double target = 1.5 * (double)LI_MD_SMOKE_N * LI_MD_SMOKE_TEMP;
  if (ke > 1e-20) {
    const double vel_scale = sqrt(target / ke);
    for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
      s->vx[i] *= vel_scale;
      s->vy[i] *= vel_scale;
      s->vz[i] *= vel_scale;
    }
  }
}

static inline void li_md_smoke_compute_forces(LiMdSmokeState* s) {
  const double rc2 = LI_MD_SMOKE_RC * LI_MD_SMOKE_RC;
  memset(s->fx, 0, sizeof(s->fx));
  memset(s->fy, 0, sizeof(s->fy));
  memset(s->fz, 0, sizeof(s->fz));
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    for (int j = i + 1; j < LI_MD_SMOKE_N; ++j) {
      const double dx = li_md_smoke_mic(s->px[j] - s->px[i]);
      const double dy = li_md_smoke_mic(s->py[j] - s->py[i]);
      const double dz = li_md_smoke_mic(s->pz[j] - s->pz[i]);
      const double r2 = dx * dx + dy * dy + dz * dz;
      if (r2 >= rc2 || r2 < 1e-12) continue;
      const double inv_r2 = 1.0 / r2;
      const double inv_r6 = inv_r2 * inv_r2 * inv_r2;
      const double inv_r12 = inv_r6 * inv_r6;
      const double f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6;
      const double fx = f_scalar * dx;
      const double fy = f_scalar * dy;
      const double fz = f_scalar * dz;
      s->fx[i] -= fx;
      s->fy[i] -= fy;
      s->fz[i] -= fz;
      s->fx[j] += fx;
      s->fy[j] += fy;
      s->fz[j] += fz;
    }
  }
}

static inline void li_md_smoke_potential(const LiMdSmokeState* s, double* pe_out) {
  const double rc2 = LI_MD_SMOKE_RC * LI_MD_SMOKE_RC;
  double pe = 0.0;
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    for (int j = i + 1; j < LI_MD_SMOKE_N; ++j) {
      const double dx = li_md_smoke_mic(s->px[j] - s->px[i]);
      const double dy = li_md_smoke_mic(s->py[j] - s->py[i]);
      const double dz = li_md_smoke_mic(s->pz[j] - s->pz[i]);
      const double r2 = dx * dx + dy * dy + dz * dz;
      if (r2 >= rc2 || r2 < 1e-12) continue;
      const double inv_r2 = 1.0 / r2;
      const double inv_r6 = inv_r2 * inv_r2 * inv_r2;
      const double inv_r12 = inv_r6 * inv_r6;
      pe += 4.0 * (inv_r12 - inv_r6);
    }
  }
  *pe_out = pe;
}

static inline void li_md_smoke_step(LiMdSmokeState* s) {
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    s->vx[i] += 0.5 * LI_MD_SMOKE_DT * s->fx[i];
    s->vy[i] += 0.5 * LI_MD_SMOKE_DT * s->fy[i];
    s->vz[i] += 0.5 * LI_MD_SMOKE_DT * s->fz[i];
  }
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    s->px[i] = li_md_smoke_wrap(s->px[i] + LI_MD_SMOKE_DT * s->vx[i]);
    s->py[i] = li_md_smoke_wrap(s->py[i] + LI_MD_SMOKE_DT * s->vy[i]);
    s->pz[i] = li_md_smoke_wrap(s->pz[i] + LI_MD_SMOKE_DT * s->vz[i]);
  }
  li_md_smoke_compute_forces(s);
  for (int i = 0; i < LI_MD_SMOKE_N; ++i) {
    s->vx[i] += 0.5 * LI_MD_SMOKE_DT * s->fx[i];
    s->vy[i] += 0.5 * LI_MD_SMOKE_DT * s->fy[i];
    s->vz[i] += 0.5 * LI_MD_SMOKE_DT * s->fz[i];
  }
}

#ifdef __cplusplus
}
#endif
