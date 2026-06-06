#include "li_rt_hetero.h"

#include <stdio.h>
#include <stdlib.h>

int main(void) {
  if (li_rt_hetero_probe_pipeline() != 0) {
    fprintf(stderr, "li_hetero_smoke: hetero pipeline probe failed\n");
    return 1;
  }
  printf("li_hetero_smoke: ok (GPU+TPU+ASIC orchestration mask=%d)\n",
         (int)li_rt_hetero_available_mask());
  return 0;
}
