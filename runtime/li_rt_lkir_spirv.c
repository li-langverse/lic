#include "li_rt_lkir_spirv.h"

#include <stdlib.h>
#include <string.h>

/* Minimal SPIR-V 1.0 module header (magic + version + generator + bound + schema).
 * Not a runnable compute shader — headless validation smoke (WP-HW-06/07). */
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

static uint32_t spirv_stub_read_u32_le(size_t off) {
  if (off + 4u > sizeof(k_lkir_matmul_spirv_stub)) {
    return 0u;
  }
  const uint8_t* p = k_lkir_matmul_spirv_stub + off;
  return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

int32_t li_rt_lkir_spirv_emit_status(void) {
  if (!spirv_stub_magic_ok()) {
    return 1;
  }
  if (spirv_stub_read_u32_le(12u) < 1u) {
    return 2;
  }
  return 0;
}

int32_t li_rt_lkir_spirv_validation_smoke(void) {
  if (li_rt_lkir_spirv_emit_status() != 0) {
    return 0;
  }
  const uint32_t version = spirv_stub_read_u32_le(4u);
  if (version == 0u) {
    return 0;
  }
  return 1;
}

/* WP-HW-07: lavapipe / ICD hint only — no linked Vulkan loader in default build. */
int32_t li_rt_lkir_spirv_lavapipe_probe(void) {
  if (li_rt_lkir_spirv_validation_smoke() != 1) {
    return 0;
  }
  const char* force = getenv("LIG_VULKAN_LAVA");
  if (force != NULL && force[0] != '\0' && strcmp(force, "0") != 0) {
    return 1;
  }
  const char* icd = getenv("VK_ICD_FILENAMES");
  if (icd != NULL && icd[0] != '\0') {
    if (strstr(icd, "lavapipe") != NULL || strstr(icd, "Lavapipe") != NULL) {
      return 1;
    }
  }
  return 0;
}

const uint8_t* li_rt_lkir_spirv_matmul_stub_bytes(uint32_t* out_len) {
  if (out_len) {
    *out_len = (uint32_t)sizeof(k_lkir_matmul_spirv_stub);
  }
  return k_lkir_matmul_spirv_stub;
}
