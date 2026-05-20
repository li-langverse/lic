#include "../../../harness/bench_quick.h"

#include <math.h>

enum { LI_CL_N_MAX = 16 };
#define LI_CL_N_FULL 16
#define LI_CL_N_QUICK 8
#define LI_CL_STEPS_FULL 8000
#define LI_CL_STEPS_QUICK 4000
#define LI_CL_DT (1.0 / 60.0)
#define LI_CL_REST 0.2
#define LI_CL_STIFF 0.95

static double g_li_cloth_checksum;

void li_cloth_swing_kernel(void) {
  const int n = li_bench_pick_int(LI_CL_N_QUICK, LI_CL_N_FULL);
  const int steps = li_bench_pick_int(LI_CL_STEPS_QUICK, LI_CL_STEPS_FULL);
  double px[LI_CL_N_MAX];
  double py[LI_CL_N_MAX];
  double vx[LI_CL_N_MAX];
  double vy[LI_CL_N_MAX];
  for (int i = 0; i < n; ++i) {
    px[i] = (double)i * LI_CL_REST;
    py[i] = 1.0;
    vx[i] = 0.0;
    vy[i] = 0.0;
  }
  px[0] = 0.0;
  py[0] = 1.0;
  vx[0] = 0.0;
  vy[0] = 0.0;
  for (int s = 0; s < steps; ++s) {
    for (int k = 0; k < 4; ++k) {
      for (int i = 0; i < n - 1; ++i) {
        double dx = px[i + 1] - px[i];
        double dy = py[i + 1] - py[i];
        double len = sqrt(dx * dx + dy * dy);
        if (len < 1e-12) continue;
        double corr = LI_CL_STIFF * (len - LI_CL_REST) / len;
        if (i > 0) {
          px[i] += 0.5 * corr * dx;
          py[i] += 0.5 * corr * dy;
        }
        px[i + 1] -= 0.5 * corr * dx;
        py[i + 1] -= 0.5 * corr * dy;
      }
    }
    for (int i = 1; i < n; ++i) {
      vy[i] += -9.81 * LI_CL_DT;
      px[i] += vx[i] * LI_CL_DT;
      py[i] += vy[i] * LI_CL_DT;
    }
  }
  g_li_cloth_checksum = py[n - 1];
}

double li_cloth_swing_checksum(void) { return g_li_cloth_checksum; }
