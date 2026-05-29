#include "li_rt_lig.h"

#include "li_rt_lkir_spirv.h"

#include <stdlib.h>
#include <string.h>

int32_t li_rt_lig_present_blit_rgba8(int32_t,int32_t,int32_t,int32_t,int32_t);
int32_t li_rt_lig_wgpu_readback_stub(int32_t,int32_t,int32_t,int32_t,int32_t);
int32_t li_rt_studio_demo_profile_from_env(void);

static float g_ratio = 1.0f;

/* Host launch status (WP-HW-08): negative = blocked, 0 = ran stub path, 1 = emit stub only */
enum {
  LI_LIG_KERNEL_UNAVAILABLE = -1,
  LI_LIG_KERNEL_EMIT_OFF = -2,
  LI_LIG_KERNEL_STUB_OK = 0,
  LI_LIG_KERNEL_EMIT_STUB = 1,
};

static int lig_emit_env_enabled(const char* name) {
  const char* emit = getenv(name);
  if (emit == NULL || emit[0] == '\0') {
    return 0;
  }
  if (strcmp(emit, "0") == 0) {
    return 0;
  }
  return 1;
}

static int lig_emit_cuda_enabled(void) { return lig_emit_env_enabled("LIG_EMIT_CUDA"); }

static int lig_emit_hip_enabled(void) { return lig_emit_env_enabled("LIG_EMIT_HIP"); }

static int32_t lig_run_present_blit_rgba8(int32_t b){(void)b;int p=li_rt_studio_demo_profile_from_env();int t=21+(p>1?p-1:0);if(p==7)t=27;g_ratio=1.0f;return li_rt_lig_present_blit_rgba8(1280,720,p,1,t)==1?0:1;}
static int32_t lig_run_present_wgpu_readback(int32_t b){(void)b;int p=li_rt_studio_demo_profile_from_env();int t=21+(p>1?p-1:0);if(p==7)t=27;g_ratio=1.0f;return li_rt_lig_wgpu_readback_stub(1280,720,p,1,t)==1?0:1;}

static int32_t lig_run_matmul_vendor_stub(int32_t bid) {
  if (bid == 1) {
    if (!lig_emit_cuda_enabled()) {
      g_ratio = 0.0f;
      return LI_LIG_KERNEL_EMIT_OFF;
    }
    g_ratio = 0.0f;
    return LI_LIG_KERNEL_EMIT_STUB;
  }
  if (bid == 2) {
    if (!lig_emit_hip_enabled()) {
      g_ratio = 0.0f;
      return LI_LIG_KERNEL_EMIT_OFF;
    }
    g_ratio = 0.0f;
    return LI_LIG_KERNEL_EMIT_STUB;
  }
  return LI_LIG_KERNEL_UNAVAILABLE;
}

int32_t li_rt_lig_kernel_run(int32_t kid, int32_t bid) {
  g_ratio = 1.0f;
  if (bid == 5) {
    if (li_rt_lkir_spirv_validation_smoke() == 1) {
      g_ratio = 1.0f;
    } else {
      g_ratio = 0.0f;
    }
    return LI_LIG_KERNEL_UNAVAILABLE;
  }
  if (kid == 1 && (bid == 1 || bid == 2)) {
    return lig_run_matmul_vendor_stub(bid);
  }
  if (kid == 2 && (bid == 1 || bid == 2 || bid == 5)) {
    return lig_run_matmul_vendor_stub(bid);
  }
  if (kid == 3) {
    return lig_run_present_blit_rgba8(0);
  }
  if (kid == 4) {
    return lig_run_present_wgpu_readback(0);
  }
  if (bid == 1 || bid == 2) {
    return lig_run_matmul_vendor_stub(bid);
  }
  return LI_LIG_KERNEL_STUB_OK;
}

float li_rt_lig_kernel_last_validity_ratio(void) { return g_ratio; }
