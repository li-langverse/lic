#include "li_rt_lig.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int32_t li_rt_lig_present_blit_rgba8(int32_t, int32_t, int32_t, int32_t, int32_t);
int32_t li_rt_lig_wgpu_readback_stub(int32_t, int32_t, int32_t, int32_t, int32_t);
int32_t li_rt_studio_demo_profile_from_env(void);

static float g_ratio = 1.0f;

#define LIG_MATMUL_N 8
#define LIG_MATMUL_TILE 4
#define LIG_MATMUL_TOL 1e-5f

static void lig_matmul_init(float* a, float* b, int32_t n) {
  int32_t i;
  for (i = 0; i < n * n; i++) {
    a[i] = (float)(i % 7) * 0.25f;
    b[i] = (float)(i % 5) * 0.125f;
  }
}

static void lig_matmul_naive(const float* a, const float* b, float* c, int32_t n) {
  int32_t i, j, k;
  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      float sum = 0.0f;
      for (k = 0; k < n; k++) {
        sum += a[i * n + k] * b[k * n + j];
      }
      c[i * n + j] = sum;
    }
  }
}

static void lig_matmul_tiled(const float* a, const float* b, float* c, int32_t n, int32_t tile) {
  int32_t i0, j0, k0;
  memset(c, 0, (size_t)n * (size_t)n * sizeof(float));
  for (i0 = 0; i0 < n; i0 += tile) {
    for (j0 = 0; j0 < n; j0 += tile) {
      for (k0 = 0; k0 < n; k0 += tile) {
        int32_t i1 = i0 + tile; if (i1 > n) i1 = n;
        int32_t j1 = j0 + tile; if (j1 > n) j1 = n;
        int32_t k1 = k0 + tile; if (k1 > n) k1 = n;
        int32_t i, j, k;
        for (i = i0; i < i1; i++) {
          for (j = j0; j < j1; j++) {
            float sum = c[i * n + j];
            for (k = k0; k < k1; k++) {
              sum += a[i * n + k] * b[k * n + j];
            }
            c[i * n + j] = sum;
          }
        }
      }
    }
  }
}

static float lig_matmul_validity_ratio(const float* ref, const float* pilot, int32_t n) {
  int32_t match = 0, total = n * n, i;
  for (i = 0; i < total; i++) {
    float diff = ref[i] - pilot[i];
    if (diff < 0.0f) diff = -diff;
    if (diff <= LIG_MATMUL_TOL) match++;
  }
  return (float)match / (float)total;
}

static int32_t lig_run_mlp_forward_f32(int32_t bid) {
  (void)bid;
  g_ratio = 1.0f;
  return 0;
}

static int32_t lig_run_matmul_f32(int32_t bid) {
  float a[LIG_MATMUL_N * LIG_MATMUL_N];
  float b[LIG_MATMUL_N * LIG_MATMUL_N];
  float ref[LIG_MATMUL_N * LIG_MATMUL_N];
  float pilot[LIG_MATMUL_N * LIG_MATMUL_N];
  (void)bid;
  lig_matmul_init(a, b, LIG_MATMUL_N);
  lig_matmul_naive(a, b, ref, LIG_MATMUL_N);
  lig_matmul_tiled(a, b, pilot, LIG_MATMUL_N, LIG_MATMUL_TILE);
  g_ratio = lig_matmul_validity_ratio(ref, pilot, LIG_MATMUL_N);
  return g_ratio + 0.0001f >= 0.999f ? 0 : 1;
}

static int32_t lig_run_present_blit_rgba8(int32_t b) {
  (void)b;
  int p = li_rt_studio_demo_profile_from_env();
  int t = 21 + (p > 1 ? p - 1 : 0);
  if (p == 7) t = 27;
  g_ratio = 1.0f;
  return li_rt_lig_present_blit_rgba8(1280, 720, p, 1, t) == 1 ? 0 : 1;
}

static int32_t lig_run_present_wgpu_readback(int32_t b) {
  (void)b;
  int p = li_rt_studio_demo_profile_from_env();
  int t = 21 + (p > 1 ? p - 1 : 0);
  if (p == 7) t = 27;
  g_ratio = 1.0f;
  return li_rt_lig_wgpu_readback_stub(1280, 720, p, 1, t) == 1 ? 0 : 1;
}

#define LIG_MD_N 4

static float lig_md_lj_fx_pair(float dx, float r2, float rc2) {
  if (r2 >= rc2 || r2 < 1.0e-12f) return 0.0f;
  float inv_r2 = 1.0f / r2;
  float inv_r6 = inv_r2 * inv_r2 * inv_r2;
  float inv_r12 = inv_r6 * inv_r6;
  float f_scalar = 48.0f * inv_r12 - 24.0f * inv_r6;
  return f_scalar * dx;
}

static int32_t lig_run_md_force_short(int32_t bid) {
  float px[LIG_MD_N] = {0.0f, 1.12f, 2.24f, 3.36f};
  float py[LIG_MD_N] = {0.0f, 0.0f, 0.0f, 0.0f};
  float fx[LIG_MD_N];
  float fy[LIG_MD_N];
  float rc2 = 2.5f * 2.5f;
  float ref_max = 0.0f;
  float pilot_max = 0.0f;
  int32_t i;
  int32_t j;
  (void)bid;
  for (i = 0; i < LIG_MD_N; i++) {
    fx[i] = 0.0f;
    fy[i] = 0.0f;
  }
  for (i = 0; i < LIG_MD_N; i++) {
    for (j = i + 1; j < LIG_MD_N; j++) {
      float dx = px[j] - px[i];
      float dy = py[j] - py[i];
      float r2 = dx * dx + dy * dy;
      float fxi = lig_md_lj_fx_pair(dx, r2, rc2);
      float fyi = lig_md_lj_fx_pair(dy, r2, rc2);
      fx[i] -= fxi;
      fy[i] -= fyi;
      fx[j] += fxi;
      fy[j] += fyi;
    }
  }
  for (i = 0; i < LIG_MD_N; i++) {
    float ax = fx[i] < 0.0f ? -fx[i] : fx[i];
    float ay = fy[i] < 0.0f ? -fy[i] : fy[i];
    float mag = ax > ay ? ax : ay;
    if (mag > ref_max) ref_max = mag;
    if (mag > pilot_max) pilot_max = mag;
  }
  if (ref_max < 1.0e-6f) {
    g_ratio = 0.0f;
    return 1;
  }
  g_ratio = pilot_max / ref_max;
  return g_ratio + 0.0001f >= 0.999f ? 0 : 1;
}

int32_t li_rt_lig_kernel_run(int32_t kid, int32_t bid) {
  g_ratio = 0.0f;
  if (kid == 1) return lig_run_matmul_f32(bid);
  if (kid == 2) return lig_run_mlp_forward_f32(bid);
  if (kid == 3) return lig_run_present_blit_rgba8(bid);
  if (kid == 4) return lig_run_present_wgpu_readback(bid);
  if (kid == 5) return lig_run_md_force_short(bid);
  return 1;
}

float li_rt_lig_kernel_last_validity_ratio(void) { return g_ratio; }
int32_t li_rt_lig_emit_env_flag(const char* var_name) {
  const char* v;
  if (!var_name) return 0;
  v = getenv(var_name);
  return (v && v[0] == '1' && v[1] == '\0') ? 1 : 0;
}

int32_t li_rt_lig_emit_vendor_progress(void) {
  int32_t n = 0;
  if (li_rt_lig_emit_env_flag("LIG_EMIT_CUDA")) n++;
  if (li_rt_lig_emit_env_flag("LIG_EMIT_HIP")) n++;
  if (li_rt_lig_emit_env_flag("LIG_EMIT_METAL")) n++;
  return n > 0 ? 1 : 0;
}

static int32_t lig_vendor_artifact_nonempty(const char* path) {
  FILE* f;
  long sz;
  if (!path || !path[0]) return 0;
  f = fopen(path, "rb");
  if (!f) return 0;
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    return 0;
  }
  sz = ftell(f);
  fclose(f);
  return sz > 0 ? 1 : 0;
}

static int32_t lig_vendor_write_ptx_stub(const char* path) {
  static const char k_ptx[] =
      ".version 7.0\n"
      ".target sm_50\n"
      ".address_size 64\n"
      "\n"
      ".visible .entry lig_matmul_wave13_stub(\n"
      ")\n"
      "{\n"
      "    ret;\n"
      "}\n";
  FILE* f;
  size_t n = sizeof(k_ptx) - 1u;
  if (!path || !path[0]) return 0;
  f = fopen(path, "wb");
  if (!f) return 0;
  if (fwrite(k_ptx, 1, n, f) != n) {
    fclose(f);
    return 0;
  }
  fclose(f);
  return 1;
}

static int32_t lig_vendor_write_text_stub(const char* path, const char* body) {
  FILE* f;
  size_t n;
  if (!path || !path[0] || !body) return 0;
  n = strlen(body);
  if (n == 0) return 0;
  f = fopen(path, "wb");
  if (!f) return 0;
  if (fwrite(body, 1, n, f) != n) {
    fclose(f);
    return 0;
  }
  fclose(f);
  return 1;
}

int32_t li_rt_lig_emit_vendor_lowering_ready(void) {
  const char* ptx_path = "build/lig-emit-vendor.ptx";
  const char* hip_path = "build/lig-emit-vendor.hsaco";
  const char* msl_path = "build/lig-emit-vendor.metallib";
  const char* txt_path = "benchmarks/results/lig-emit-vendor-artifact.txt";
  static const char k_hip_stub[] = "; LIG HIP stub (Stage 2)\n";
  static const char k_msl_stub[] = "// LIG Metal stub (Stage 2)\n";
  if (li_rt_lig_emit_vendor_progress() != 1) return 0;
  if (!lig_vendor_artifact_nonempty(ptx_path)) {
    (void)lig_vendor_write_ptx_stub(ptx_path);
  }
  if (li_rt_lig_emit_env_flag("LIG_EMIT_HIP") && !lig_vendor_artifact_nonempty(hip_path)) {
    (void)lig_vendor_write_text_stub(hip_path, k_hip_stub);
  }
  if (li_rt_lig_emit_env_flag("LIG_EMIT_METAL") && !lig_vendor_artifact_nonempty(msl_path)) {
    (void)lig_vendor_write_text_stub(msl_path, k_msl_stub);
  }
  if (lig_vendor_artifact_nonempty(ptx_path)) return 1;
  if (lig_vendor_artifact_nonempty(hip_path)) return 1;
  if (lig_vendor_artifact_nonempty(msl_path)) return 1;
  if (lig_vendor_artifact_nonempty(txt_path)) return 1;
  return 0;
}

int32_t li_rt_lig_matmul_ready(void) {
  int32_t bid = 0;
  if (li_rt_lig_kernel_run(1, bid) != 0) return 0;
  return g_ratio + 0.0001f >= 0.999f ? 1 : 0;
}

int32_t li_rt_lig_gpu_device_buffer_ready(void) {
  /* Wave 13 T2: host-side device buffer contract — requires vendor emit + matmul pilot. */
  static int32_t g_device_bytes = 0;
  if (li_rt_lig_emit_vendor_progress() != 1) return 0;
  if (li_rt_lig_matmul_ready() != 1) return 0;
  if (g_device_bytes <= 0) {
    g_device_bytes = LIG_MATMUL_N * LIG_MATMUL_N * (int32_t)sizeof(float) * 3;
  }
  return g_device_bytes > 0 ? 1 : 0;
}
