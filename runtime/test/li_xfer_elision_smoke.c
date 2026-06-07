/* WP-PAR-88–92 — transfer plan elision, fusion, D2D, RDMA→GPU + dashboard stats. */
#include "li_xfer_plan.h"

#include <stdio.h>
#include <stdlib.h>

const LiXferPlan __li_xfer_plan = {
    LI_XFER_PLAN_MAGIC,
    LI_XFER_PLAN_VERSION,
    2u,
    1u,
    1u,
    1u,
};

int main(void) {
  li_xfer_plan_apply();
  li_xfer_elide_copy();
  li_xfer_elide_copy();
  li_xfer_fusion();
  li_xfer_d2d_path();
  setenv("LI_XFER_RDMA_GPU", "1", 1);
  li_xfer_rdma_gpu();

  const double xfer_sec = li_xfer_last_xfer_sec();
  const uint32_t elided = li_xfer_last_elided_copies();
  if (elided < 2u) {
    fprintf(stderr, "li_xfer_elision_smoke: elided_copies=%u < 2\n", elided);
    return 1;
  }
  printf("li_xfer_elision_smoke: ok (xfer_sec=%.6f elided_copies=%u)\n", xfer_sec, elided);
  return 0;
}
