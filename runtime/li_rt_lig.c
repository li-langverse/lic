#include "li_rt_lig.h"

#include <math.h>
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

int32_t li_rt_lig_kernel_run(int32_t kid, int32_t bid) {
  g_ratio = 0.0f;
  if (kid == 1) return lig_run_matmul_f32(bid);
  if (kid == 3) return lig_run_present_blit_rgba8(bid);
  if (kid == 4) return lig_run_present_wgpu_readback(bid);
  return 1;
}

float li_rt_lig_kernel_last_validity_ratio(void) { return g_ratio; }
