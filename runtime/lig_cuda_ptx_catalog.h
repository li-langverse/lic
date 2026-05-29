#ifndef LI_LIG_CUDA_PTX_CATALOG_H
#define LI_LIG_CUDA_PTX_CATALOG_H

#include <stdint.h>

typedef struct LiLigCudaPtxEntry {
  const char* kernel_id;
  int32_t lig_kid;
  const char* symbol;
  const char* ptx;
  unsigned int ptx_len;
  const char* source_cu;
} LiLigCudaPtxEntry;

int32_t li_rt_lig_cuda_ptx_catalog_count(void);
const LiLigCudaPtxEntry* li_rt_lig_cuda_ptx_catalog_entry(int32_t index);
const LiLigCudaPtxEntry* li_rt_lig_cuda_ptx_lookup(const char* symbol);

#endif
