/* Studio demo recorder — numbered frame paths + trace append (Phase 2). */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <direct.h>
#define li_demo_mkdir(p) _mkdir(p)
#else
#include <sys/stat.h>
#include <sys/types.h>
#define li_demo_mkdir(p) mkdir(p, 0755)
#endif

static char g_demo_frames_dir[512];
static int32_t g_demo_frame_next = 1;
static char g_demo_trace_path[512];

static int32_t li_demo_dir_ready(const char* dir) {
  if (dir == NULL || dir[0] == '\0') {
    return 0;
  }
  li_demo_mkdir(dir);
  return 1;
}

int32_t li_rt_studio_demo_set_output(const char* dir, int32_t frame_start) {
  if (!li_demo_dir_ready(dir)) {
    return 0;
  }
  strncpy(g_demo_frames_dir, dir, sizeof(g_demo_frames_dir) - 1u);
  g_demo_frames_dir[sizeof(g_demo_frames_dir) - 1u] = '\0';
  if (frame_start < 1) {
    frame_start = 1;
  }
  g_demo_frame_next = frame_start;
  return 1;
}

int32_t li_rt_studio_demo_emit_scratch(const char* scratch_path) {
  char dest[640];
  FILE* in;
  FILE* out;
  size_t n;
  unsigned char buf[8192];

  if (scratch_path == NULL || scratch_path[0] == '\0' || g_demo_frames_dir[0] == '\0') {
    return 0;
  }
  if (snprintf(dest, sizeof(dest), "%s/frame-%04d.ppm", g_demo_frames_dir, (int)g_demo_frame_next) < 0) {
    return 0;
  }
  in = fopen(scratch_path, "rb");
  if (in == NULL) {
    return 0;
  }
  out = fopen(dest, "wb");
  if (out == NULL) {
    fclose(in);
    return 0;
  }
  while ((n = fread(buf, 1, sizeof(buf), in)) > 0u) {
    if (fwrite(buf, 1, n, out) != n) {
      fclose(in);
      fclose(out);
      return 0;
    }
  }
  fclose(in);
  fclose(out);
  g_demo_frame_next += 1;
  return 1;
}

int32_t li_rt_studio_demo_frame_count(void) {
  if (g_demo_frame_next < 1) {
    return 0;
  }
  return g_demo_frame_next - 1;
}

int32_t li_rt_studio_demo_scenario_id_from_env(void) {
  const char* v = getenv("STUDIO_DEMO_SCENARIO_ID");
  if (v == NULL || v[0] == '\0') {
    return 1;
  }
  return (int32_t)atoi(v);
}

int32_t li_rt_studio_demo_trace_open(const char* path) {
  if (path == NULL || path[0] == '\0') {
    g_demo_trace_path[0] = '\0';
    return 0;
  }
  strncpy(g_demo_trace_path, path, sizeof(g_demo_trace_path) - 1u);
  g_demo_trace_path[sizeof(g_demo_trace_path) - 1u] = '\0';
  return 1;
}

int32_t li_rt_studio_demo_trace_append(const char* path, int32_t step_idx, int32_t kind, int32_t arg) {
  const char* use = path;
  if (use == NULL || use[0] == '\0') {
    use = g_demo_trace_path;
  }
  if (use[0] == '\0') {
    return 0;
  }
  FILE* f = fopen(use, "a");
  if (f == NULL) {
    return 0;
  }
  fprintf(f, "{\"step\":%d,\"kind\":%d,\"arg\":%d}\n", (int)step_idx, (int)kind, (int)arg);
  fclose(f);
  return 1;
}
