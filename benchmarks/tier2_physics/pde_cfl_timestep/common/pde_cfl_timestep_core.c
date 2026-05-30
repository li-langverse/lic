#include "pde_cfl_timestep_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { NX = 64, NY = 64, STEPS = 40000 };
#define CFL 0.45
#define DX 0.02
static double g_checksum;
__attribute__((noinline)) void li_pde_cfl_timestep_kernel(void) {
  double u[NX][NY], v[NX][NY];
  for (int i = 0; i < NX; ++i) {
    for (int j = 0; j < NY; ++j) {
      u[i][j] = 0.2 * sin(0.1 * (double)i) * cos(0.1 * (double)j);
      v[i][j] = 0.15 * cos(0.08 * (double)i) * sin(0.09 * (double)j);
    }
  }
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {
    double maxs = 1e-12;
    for (int i = 0; i < NX; ++i) {
      for (int j = 0; j < NY; ++j) {
        const double sp = sqrt(u[i][j] * u[i][j] + v[i][j] * v[i][j]);
        if (sp > maxs) maxs = sp;
      }
    }
    const double dt = CFL * DX / maxs;
    acc += dt;
    for (int i = 1; i < NX - 1; ++i) {
      for (int j = 1; j < NY - 1; ++j) {
        u[i][j] -= dt * 0.25 * (u[i][j] - u[i - 1][j]);
        v[i][j] -= dt * 0.25 * (v[i][j] - v[i][j - 1]);
      }
    }
    (void)s;
  }
  g_checksum = acc;
}

double li_pde_cfl_timestep_checksum(void) { return g_checksum; }
