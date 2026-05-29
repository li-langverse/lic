#ifndef LI_RT_LIG_CUDA_H
#define LI_RT_LIG_CUDA_H

#include "lig_cuda_ptx_catalog.h"

#include <stdint.h>

int32_t li_rt_lig_cuda_matmul2x2_device(void);
int64_t li_rt_lig_cuda_last_timing_ns(void);

#endif
