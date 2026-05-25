#pragma once
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
int32_t li_rt_lig_backend_select_auto(void);
int32_t li_rt_lig_kernel_run(int32_t kernel_id, int32_t backend_id);
float li_rt_lig_kernel_last_validity_ratio(void);
#ifdef __cplusplus
}
#endif
