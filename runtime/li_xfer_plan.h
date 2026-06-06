#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LI_XFER_PLAN_MAGIC 0x5058494cu /* 'LIXP' */
#define LI_XFER_PLAN_VERSION 1u

typedef struct LiXferPlan {
  uint32_t magic;
  uint32_t version;
  uint32_t elide_copy_count;
  uint32_t fusion_count;
  uint32_t d2d_path_count;
  uint32_t rdma_gpu_count;
} LiXferPlan;

extern const LiXferPlan __li_xfer_plan;

void li_xfer_plan_apply(void);
void li_xfer_elide_copy(void);
void li_xfer_fusion(void);
void li_xfer_d2d_path(void);
void li_xfer_rdma_gpu(void);

/** Dashboard stats (WP-PAR-92). */
double li_xfer_last_xfer_sec(void);
uint32_t li_xfer_last_elided_copies(void);
void li_xfer_set_last_xfer_sec(double seconds);
void li_xfer_set_last_elided_copies(uint32_t count);

#ifdef __cplusplus
}
#endif
