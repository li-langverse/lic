#include "li_rt_lig_cuda.h"

#include <stdio.h>

int main(void) {
  if (li_rt_lig_cuda_matmul2x2_device() != 1) {
    return 1;
  }
  const long long ns = (long long)li_rt_lig_cuda_last_timing_ns();
  if (ns <= 0) {
    return 1;
  }
  printf("%lld\n", ns);
  return 0;
}
