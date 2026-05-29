#ifndef LI_RT_LIG_H
#define LI_RT_LIG_H

#include <stdint.h>

int32_t li_rt_lig_kernel_run(int32_t kernel_id, int32_t backend_id);
float li_rt_lig_kernel_last_validity_ratio(void);

/** WP-HW-09: 1=CUDA_HOME set, 2=CUDA_PATH set, 4=nvcc on PATH (no device timing). */
int32_t li_rt_lig_cuda_home_probe(void);

#endif
