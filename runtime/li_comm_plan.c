#include "li_comm_plan.h"

#include "li_dpar.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak))
#endif
const LiCommPlan __li_comm_plan = {
    0u,
    LI_COMM_PLAN_VERSION,
    0u,
    0u,
    0u,
    0u,
};

static double g_last_overlap_fraction = 0.0;
static uint32_t g_overlap_regions_seen = 0u;

void li_comm_plan_apply(void) {
  if (__li_comm_plan.magic != LI_COMM_PLAN_MAGIC) {
    return;
  }
  g_overlap_regions_seen = 0u;
  if (__li_comm_plan.compressed_halo_enabled) {
    (void)getenv("LI_COMM_COMPRESSED_HALO");
  }
  if (__li_comm_plan.rdma_hooks) {
    li_comm_rdma_post();
  }
}

void li_comm_overlap_region(void) {
  if (__li_comm_plan.magic != LI_COMM_PLAN_MAGIC) {
    return;
  }
  g_overlap_regions_seen++;
  if (__li_comm_plan.overlap_comm_count > 0 &&
      g_overlap_regions_seen > __li_comm_plan.overlap_comm_count) {
    fprintf(stderr, "li_comm_plan: overlap comm region exceeds compiled plan (%u)\n",
            __li_comm_plan.overlap_comm_count);
  }
}

void li_comm_rdma_post(void) {
  /* WP-PAR-73 — RDMA hook registration stub; real NIC paths land in li-dpar RDMA backend. */
  const char* v = getenv("LI_COMM_RDMA");
  if (v != NULL && v[0] != '\0' && strcmp(v, "0") != 0) {
    (void)li_dpar_rank();
  }
}

double li_comm_last_overlap_fraction(void) {
  return g_last_overlap_fraction;
}

void li_comm_set_last_overlap_fraction(double fraction) {
  g_last_overlap_fraction = fraction;
}
