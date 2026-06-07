// Shared Lennard-Jones MD kernel — cell-linked list, stack SoA arrays.
#pragma once

#include <math.h>
#include <stdint.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

enum {
  LI_MD_N = 256,
  LI_MD_STEPS = 10000,
  LI_MD_TRACE_INTERVAL = 25,
};
#define LI_MD_DT 0.004
#define LI_MD_RC 2.5
#define LI_MD_BOX 10.0
#define LI_MD_RHO ((double)LI_MD_N / (LI_MD_BOX * LI_MD_BOX * LI_MD_BOX))
#define LI_MD_TEMP 1.0
#define LI_MD_SEED UINT64_C(7)

typedef struct LiMdRng {
  uint64_t state;
} LiMdRng;

typedef struct LiMdState {
  double px[LI_MD_N];
  double py[LI_MD_N];
  double pz[LI_MD_N];
  double vx[LI_MD_N];
  double vy[LI_MD_N];
  double vz[LI_MD_N];
  double fx[LI_MD_N];
  double fy[LI_MD_N];
  double fz[LI_MD_N];
} LiMdState;

static inline void li_md_rng_init(LiMdRng* rng, uint64_t seed) { rng->state = seed; }

static inline double li_md_rng_next(LiMdRng* rng) {
  rng->state = rng->state * UINT64_C(6364136223846793005) + UINT64_C(1);
  return (double)(rng->state >> 11) / (double)(1ULL << 53);
}

static inline double li_md_rng_normal(LiMdRng* rng) {
  double u1 = li_md_rng_next(rng);
  if (u1 < 1e-12) u1 = 1e-12;
  const double u2 = li_md_rng_next(rng);
  return sqrt(-2.0 * log(u1)) * cos(2.0 * 3.14159265358979323846 * u2);
}

/* Smallest integer k with 4*k^3 >= N (FCC sites per cubic cell). */
static inline int li_md_fcc_ncell(void) {
  int k = 1;
  while (4 * k * k * k < LI_MD_N) {
    ++k;
  }
  return k;
}

static inline void li_md_kinetic(const LiMdState* s, double* ke_out) {
  double ke = 0.0;
  for (int i = 0; i < LI_MD_N; ++i) {
    ke += 0.5 * (s->vx[i] * s->vx[i] + s->vy[i] * s->vy[i] + s->vz[i] * s->vz[i]);
  }
  *ke_out = ke;
}

static inline void li_md_init_velocities_mb(LiMdState* s, LiMdRng* rng, double temperature) {
  const double scale = sqrt(temperature);
  for (int i = 0; i < LI_MD_N; ++i) {
    s->vx[i] = scale * li_md_rng_normal(rng);
    s->vy[i] = scale * li_md_rng_normal(rng);
    s->vz[i] = scale * li_md_rng_normal(rng);
  }
  double px_sum = 0.0, py_sum = 0.0, pz_sum = 0.0;
  for (int i = 0; i < LI_MD_N; ++i) {
    px_sum += s->vx[i];
    py_sum += s->vy[i];
    pz_sum += s->vz[i];
  }
  const double inv_n = 1.0 / (double)LI_MD_N;
  for (int i = 0; i < LI_MD_N; ++i) {
    s->vx[i] -= px_sum * inv_n;
    s->vy[i] -= py_sum * inv_n;
    s->vz[i] -= pz_sum * inv_n;
  }
  double ke = 0.0;
  li_md_kinetic(s, &ke);
  const double target = 1.5 * (double)LI_MD_N * temperature;
  if (ke > 1e-20) {
    const double vel_scale = sqrt(target / ke);
    for (int i = 0; i < LI_MD_N; ++i) {
      s->vx[i] *= vel_scale;
      s->vy[i] *= vel_scale;
      s->vz[i] *= vel_scale;
    }
  }
}

/* FCC lattice: 4 sites per cell, uniform spacing a = L/ncell, fills N particles. */
static inline void li_md_init_fcc(LiMdState* s, LiMdRng* rng, double temperature) {
  static const double basis[4][3] = {
      {0.0, 0.0, 0.0}, {0.0, 0.5, 0.5}, {0.5, 0.0, 0.5}, {0.5, 0.5, 0.0}};
  const int ncell = li_md_fcc_ncell();
  const double a = LI_MD_BOX / (double)ncell;
  int idx = 0;
  for (int ix = 0; ix < ncell && idx < LI_MD_N; ++ix) {
    for (int iy = 0; iy < ncell && idx < LI_MD_N; ++iy) {
      for (int iz = 0; iz < ncell && idx < LI_MD_N; ++iz) {
        for (int b = 0; b < 4 && idx < LI_MD_N; ++b) {
          s->px[idx] = ((double)ix + basis[b][0]) * a;
          s->py[idx] = ((double)iy + basis[b][1]) * a;
          s->pz[idx] = ((double)iz + basis[b][2]) * a;
          ++idx;
        }
      }
    }
  }
  if (temperature <= 0.0) {
    for (int i = 0; i < LI_MD_N; ++i) {
      s->vx[i] = 0.0;
      s->vy[i] = 0.0;
      s->vz[i] = 0.0;
    }
  } else {
    li_md_init_velocities_mb(s, rng, temperature);
  }
}

static inline double li_md_mic(double d) {
  const double half = 0.5 * LI_MD_BOX;
  if (d > half) return d - LI_MD_BOX;
  if (d < -half) return d + LI_MD_BOX;
  return d;
}

static inline double li_md_wrap(double x) {
  x = fmod(x, LI_MD_BOX);
  if (x < 0.0) x += LI_MD_BOX;
  return x;
}

static inline void li_md_init_lattice(LiMdState* s, LiMdRng* rng) {
  li_md_init_fcc(s, rng, LI_MD_TEMP);
}

/* LI_MD_TEMP env override for trajectory export (reduced LJ units; labels are Kelvin-style). */
double li_md_temperature_from_env(void);

static inline void li_md_potential(const LiMdState* s, double* pe_out) {
  const double rc2 = LI_MD_RC * LI_MD_RC;
  double pe = 0.0;
  for (int i = 0; i < LI_MD_N; ++i) {
    for (int j = i + 1; j < LI_MD_N; ++j) {
      const double dx = li_md_mic(s->px[j] - s->px[i]);
      const double dy = li_md_mic(s->py[j] - s->py[i]);
      const double dz = li_md_mic(s->pz[j] - s->pz[i]);
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

enum { LI_MD_NCELL_MAX = 8 };

typedef struct LiMdCellList {
  int ncell;
  int cell_head[LI_MD_NCELL_MAX * LI_MD_NCELL_MAX * LI_MD_NCELL_MAX];
  int next[LI_MD_N];
} LiMdCellList;

static inline int li_md_cell_ncell(void) {
  int n = (int)(LI_MD_BOX / LI_MD_RC);
  if (n < 1) {
    n = 1;
  }
  if (n > LI_MD_NCELL_MAX) {
    n = LI_MD_NCELL_MAX;
  }
  return n;
}

static inline int li_md_cell_index(int cx, int cy, int cz, int ncell) {
  return cx + ncell * (cy + ncell * cz);
}

static inline void li_md_cell_coord(double x, int ncell, int* c_out) {
  const double cell_size = LI_MD_BOX / (double)ncell;
  int c = (int)(x / cell_size);
  if (c < 0) {
    c = 0;
  }
  if (c >= ncell) {
    c = ncell - 1;
  }
  *c_out = c;
}

static inline void li_md_neighbor_build(const LiMdState* s, LiMdCellList* cl) {
  cl->ncell = li_md_cell_ncell();
  const int ncells = cl->ncell * cl->ncell * cl->ncell;
  for (int c = 0; c < ncells; ++c) {
    cl->cell_head[c] = -1;
  }
  for (int i = 0; i < LI_MD_N; ++i) {
    int cx = 0;
    int cy = 0;
    int cz = 0;
    li_md_cell_coord(s->px[i], cl->ncell, &cx);
    li_md_cell_coord(s->py[i], cl->ncell, &cy);
    li_md_cell_coord(s->pz[i], cl->ncell, &cz);
    const int idx = li_md_cell_index(cx, cy, cz, cl->ncell);
    cl->next[i] = cl->cell_head[idx];
    cl->cell_head[idx] = i;
  }
}

static inline void li_md_apply_pair_force(LiMdState* s, int i, int j, double rc2) {
  const double dx = li_md_mic(s->px[j] - s->px[i]);
  const double dy = li_md_mic(s->py[j] - s->py[i]);
  const double dz = li_md_mic(s->pz[j] - s->pz[i]);
  const double r2 = dx * dx + dy * dy + dz * dz;
  if (r2 >= rc2 || r2 < 1e-12) {
    return;
  }
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

static inline void li_md_compute_forces_brute(LiMdState* s) {
  const double rc2 = LI_MD_RC * LI_MD_RC;
  memset(s->fx, 0, sizeof(s->fx));
  memset(s->fy, 0, sizeof(s->fy));
  memset(s->fz, 0, sizeof(s->fz));
  for (int i = 0; i < LI_MD_N; ++i) {
    for (int j = i + 1; j < LI_MD_N; ++j) {
      li_md_apply_pair_force(s, i, j, rc2);
    }
  }
}

static inline void li_md_compute_forces_cell(LiMdState* s, LiMdCellList* cl) {
  const double rc2 = LI_MD_RC * LI_MD_RC;
  li_md_neighbor_build(s, cl);
  memset(s->fx, 0, sizeof(s->fx));
  memset(s->fy, 0, sizeof(s->fy));
  memset(s->fz, 0, sizeof(s->fz));
  const int n = cl->ncell;
  for (int cz1 = 0; cz1 < n; ++cz1) {
    for (int cy1 = 0; cy1 < n; ++cy1) {
      for (int cx1 = 0; cx1 < n; ++cx1) {
        const int cell1 = li_md_cell_index(cx1, cy1, cz1, n);
        for (int cz2 = cz1; cz2 < n; ++cz2) {
          const int y_start = (cz2 == cz1) ? cy1 : 0;
          for (int cy2 = y_start; cy2 < n; ++cy2) {
            const int x_start = (cz2 == cz1 && cy2 == cy1) ? cx1 : 0;
            for (int cx2 = x_start; cx2 < n; ++cx2) {
              const int cell2 = li_md_cell_index(cx2, cy2, cz2, n);
              for (int i = cl->cell_head[cell1]; i >= 0; i = cl->next[i]) {
                int j = (cell1 == cell2) ? cl->next[i] : cl->cell_head[cell2];
                for (; j >= 0; j = cl->next[j]) {
                  li_md_apply_pair_force(s, i, j, rc2);
                }
              }
            }
          }
        }
      }
    }
  }
}

static inline double li_md_force_max_delta(const LiMdState* a, const LiMdState* b) {
  double max_d = 0.0;
  for (int i = 0; i < LI_MD_N; ++i) {
    const double dx = a->fx[i] - b->fx[i];
    const double dy = a->fy[i] - b->fy[i];
    const double dz = a->fz[i] - b->fz[i];
    const double d = sqrt(dx * dx + dy * dy + dz * dz);
    if (d > max_d) {
      max_d = d;
    }
  }
  return max_d;
}

static inline double li_md_force_parity_cell_vs_brute(LiMdState* s) {
  LiMdState brute;
  LiMdState cell;
  LiMdCellList cl;
  brute = *s;
  cell = *s;
  li_md_compute_forces_brute(&brute);
  li_md_compute_forces_cell(&cell, &cl);
  return li_md_force_max_delta(&brute, &cell);
}

#ifdef LI_MD_USE_CELL_LIST
static inline void li_md_compute_forces(LiMdState* s) {
  LiMdCellList cl;
  li_md_compute_forces_cell(s, &cl);
}
#else
static inline void li_md_compute_forces(LiMdState* s) { li_md_compute_forces_brute(s); }
#endif

static inline void li_md_step(LiMdState* s) {
  for (int i = 0; i < LI_MD_N; ++i) {
    s->vx[i] += 0.5 * LI_MD_DT * s->fx[i];
    s->vy[i] += 0.5 * LI_MD_DT * s->fy[i];
    s->vz[i] += 0.5 * LI_MD_DT * s->fz[i];
  }
  for (int i = 0; i < LI_MD_N; ++i) {
    s->px[i] = li_md_wrap(s->px[i] + LI_MD_DT * s->vx[i]);
    s->py[i] = li_md_wrap(s->py[i] + LI_MD_DT * s->vy[i]);
    s->pz[i] = li_md_wrap(s->pz[i] + LI_MD_DT * s->vz[i]);
  }
  li_md_compute_forces(s);
  for (int i = 0; i < LI_MD_N; ++i) {
    s->vx[i] += 0.5 * LI_MD_DT * s->fx[i];
    s->vy[i] += 0.5 * LI_MD_DT * s->fy[i];
    s->vz[i] += 0.5 * LI_MD_DT * s->fz[i];
  }
}

void li_md_lj_run(void);

void li_md_kernel(void);
double li_md_checksum(void);

/* Run MD and write energy trace CSV (step,pe,ke,etotal). Returns |ΔE|/E drift. */
double li_md_run_trace(const char* path);

/* Export particle positions for animation (text format). Returns 0 on success. */
int li_md_export_trajectory(const char* path, int stride, int max_steps);

#ifdef __cplusplus
}
#endif
