#include "pde_heat_implicit_jacobi_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { NX = 64, NY = 64, STEPS = 12000, JACOBI = 6 };
#define ALPHA 0.25
#define DX 0.02
#define DT 0.001
static double g_checksum;
__attribute__((noinline)) void li_pde_heat_implicit_jacobi_kernel(void) {
  double u[NX][NY], b[NX][NY], x[NX][NY];
  const double r = ALPHA * DT / (DX * DX);
  for (int i = 0; i < NX; ++i) {
    for (int j = 0; j < NY; ++j) {
      u[i][j] = sin(0.2 * (double)i) * sin(0.2 * (double)j);
    }
  }
  for (int s = 0; s < STEPS; ++s) {
    for (int i = 0; i < NX; ++i) {
      for (int j = 0; j < NY; ++j) b[i][j] = u[i][j];
    }
    for (int j = 0; j < JACOBI; ++j) {
      for (int i = 1; i < NX - 1; ++i) {
        for (int k = 1; k < NY - 1; ++k) {
          x[i][k] = (b[i][k] + r * (u[i + 1][k] + u[i - 1][k] + u[i][k + 1] + u[i][k - 1]))
                    / (1.0 + 4.0 * r);
        }
      }
      for (int i = 0; i < NX; ++i) {
        for (int k = 0; k < NY; ++k) u[i][k] = x[i][k];
      }
    }
    (void)s;
  }
  double acc = 0.0;
  for (int i = 0; i < NX; ++i) {
    for (int j = 0; j < NY; ++j) acc += u[i][j];
  }
  g_checksum = acc;
}

double li_pde_heat_implicit_jacobi_checksum(void) { return g_checksum; }
