#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LI_COMM_PLAN_MAGIC 0x5043494cu /* 'LICP' */
#define LI_COMM_PLAN_VERSION 1u

typedef struct LiCommPlan {
  uint32_t magic;
  uint32_t version;
  uint32_t overlap_comm_count;
  uint32_t ghost_exchange_count;
  uint32_t compressed_halo_enabled;
  uint32_t rdma_hooks;
} LiCommPlan;

extern const LiCommPlan __li_comm_plan;

void li_comm_plan_apply(void);
void li_comm_overlap_region(void);
void li_comm_rdma_post(void);

/** Overlap stats (WP-PAR-72) — updated by MD ghost overlap smokes. */
double li_comm_last_overlap_fraction(void);
void li_comm_set_last_overlap_fraction(double fraction);

#ifdef __cplusplus
}
#endif
