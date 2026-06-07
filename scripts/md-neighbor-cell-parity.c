/*
 * md-neighbor-cell-parity.c — Phase A gate for algo 105 (md_neighbor_cell_list).
 *
 * At N=256, LJ reduced units (box=10, rc=2.5), verify max |F_cell - F_brute| < 1e-10
 * and relative PE parity < 1e-12 on FCC lattice init.
 *
 * Build: cc -O2 -std=c11 -o md-neighbor-cell-parity scripts/md-neighbor-cell-parity.c -lm
 * Run:   ./scripts/md-neighbor-cell-parity   (exit 0 = pass)
 */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

enum {
  MD_N = 256,
  MD_RC = 25,       /* rc * 10 for integer-free compare scaling */
  MD_BOX = 100,     /* box * 10 */
  MD_SEED = 7
};

#define MD_RC_F 2.5
#define MD_BOX_F 10.0

typedef struct {
  double px[MD_N], py[MD_N], pz[MD_N];
  double fx[MD_N], fy[MD_N], fz[MD_N];
} MdState;

static double md_mic(double d) {
  const double half = 0.5 * MD_BOX_F;
  if (d > half) return d - MD_BOX_F;
  if (d < -half) return d + MD_BOX_F;
  return d;
}

static int md_ncell(void) {
  return (int)floor(MD_BOX_F / MD_RC_F);
}

static void md_cell_index(const MdState* s, int i, int ncell, int* ix, int* iy, int* iz) {
  const double h = MD_BOX_F / (double)ncell;
  *ix = (int)floor(s->px[i] / h);
  *iy = (int)floor(s->py[i] / h);
  *iz = (int)floor(s->pz[i] / h);
  if (*ix < 0) *ix = 0;
  if (*iy < 0) *iy = 0;
  if (*iz < 0) *iz = 0;
  if (*ix >= ncell) *ix = ncell - 1;
  if (*iy >= ncell) *iy = ncell - 1;
  if (*iz >= ncell) *iz = ncell - 1;
}

static int md_cell_flat(int ix, int iy, int iz, int ncell) {
  return ix + ncell * (iy + ncell * iz);
}

static void md_lj_pair(const MdState* s, int i, int j, double rc2,
                       double* fx_i, double* fy_i, double* fz_i,
                       double* fx_j, double* fy_j, double* fz_j, double* pe) {
  const double dx = md_mic(s->px[j] - s->px[i]);
  const double dy = md_mic(s->py[j] - s->py[i]);
  const double dz = md_mic(s->pz[j] - s->pz[i]);
  const double r2 = dx * dx + dy * dy + dz * dz;
  if (r2 >= rc2 || r2 < 1e-12) return;
  const double inv_r2 = 1.0 / r2;
  const double inv_r6 = inv_r2 * inv_r2 * inv_r2;
  const double inv_r12 = inv_r6 * inv_r6;
  const double f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6;
  const double fx = f_scalar * dx;
  const double fy = f_scalar * dy;
  const double fz = f_scalar * dz;
  *fx_i -= fx;
  *fy_i -= fy;
  *fz_i -= fz;
  *fx_j += fx;
  *fy_j += fy;
  *fz_j += fz;
  *pe += 4.0 * (inv_r12 - inv_r6);
}

static void md_init_fcc(MdState* s) {
  static const double basis[4][3] = {
      {0, 0, 0}, {0, 0.5, 0.5}, {0.5, 0, 0.5}, {0.5, 0.5, 0}};
  int nc = 1;
  while (4 * nc * nc * nc < MD_N) nc++;
  const double a = MD_BOX_F / (double)nc;
  int idx = 0;
  for (int ix = 0; ix < nc && idx < MD_N; ix++)
    for (int iy = 0; iy < nc && idx < MD_N; iy++)
      for (int iz = 0; iz < nc && idx < MD_N; iz++)
        for (int b = 0; b < 4 && idx < MD_N; b++, idx++) {
          s->px[idx] = ((double)ix + basis[b][0]) * a;
          s->py[idx] = ((double)iy + basis[b][1]) * a;
          s->pz[idx] = ((double)iz + basis[b][2]) * a;
        }
}

static void md_forces_brute(MdState* s, double* pe_out) {
  const double rc2 = MD_RC_F * MD_RC_F;
  memset(s->fx, 0, sizeof(s->fx));
  memset(s->fy, 0, sizeof(s->fy));
  memset(s->fz, 0, sizeof(s->fz));
  double pe = 0.0;
  for (int i = 0; i < MD_N; i++) {
    for (int j = i + 1; j < MD_N; j++) {
      md_lj_pair(s, i, j, rc2, &s->fx[i], &s->fy[i], &s->fz[i],
                 &s->fx[j], &s->fy[j], &s->fz[j], &pe);
    }
  }
  *pe_out = pe;
}

static void md_forces_cell(MdState* s, double* pe_out) {
  const int ncell = md_ncell();
  const int ncells = ncell * ncell * ncell;
  const double rc2 = MD_RC_F * MD_RC_F;

  int* head = (int*)calloc((size_t)ncells, sizeof(int));
  int* next = (int*)malloc((size_t)MD_N * sizeof(int));
  int* cell_x = (int*)malloc((size_t)MD_N * sizeof(int));
  int* cell_y = (int*)malloc((size_t)MD_N * sizeof(int));
  int* cell_z = (int*)malloc((size_t)MD_N * sizeof(int));
  if (!head || !next || !cell_x || !cell_y || !cell_z) {
    fprintf(stderr, "md-neighbor-cell-parity: alloc failed\n");
    exit(2);
  }
  for (int c = 0; c < ncells; c++) head[c] = -1;

  for (int i = 0; i < MD_N; i++) {
    md_cell_index(s, i, ncell, &cell_x[i], &cell_y[i], &cell_z[i]);
    const int cid = md_cell_flat(cell_x[i], cell_y[i], cell_z[i], ncell);
    next[i] = head[cid];
    head[cid] = i;
  }

  memset(s->fx, 0, sizeof(s->fx));
  memset(s->fy, 0, sizeof(s->fy));
  memset(s->fz, 0, sizeof(s->fz));
  double pe = 0.0;

  for (int iz = 0; iz < ncell; iz++) {
    for (int iy = 0; iy < ncell; iy++) {
      for (int ix = 0; ix < ncell; ix++) {
        const int cid_a = md_cell_flat(ix, iy, iz, ncell);
        for (int dz = -1; dz <= 1; dz++) {
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              int nx = ix + dx;
              int ny = iy + dy;
              int nz = iz + dz;
              nx = (nx % ncell + ncell) % ncell;
              ny = (ny % ncell + ncell) % ncell;
              nz = (nz % ncell + ncell) % ncell;
              /* half-shell: only pairs with cid_b >= cid_a lex order */
              if (dz < 0) continue;
              if (dz == 0 && dy < 0) continue;
              if (dz == 0 && dy == 0 && dx < 0) continue;
              const int cid_b = md_cell_flat(nx, ny, nz, ncell);
              for (int i = head[cid_a]; i >= 0; i = next[i]) {
                for (int j = head[cid_b]; j >= 0; j = next[j]) {
                  if (cid_a == cid_b && j <= i) continue;
                  md_lj_pair(s, i, j, rc2, &s->fx[i], &s->fy[i], &s->fz[i],
                             &s->fx[j], &s->fy[j], &s->fz[j], &pe);
                }
              }
            }
          }
        }
      }
    }
  }

  free(head);
  free(next);
  free(cell_x);
  free(cell_y);
  free(cell_z);
  *pe_out = pe;
}

static double md_max_force_diff(const MdState* a, const MdState* b) {
  double max_d = 0.0;
  for (int i = 0; i < MD_N; i++) {
    double dx = fabs(a->fx[i] - b->fx[i]);
    double dy = fabs(a->fy[i] - b->fy[i]);
    double dz = fabs(a->fz[i] - b->fz[i]);
    if (dx > max_d) max_d = dx;
    if (dy > max_d) max_d = dy;
    if (dz > max_d) max_d = dz;
  }
  return max_d;
}

int main(void) {
  MdState brute, cell;
  md_init_fcc(&brute);
  memcpy(&cell, &brute, sizeof(MdState));

  double pe_brute = 0.0, pe_cell = 0.0;
  md_forces_brute(&brute, &pe_brute);
  md_forces_cell(&cell, &pe_cell);

  const double max_f = md_max_force_diff(&brute, &cell);
  const double pe_denom = fabs(pe_brute) > 1e-20 ? fabs(pe_brute) : 1.0;
  const double pe_rel = fabs(pe_brute - pe_cell) / pe_denom;

  printf("md-neighbor-cell-parity: N=%d ncell=%d max|dF|=%.3e pe_rel=%.3e\n",
         MD_N, md_ncell(), max_f, pe_rel);

  if (max_f > 1e-10) {
    fprintf(stderr, "FAIL: max force diff %.3e > 1e-10\n", max_f);
    return 1;
  }
  if (pe_rel > 1e-12) {
    fprintf(stderr, "FAIL: PE rel diff %.3e > 1e-12\n", pe_rel);
    return 1;
  }
  printf("PASS: brute/cell parity @ N=%d\n", MD_N);
  return 0;
}
