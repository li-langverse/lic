/* Optional quick bench profile: few DOFs, enough steps for stability (set LI_BENCH_QUICK=1). */
#pragma once

#include <stdlib.h>

static inline int li_bench_quick_enabled(void) {
  const char* q = getenv("LI_BENCH_QUICK");
  return q != NULL && q[0] == '1';
}

static inline int li_bench_pick_int(int quick_val, int full_val) {
  return li_bench_quick_enabled() ? quick_val : full_val;
}
