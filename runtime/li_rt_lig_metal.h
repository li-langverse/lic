#ifndef LI_RT_LIG_METAL_H
#define LI_RT_LIG_METAL_H

#include <stdint.h>

/** Run 2x2 f32 matmul on Metal (macOS / Apple Silicon only). Returns 1 on success. */
int32_t li_rt_lig_metal_matmul2x2_device(void);

/** Last device kernel wall time in ns, or -1 if not measured. */
int64_t li_rt_lig_metal_last_timing_ns(void);

#endif
