#include "lig_cuda_ptx_catalog.h"

#include "lig_cuda_matmul2_ptx.inc"

#include <stddef.h>

static const LiLigCudaPtxEntry k_ptx_catalog[] = {
    {
        "lig.kernel.matmul_f32",
        1,
        "lig_matmul2x2_f32",
        k_lig_matmul2x2_ptx,
        k_lig_matmul2x2_ptx_len,
        "runtime/kernels/lig_matmul2x2.cu",
    },
};

int32_t li_rt_lig_cuda_ptx_catalog_count(void) {
  return (int32_t)(sizeof(k_ptx_catalog) / sizeof(k_ptx_catalog[0]));
}

const LiLigCudaPtxEntry* li_rt_lig_cuda_ptx_catalog_entry(int32_t index) {
  if (index < 0 || index >= li_rt_lig_cuda_ptx_catalog_count()) {
    return NULL;
  }
  return &k_ptx_catalog[index];
}

const LiLigCudaPtxEntry* li_rt_lig_cuda_ptx_lookup(const char* symbol) {
  if (symbol == NULL || symbol[0] == '\0') {
    return NULL;
  }
  for (int32_t i = 0; i < li_rt_lig_cuda_ptx_catalog_count(); ++i) {
    const LiLigCudaPtxEntry* e = &k_ptx_catalog[i];
    if (e->symbol != NULL) {
      const char* a = e->symbol;
      const char* b = symbol;
      while (*a != '\0' && *a == *b) {
        ++a;
        ++b;
      }
      if (*a == '\0' && *b == '\0') {
        return e;
      }
    }
  }
  return NULL;
}
