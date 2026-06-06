#ifndef LI_RT_HETERO_H
#define LI_RT_HETERO_H

#include <stdint.h>

int32_t li_rt_hetero_probe_gpu(void);
int32_t li_rt_hetero_probe_tpu(void);
int32_t li_rt_hetero_probe_asic(void);
int32_t li_rt_hetero_available_mask(void);
int32_t li_rt_hetero_probe_pipeline(void);

#endif
