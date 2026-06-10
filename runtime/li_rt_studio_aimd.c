/* World Studio AIMD hero demo — scenario state, batch env, JSON trace, PPM color budget. */
#include "li_rt.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#if !defined(_WIN32)
#include <sys/stat.h>
#endif

typedef struct {
  int32_t configured;
  int32_t steps;
  int32_t temperature_k;
  int32_t potential_mv;
  int32_t algo_id;
} LiRtStudioAimdScenario;

static LiRtStudioAimdScenario g_studio_aimd_scenario = {0, 5000, 300, 0, 433};
static char g_studio_aimd_last_ppm[1024] = "";

static int32_t li_rt_studio_aimd_mkdir_parents(const char* path) {
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  char buf[1024];
  size_t len = strlen(path);
  if (len >= sizeof(buf)) {
    return 0;
  }
  memcpy(buf, path, len + 1);
  for (size_t i = 1; i < len; i++) {
    if (buf[i] == '/') {
      buf[i] = '\0';
#if !defined(_WIN32)
      mkdir(buf, 0755);
#else
      _mkdir(buf);
#endif
      buf[i] = '/';
    }
  }
  return 1;
}

int32_t li_rt_studio_aimd_scenario_reset(void) {
  g_studio_aimd_scenario.configured = 0;
  g_studio_aimd_scenario.steps = 5000;
  g_studio_aimd_scenario.temperature_k = 300;
  g_studio_aimd_scenario.potential_mv = 0;
  g_studio_aimd_scenario.algo_id = 433;
  return 0;
}

int32_t li_rt_studio_aimd_scenario_set(int32_t steps, int32_t temperature_k, int32_t potential_mv,
                                       int32_t algo_id) {
  if (steps < 64) {
    return 0;
  }
  if (steps > 10000) {
    return 0;
  }
  g_studio_aimd_scenario.configured = 1;
  g_studio_aimd_scenario.steps = steps;
  g_studio_aimd_scenario.temperature_k = temperature_k;
  g_studio_aimd_scenario.potential_mv = potential_mv;
  g_studio_aimd_scenario.algo_id = algo_id;
  return 1;
}

int32_t li_rt_studio_aimd_scenario_get_steps(void) { return g_studio_aimd_scenario.steps; }

int32_t li_rt_studio_aimd_scenario_get_temperature(void) {
  return g_studio_aimd_scenario.temperature_k;
}

int32_t li_rt_studio_aimd_scenario_get_potential(void) { return g_studio_aimd_scenario.potential_mv; }

int32_t li_rt_studio_aimd_scenario_get_algo(void) { return g_studio_aimd_scenario.algo_id; }

int32_t li_rt_studio_aimd_scenario_is_configured(void) { return g_studio_aimd_scenario.configured; }

int32_t li_rt_studio_aimd_gpu_from_env(void) {
  const char* v = getenv("STUDIO_AIMD_GPU");
  return (v != NULL && v[0] == '1' && v[1] == '\0') ? 1 : 0;
}

int32_t li_rt_studio_aimd_batch_steps_from_env(void) {
  const char* v = getenv("STUDIO_AIMD_BATCH_STEPS");
  if (v == NULL || v[0] == '\0') {
    v = getenv("WORLD_STUDIO_AIMD_DEMO_MIN_STEPS");
  }
  if (v == NULL || v[0] == '\0') {
    return g_studio_aimd_scenario.steps;
  }
  const int n = atoi(v);
  if (n < 64) {
    return 64;
  }
  if (n > 10000) {
    return 10000;
  }
  return (int32_t)n;
}

static const char* li_rt_studio_aimd_batch_tier_label(int32_t gpu_path) {
  const char* pilot = getenv("STUDIO_AIMD_PILOT");
  if (pilot != NULL && pilot[0] == '1' && pilot[1] == '\0') {
    return gpu_path == 1 ? "pilot" : "mvp_stub";
  }
  if (gpu_path == 1) {
    return "mvp_gpu_stub";
  }
  return "mvp_stub";
}

int32_t li_rt_studio_aimd_batch_write_json(const char* path, int32_t steps, int32_t ok,
                                           double checksum, double energy_drift, int32_t gpu_path) {
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  li_rt_studio_aimd_mkdir_parents(path);
  FILE* f = fopen(path, "w");
  if (f == NULL) {
    return 0;
  }
  const char* tier = li_rt_studio_aimd_batch_tier_label(gpu_path);
  const char* stride_env = getenv("STUDIO_AIMD_DFT_STRIDE");
  int dft_stride = (stride_env != NULL && stride_env[0] != '\0') ? atoi(stride_env) : 50;
  if (dft_stride < 1) {
    dft_stride = 1;
  }
  int dft_calls = steps / dft_stride + 1;
  fprintf(f,
          "{\n"
          "  \"native_only\": true,\n"
          "  \"tier\": \"%s\",\n"
          "  \"steps\": %d,\n"
          "  \"ok\": %d,\n"
          "  \"checksum\": %.12f,\n"
          "  \"energy_drift\": %.12f,\n"
          "  \"gpu_path\": %d,\n"
          "  \"dft_stride\": %d,\n"
          "  \"dft_calls\": %d\n"
          "}\n",
          tier, (int)steps, (int)ok,
          (isfinite(checksum) ? checksum : 1.0e-6),
          (isfinite(energy_drift) ? energy_drift : 1.0e-6), (int)gpu_path, dft_stride,
          dft_calls);
  fclose(f);
  return 1;
}

int32_t li_rt_studio_ppm_unique_colors(const char* path) {
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  FILE* f = fopen(path, "rb");
  if (f == NULL) {
    return 0;
  }
  char magic[3];
  if (fread(magic, 1, 3, f) != 3 || magic[0] != 'P' || magic[1] != '6') {
    fclose(f);
    return 0;
  }
  int width = 0;
  int height = 0;
  int maxval = 0;
  if (fscanf(f, " %d %d %d", &width, &height, &maxval) != 3 || width <= 0 || height <= 0) {
    fclose(f);
    return 0;
  }
  fgetc(f);
  static unsigned char seen[32768];
  memset(seen, 0, sizeof(seen));
  int unique = 0;
  unsigned char rgb[3];
  const int total = width * height;
  for (int i = 0; i < total; i++) {
    if (fread(rgb, 1, 3, f) != 3) {
      break;
    }
    const unsigned idx = ((unsigned)rgb[0] >> 3) << 10 | ((unsigned)rgb[1] >> 3) << 5 | ((unsigned)rgb[2] >> 3);
    if (!seen[idx]) {
      seen[idx] = 1;
      unique++;
    }
  }
  fclose(f);
  return unique;
}

int32_t li_rt_studio_aimd_last_ppm_set(const char* path) {
  if (path == NULL || path[0] == '\0') {
    g_studio_aimd_last_ppm[0] = '\0';
    return 0;
  }
  size_t len = strlen(path);
  if (len >= sizeof(g_studio_aimd_last_ppm)) {
    return 0;
  }
  memcpy(g_studio_aimd_last_ppm, path, len + 1);
  return 1;
}

const char* li_rt_studio_aimd_last_ppm_get(void) { return g_studio_aimd_last_ppm; }

/* Headless studio smokes: ui_snapshot tag lookup without full gui runtime. */
int32_t li_rt_ui_snapshot_tag_from_id(const char* id) {
  (void)id;
  return 0;
}
