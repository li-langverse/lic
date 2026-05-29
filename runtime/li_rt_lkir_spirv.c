#include "li_rt_lkir_spirv.h"

/* Minimal SPIR-V 1.0 module header (magic + version + generator + bound + schema).
 * Not a runnable compute shader — headless validation smoke only (WP-HW-06). */
static const uint8_t k_lkir_matmul_spirv_stub[] = {
    0x03, 0x02, 0x23, 0x07, /* MagicNumber */
    0x00, 0x00, 0x01, 0x00, /* Version 1.0 */
    0x00, 0x00, 0x00, 0x00, /* Generator */
    0x01, 0x00, 0x00, 0x00, /* Bound */
    0x00, 0x00, 0x00, 0x00, /* Schema */
};

static int spirv_stub_magic_ok(void) {
  if (sizeof(k_lkir_matmul_spirv_stub) < 20u) {
    return 0;
  }
  const uint32_t magic =
      (uint32_t)k_lkir_matmul_spirv_stub[0] | ((uint32_t)k_lkir_matmul_spirv_stub[1] << 8) |
      ((uint32_t)k_lkir_matmul_spirv_stub[2] << 16) | ((uint32_t)k_lkir_matmul_spirv_stub[3] << 24);
  return magic == 0x07230203u;
}

int32_t li_rt_lkir_spirv_emit_status(void) {
  if (!spirv_stub_magic_ok()) {
    return 1;
  }
  return 0;
}

int32_t li_rt_lkir_spirv_validation_smoke(void) {
  if (li_rt_lkir_spirv_emit_status() != 0) {
    return 0;
  }
  return 1;
}

const uint8_t* li_rt_lkir_spirv_matmul_stub_bytes(uint32_t* out_len) {
  if (out_len) {
    *out_len = (uint32_t)sizeof(k_lkir_matmul_spirv_stub);
  }
  return k_lkir_matmul_spirv_stub;
}
