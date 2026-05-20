#include "../../../harness/bench_quick.h"

#include <math.h>

enum { LI_RS_N_MAX = 50 };
#define LI_RS_N_FULL 50
#define LI_RS_N_QUICK 12
#define LI_RS_STEPS_FULL 2000
#define LI_RS_STEPS_QUICK 400
#define LI_RS_DT (1.0 / 60.0)
#define LI_RS_G 9.81

static double g_li_rigid_stack_checksum;

void li_rigid_stack_kernel(void) {
  const int n = li_bench_pick_int(LI_RS_N_QUICK, LI_RS_N_FULL);
  const int steps = li_bench_pick_int(LI_RS_STEPS_QUICK, LI_RS_STEPS_FULL);
  double y[LI_RS_N_MAX];
  double v[LI_RS_N_MAX];
  for (int i = 0; i < n; ++i) {
    y[i] = 1.0 + (double)i * 0.1;
    v[i] = 0.0;
  }
  for (int s = 0; s < steps; ++s) {
    for (int i = 0; i < n; ++i) {
      v[i] += -LI_RS_G * LI_RS_DT;
      y[i] += v[i] * LI_RS_DT;
      if (y[i] < 0.0) {
        y[i] = 0.0;
        v[i] = 0.0;
      }
    }
  }
  g_li_rigid_stack_checksum = y[n - 1];
}

double li_rigid_stack_checksum(void) { return g_li_rigid_stack_checksum; }
