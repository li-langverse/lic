#include "li_xfer_plan.h"

#include "li_dpar.h"
#include "li_rt_hetero.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak))
#endif
const LiXferPlan __li_xfer_plan = {
    0u,
    LI_XFER_PLAN_VERSION,
    0u,
    0u,
    0u,
    0u,
};

static double g_last_xfer_sec = 0.0;
static uint32_t g_last_elided_copies = 0u;
static uint32_t g_elide_sites_seen = 0u;
static uint32_t g_fusion_sites_seen = 0u;
static uint32_t g_d2d_sites_seen = 0u;
static uint32_t g_rdma_gpu_sites_seen = 0u;

static double now_sec(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

void li_xfer_plan_apply(void) {
  if (__li_xfer_plan.magic != LI_XFER_PLAN_MAGIC) {
    return;
  }
  g_elide_sites_seen = 0u;
  g_fusion_sites_seen = 0u;
  g_d2d_sites_seen = 0u;
  g_rdma_gpu_sites_seen = 0u;
}

void li_xfer_elide_copy(void) {
  if (__li_xfer_plan.magic != LI_XFER_PLAN_MAGIC) {
    return;
  }
  g_elide_sites_seen++;
  if (__li_xfer_plan.elide_copy_count > 0 &&
      g_elide_sites_seen > __li_xfer_plan.elide_copy_count) {
    fprintf(stderr, "li_xfer_plan: elide copy site exceeds compiled plan (%u)\n",
            __li_xfer_plan.elide_copy_count);
  }
  g_last_elided_copies++;
}

void li_xfer_fusion(void) {
  if (__li_xfer_plan.magic != LI_XFER_PLAN_MAGIC) {
    return;
  }
  g_fusion_sites_seen++;
  if (__li_xfer_plan.fusion_count > 0 && g_fusion_sites_seen > __li_xfer_plan.fusion_count) {
    fprintf(stderr, "li_xfer_plan: fuse xfer site exceeds compiled plan (%u)\n",
            __li_xfer_plan.fusion_count);
  }
}

void li_xfer_d2d_path(void) {
  if (__li_xfer_plan.magic != LI_XFER_PLAN_MAGIC) {
    return;
  }
  g_d2d_sites_seen++;
  if (__li_xfer_plan.d2d_path_count > 0 && g_d2d_sites_seen > __li_xfer_plan.d2d_path_count) {
    fprintf(stderr, "li_xfer_plan: d2d path site exceeds compiled plan (%u)\n",
            __li_xfer_plan.d2d_path_count);
  }
  if (li_rt_hetero_probe_gpu() == 0) {
    const double t0 = now_sec();
    (void)li_rt_hetero_available_mask();
    g_last_xfer_sec += now_sec() - t0;
  }
}

void li_xfer_rdma_gpu(void) {
  if (__li_xfer_plan.magic != LI_XFER_PLAN_MAGIC) {
    return;
  }
  g_rdma_gpu_sites_seen++;
  if (__li_xfer_plan.rdma_gpu_count > 0 && g_rdma_gpu_sites_seen > __li_xfer_plan.rdma_gpu_count) {
    fprintf(stderr, "li_xfer_plan: rdma gpu site exceeds compiled plan (%u)\n",
            __li_xfer_plan.rdma_gpu_count);
  }
  const char* v = getenv("LI_XFER_RDMA_GPU");
  if (v != NULL && v[0] != '\0' && strcmp(v, "0") != 0) {
    (void)li_dpar_rank();
    if (li_rt_hetero_probe_gpu() == 0) {
      g_last_elided_copies++;
    }
  }
}

double li_xfer_last_xfer_sec(void) {
  return g_last_xfer_sec;
}

uint32_t li_xfer_last_elided_copies(void) {
  return g_last_elided_copies;
}

void li_xfer_set_last_xfer_sec(double seconds) {
  g_last_xfer_sec = seconds;
}

void li_xfer_set_last_elided_copies(uint32_t count) {
  g_last_elided_copies = count;
}
