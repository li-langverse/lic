#include <math.h>

/* v1: 2D scalar upwind advection (not full Euler equations — see BENCH_WORKLOADS.md). */
enum { LI_EF_NX = 64, LI_EF_NY = 64, LI_EF_STEPS = 8000 };
#define LI_EF_DT 0.001
#define LI_EF_DX 0.05
#define LI_EF_DY 0.05
#define LI_EF_C 0.5

static double g_li_euler_fluid_checksum;

void li_euler_fluid_2d_kernel(void) {
  double u[LI_EF_NX][LI_EF_NY];
  double un[LI_EF_NX][LI_EF_NY];
  for (int j = 0; j < LI_EF_NY; ++j) {
    for (int i = 0; i < LI_EF_NX; ++i) {
      u[i][j] = 0.5 + 0.5 * sin(0.2 * (double)i) * cos(0.15 * (double)j);
      un[i][j] = u[i][j];
    }
  }
  const double cx = LI_EF_C * LI_EF_DT / LI_EF_DX;
  const double cy = LI_EF_C * LI_EF_DT / LI_EF_DY;
  for (int s = 0; s < LI_EF_STEPS; ++s) {
    for (int j = 1; j < LI_EF_NY - 1; ++j) {
      for (int i = 1; i < LI_EF_NX - 1; ++i) {
        un[i][j] =
            u[i][j] - cx * (u[i][j] - u[i - 1][j]) - cy * (u[i][j] - u[i][j - 1]);
      }
    }
    for (int j = 0; j < LI_EF_NY; ++j) {
      for (int i = 0; i < LI_EF_NX; ++i) {
        u[i][j] = un[i][j];
      }
    }
  }
  g_li_euler_fluid_checksum = u[LI_EF_NX / 2][LI_EF_NY / 2];
}

double li_euler_fluid_2d_checksum(void) { return g_li_euler_fluid_checksum; }
