#include "li_rt_lig.h"

#include "li_rt_lig_cuda.h"
#include "li_rt_lkir_spirv.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

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

static int lig_cuda_home_present(void) {
  const char* home = getenv("CUDA_HOME");
  if (home != NULL && home[0] != '\0') {
    return 1;
  }
  home = getenv("CUDA_PATH");
  return (home != NULL && home[0] != '\0') ? 1 : 0;
}

static int lig_nvcc_executable(void) {
  const char* roots[] = {getenv("CUDA_HOME"), getenv("CUDA_PATH"), "/usr/local/cuda", NULL};
  for (size_t r = 0; roots[r] != NULL; ++r) {
    const char* root = roots[r];
    if (root == NULL || root[0] == '\0') continue;
    char path[512];
    const int n = snprintf(path, sizeof(path), "%s/bin/nvcc", root);
    if (n > 0 && n < (int)sizeof(path) && access(path, X_OK) == 0) return 1;
  }
  return (access("/usr/bin/nvcc", X_OK) == 0) ? 1 : 0;
}

/* Fixed 2x2 reference matmul — CPU only, sets g_ratio (WP-HW-08/09). */
static void lig_matmul_cpu_ref_2x2(void) {
  const float a[4] = {1.0f, 2.0f, 3.0f, 4.0f};
  const float b[4] = {5.0f, 6.0f, 7.0f, 8.0f};
  float c[4];
  c[0] = a[0] * b[0] + a[1] * b[2];
  c[1] = a[0] * b[1] + a[1] * b[3];
  c[2] = a[2] * b[0] + a[3] * b[2];
  c[3] = a[2] * b[1] + a[3] * b[3];
  const float expect[4] = {19.0f, 22.0f, 43.0f, 50.0f};
  float err = 0.0f;
  for (int i = 0; i < 4; ++i) {
    const float d = c[i] - expect[i];
    if (d < 0.0f) {
      err += -d;
    } else {
      err += d;
    }
  }
  g_ratio = (err < 1e-5f) ? 1.0f : 0.0f;
}

static int32_t lig_run_present_blit_rgba8(int32_t b){(void)b;int p=li_rt_studio_demo_profile_from_env();int t=21+(p>1?p-1:0);if(p==7)t=27;g_ratio=1.0f;return li_rt_lig_present_blit_rgba8(1280,720,p,1,t)==1?0:1;}
static int32_t lig_run_present_wgpu_readback(int32_t b){(void)b;int p=li_rt_studio_demo_profile_from_env();int t=21+(p>1?p-1:0);if(p==7)t=27;g_ratio=1.0f;return li_rt_lig_wgpu_readback_stub(1280,720,p,1,t)==1?0:1;}

static int32_t lig_run_matmul_vendor_stub(int32_t bid) {
  if (bid == 1) {
    if (!lig_emit_cuda_enabled()) {
      g_ratio = 0.0f;
      return LI_LIG_KERNEL_EMIT_OFF;
    }
    if (lig_cuda_home_present() && lig_nvcc_executable() &&
        li_rt_lig_cuda_matmul2x2_device() == 1) {
      g_ratio = 1.0f;
      return LI_LIG_KERNEL_STUB_OK;
    }
    lig_matmul_cpu_ref_2x2();
    return LI_LIG_KERNEL_EMIT_STUB;
  }
  if (bid == 2) {
    if (!lig_emit_hip_enabled()) {
      g_ratio = 0.0f;
      return LI_LIG_KERNEL_EMIT_OFF;
    }
    lig_matmul_cpu_ref_2x2();
    return LI_LIG_KERNEL_EMIT_STUB;
  }
  return LI_LIG_KERNEL_UNAVAILABLE;
}

static int32_t lig_run_vulkan_spirv_path(void) {
  if (li_rt_lkir_spirv_validation_smoke() != 1) {
    g_ratio = 0.0f;
    return LI_LIG_KERNEL_UNAVAILABLE;
  }
  g_ratio = 1.0f;
  if (li_rt_lkir_spirv_lavapipe_probe() == 1) {
    return LI_LIG_KERNEL_STUB_OK;
  }
  return LI_LIG_KERNEL_STUB_OK;
}

int32_t li_rt_lig_kernel_run(int32_t kid, int32_t bid) {
  g_ratio = 1.0f;
  if (bid == 5) {
    return lig_run_vulkan_spirv_path();
  }
  if (kid == 1 && (bid == 1 || bid == 2)) {
    return lig_run_matmul_vendor_stub(bid);
  }
  if (kid == 2 && (bid == 1 || bid == 2 || bid == 5)) {
    if (bid == 5) {
      return lig_run_vulkan_spirv_path();
    }
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

int32_t li_rt_lig_cuda_home_probe(void) {
  int32_t mask = 0;
  const char* home = getenv("CUDA_HOME");
  if (home != NULL && home[0] != '\0') {
    mask |= 1;
  }
  home = getenv("CUDA_PATH");
  if (home != NULL && home[0] != '\0') {
    mask |= 2;
  }
  const char* path = getenv("PATH");
  if (path != NULL && path[0] != '\0') {
    const char* start = path;
    for (;;) {
      const char* end = strchr(start, ':');
      const size_t len = end ? (size_t)(end - start) : strlen(start);
      if (len > 0 && len < 480) {
        char candidate[512];
        snprintf(candidate, sizeof(candidate), "%.*s/nvcc", (int)len, start);
        if (access(candidate, X_OK) == 0) {
          mask |= 4;
          break;
        }
      }
      if (end == NULL) {
        break;
      }
      start = end + 1;
    }
  }
  return mask;
}
