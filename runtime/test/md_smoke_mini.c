#include "md_smoke_mini.h"

static double g_li_md_checksum;

static double li_md_smoke_run(void) {
  LiMdSmokeRng rng;
  LiMdSmokeState state;
  li_md_smoke_rng_init(&rng, LI_MD_SMOKE_SEED);
  li_md_smoke_init_fcc(&state, &rng);
  li_md_smoke_compute_forces(&state);
  double ke = 0.0, pe = 0.0;
  li_md_smoke_kinetic(&state, &ke);
  li_md_smoke_potential(&state, &pe);
  const double e0 = pe + ke;
  for (int step = 1; step <= LI_MD_SMOKE_STEPS; ++step) {
    li_md_smoke_step(&state);
  }
  li_md_smoke_kinetic(&state, &ke);
  li_md_smoke_potential(&state, &pe);
  const double e1 = pe + ke;
  const double denom = (e0 >= e1 ? e0 : e1);
  const double d = denom > 1e-12 ? denom : 1e-12;
  const double diff = e1 - e0;
  return (diff >= 0.0 ? diff : -diff) / d;
}

void li_md_kernel(void) { g_li_md_checksum = li_md_smoke_run(); }

double li_md_checksum(void) { return g_li_md_checksum; }
