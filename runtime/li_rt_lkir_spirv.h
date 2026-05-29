#ifndef LI_RT_LKIR_SPIRV_H
#define LI_RT_LKIR_SPIRV_H

#include <stdint.h>

/** 0 = stub module ok, 1 = magic mismatch, 2 = size too small */
int32_t li_rt_lkir_spirv_emit_status(void);
/** 1 when minimal SPIR-V header validates (no Vulkan dispatch). */
int32_t li_rt_lkir_spirv_validation_smoke(void);
const uint8_t* li_rt_lkir_spirv_matmul_stub_bytes(uint32_t* out_len);

#endif
