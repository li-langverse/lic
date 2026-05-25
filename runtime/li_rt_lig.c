#include "li_rt_lig.h"
#include <stdlib.h>
#if defined(__APPLE__)
#include <TargetConditionals.h>
#endif
static float g_ratio = 1.0f;
int32_t li_rt_lig_backend_select_auto(void) {
#if defined(__APPLE__) && TARGET_OS_OSX
  return 3;
#else
  if (getenv("ROCM_PATH") || getenv("HIPCC")) return 2;
  if (getenv("CUDA_PATH") || getenv("CUDA_HOME")) return 1;
  return 4;
#endif
}
int32_t li_rt_lig_kernel_run(int32_t kid, int32_t bid) {
  (void)kid; (void)bid; g_ratio = 1.0f; return 0;
}
float li_rt_lig_kernel_last_validity_ratio(void) { return g_ratio; }
