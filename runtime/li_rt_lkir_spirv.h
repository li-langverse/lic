#ifndef LI_RT_LKIR_SPIRV_H
#define LI_RT_LKIR_SPIRV_H

#include <stdint.h>

/** 0 = stub module ok, 1 = magic mismatch, 2 = bound too small */
int32_t li_rt_lkir_spirv_emit_status(void);
/** 1 when minimal SPIR-V header validates (no GPU dispatch). */
int32_t li_rt_lkir_spirv_validation_smoke(void);
/** 1 when libvulkan VkInstance create succeeds (WP-HW-07 loader smoke). */
int32_t li_rt_lkir_vulkan_loader_smoke(void);
/** 1 when loader smoke or LIG_VULKAN_LAVA / lavapipe ICD hint (WP-HW-07). */
int32_t li_rt_lkir_spirv_lavapipe_probe(void);
const uint8_t* li_rt_lkir_spirv_matmul_stub_bytes(uint32_t* out_len);

#endif
