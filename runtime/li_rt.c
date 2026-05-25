#include "li_rt.h"
#include "li_parallel.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32)
#include <pthread.h>
#include <unistd.h>
#endif

void li_panic(const char* msg) {
  fprintf(stderr, "li panic: %s\n", msg);
  abort();
}

void li_bounds_fail(void) { li_panic("array index out of bounds"); }

void li_rt_print_int(int32_t value) { printf("%d\n", value); }

void li_rt_print_str(const char* s) { puts(s); }

static int li_argc = 0;
static char** li_argv = NULL;

void li_rt_set_args(int argc, char** argv) {
  li_argc = argc;
  li_argv = argv;
}

int li_rt_argc(void) { return li_argc; }

const char* li_rt_argv(int index) {
  if (index < 0 || index >= li_argc || li_argv == NULL) {
    return "";
  }
  return li_argv[index];
}

typedef struct {
  long long begin;
  long long end;
} LiParChunk;

typedef struct {
  void (*body)(long long);
  LiParChunk chunk;
} LiParWorkerArg;

#if !defined(_WIN32)
static void* li_par_worker(void* raw) {
  LiParWorkerArg* arg = (LiParWorkerArg*)raw;
  for (long long i = arg->chunk.begin; i < arg->chunk.end; ++i) {
    arg->body(i);
  }
  return NULL;
}
#endif

static int li_warn_omp_alias_once(void) {
  static int warned = 0;
  if (!warned) {
    fprintf(stderr,
            "lic: warning: li_omp_parallel_for_i64 is deprecated; use li_parallel_for_i64 "
            "(native pthread pool)\n");
    warned = 1;
  }
  return 0;
}

static int li_resolve_team_size(int team_size) {
  /* team_size > 0 is baked in at `lic build` from --threads/--cores (preferred). */
  if (team_size > 0) {
    return team_size;
  }
  const char* nt = getenv("LI_OMP_THREADS");
  if (nt && *nt) {
    int threads = atoi(nt);
    if (threads > 0) {
      return threads;
    }
  }
#if defined(_WIN32)
  return 1;
#else
  long cores = sysconf(_SC_NPROCESSORS_ONLN);
  if (cores < 1) {
    return 1;
  }
  if (cores > LI_MAX_THREADS) {
    return LI_MAX_THREADS;
  }
  return (int)cores;
#endif
}

static int li_clamp_team(int team_size, long long trip_count) {
  team_size = li_resolve_team_size(team_size);
  if (team_size > LI_MAX_THREADS) {
    team_size = LI_MAX_THREADS;
  }
  if (trip_count < (long long)team_size) {
    team_size = (int)trip_count;
  }
  if (team_size < 1) {
    team_size = 1;
  }
  return team_size;
}

void li_parallel_for_i64(long long start, long long end, void (*body)(long long),
                         int team_size) {
  const long long trip = end - start;
  if (trip <= 0 || body == NULL) {
    return;
  }
  if (trip == 1) {
    body(start);
    return;
  }

  team_size = li_clamp_team(team_size, trip);
  if (team_size <= 1) {
    for (long long i = start; i < end; ++i) {
      body(i);
    }
    return;
  }

#if defined(_WIN32)
  (void)team_size;
  for (long long i = start; i < end; ++i) {
    body(i);
  }
#else
  pthread_t threads[LI_MAX_THREADS];
  LiParWorkerArg args[LI_MAX_THREADS];
  const long long base = trip / team_size;
  const long long rem = trip % team_size;
  int launched = 0;
  long long cur = start;
  for (int w = 0; w < team_size; ++w) {
    const long long len = base + (w < (int)rem ? 1 : 0);
    if (len <= 0) {
      continue;
    }
    args[launched].body = body;
    args[launched].chunk.begin = cur;
    args[launched].chunk.end = cur + len;
    cur += len;
    if (pthread_create(&threads[launched], NULL, li_par_worker, &args[launched]) != 0) {
      for (long long i = args[launched].chunk.begin; i < args[launched].chunk.end; ++i) {
        body(i);
      }
      continue;
    }
    ++launched;
  }
  for (int w = 0; w < launched; ++w) {
    pthread_join(threads[w], NULL);
  }
#endif
}

void li_omp_parallel_for_i64(long long start, long long end, void (*body)(long long)) {
  (void)li_warn_omp_alias_once();
  li_parallel_for_i64(start, end, body, 0);
}

int32_t li_rt_floor_div_i32(int32_t a, int32_t b) {
  if (b == 0) {
    li_panic("division by zero");
  }
  int32_t q = a / b;
  int32_t r = a % b;
  if (r != 0 && ((r < 0) != (b < 0))) {
    --q;
  }
  return q;
}

int32_t li_rt_pow_i32(int32_t base, int32_t exp) {
  if (exp < 0) {
    return 0;
  }
  int32_t out = 1;
  for (int32_t i = 0; i < exp; ++i) {
    out *= base;
  }
  return out;
}

double li_rt_sqrt(double x) {
#if defined(_WIN32)
  return sqrt(x);
#else
  return __builtin_sqrt(x);
#endif
}

double li_rt_sin(double x) { return sin(x); }

double li_rt_cos(double x) { return cos(x); }

double li_rt_atan2(double y, double x) { return atan2(y, x); }

double li_rt_exp(double x) { return exp(x); }

double li_rt_log(double x) { return log(x); }

double li_rt_hypot(double x, double y) {
#if defined(_WIN32)
  return hypot(x, y);
#else
  return __builtin_hypot(x, y);
#endif
}

double li_rt_expm1(double x) {
#if defined(_WIN32)
  return expm1(x);
#else
  return __builtin_expm1(x);
#endif
}

double li_rt_log1p(double x) { return log1p(x); }

void li_rt_print_f64(double v) { printf("%.17g\n", v); }

void li_rt_volatile_sink_f64(double v) {
  const char* emit = getenv("LI_PRINT_SINK_F64");
  if (emit != NULL && emit[0] == '1' && emit[1] == '\0') {
    printf("%.17g\n", v);
  }
  volatile double sink = v;
  (void)sink;
}

int32_t li_rt_str_byte_at(const char* s, int32_t i) {
  if (s == NULL || i < 0) {
    li_panic("li_rt_str_byte_at: bad args");
  }
  const size_t len = strlen(s);
  if ((size_t)i >= len) {
    li_panic("li_rt_str_byte_at: out of bounds");
  }
  return (int32_t)(unsigned char)s[i];
}

int32_t li_rt_str_prefix_is_get(const char* s) {
  if (s == NULL) {
    return 0;
  }
  const unsigned char* p = (const unsigned char*)s;
  return (p[0] == (unsigned char)'G' && p[1] == (unsigned char)'E' && p[2] == (unsigned char)'T') ? 1 : 0;
}

int32_t li_rt_http_parse_request_len_tag(const char* s, int32_t max_header_block, int32_t max_body) {
  (void)max_body;
  if (s == NULL || max_header_block <= 0) {
    return 0;
  }
  const size_t len = strlen(s);
  if (len > (size_t)max_header_block) {
    return 0;
  }
  const int32_t n = (int32_t)len;
  if (n < 3) {
    return n;
  }
  return n + li_rt_str_prefix_is_get(s);
}

int32_t li_rt_str_len(const char* s) {
  if (s == NULL) {
    return 0;
  }
  return (int32_t)strlen(s);
}

int32_t li_rt_str_char_at(const char* s, int32_t i) {
  if (s == NULL || i < 0) {
    return -1;
  }
  const size_t len = strlen(s);
  if ((size_t)i >= len) {
    return -1;
  }
  return (int32_t)(unsigned char)s[i];
}

int32_t li_rt_str_eq(const char* a, const char* b) {
  if (a == NULL || b == NULL) {
    return 0;
  }
  return strcmp(a, b) == 0 ? 1 : 0;
}


static int32_t li_rt_studio_profile_match_name(const char* name) {
  if (name == NULL) {
    return 0;
  }
  if (li_rt_str_eq(name, "game")) {
    return 1;
  }
  if (li_rt_str_eq(name, "sim_rl")) {
    return 2;
  }
  if (li_rt_str_eq(name, "sim_automotive")) {
    return 3;
  }
  if (li_rt_str_eq(name, "sim_robotics")) {
    return 4;
  }
  if (li_rt_str_eq(name, "sim_additive")) {
    return 5;
  }
  if (li_rt_str_eq(name, "sim_scientific")) {
    return 6;
  }
  if (li_rt_str_eq(name, "sim_drug_design")) {
    return 7;
  }
  return 0;
}

int32_t li_rt_studio_profile_from_name(const char* name) {
  return li_rt_studio_profile_match_name(name);
}

static int32_t li_rt_studio_mcp_tool_match_name(const char* name) {
  if (name == NULL) {
    return 0;
  }
  if (li_rt_str_eq(name, "world_scaffold")) {
    return 1;
  }
  if (li_rt_str_eq(name, "sim_set_profile")) {
    return 2;
  }
  if (li_rt_str_eq(name, "lic_check")) {
    return 3;
  }
  if (li_rt_str_eq(name, "lic_build")) {
    return 4;
  }
  if (li_rt_str_eq(name, "publish_bundle")) {
    return 5;
  }
  return 0;
}

int32_t li_rt_studio_mcp_tool_from_name(const char* name) {
  return li_rt_studio_mcp_tool_match_name(name);
}

const char* li_rt_studio_mcp_tool_name(int32_t tool_id) {
  switch (tool_id) {
    case 1:
      return "world_scaffold";
    case 2:
      return "sim_set_profile";
    case 3:
      return "lic_check";
    case 4:
      return "lic_build";
    case 5:
      return "publish_bundle";
    default:
      return "";
  }
}

static int32_t g_studio_timeline_playing = 0;
static float g_studio_timeline_playhead_pct = 0.35f;

int32_t li_rt_studio_timeline_playing(void) { return g_studio_timeline_playing; }

int32_t li_rt_studio_timeline_toggle_play(void) {
  g_studio_timeline_playing = g_studio_timeline_playing ? 0 : 1;
  return g_studio_timeline_playing;
}

int32_t li_rt_studio_timeline_tick_frame(void) {
  if (!g_studio_timeline_playing) {
    return 0;
  }
  g_studio_timeline_playhead_pct += 0.01f;
  if (g_studio_timeline_playhead_pct > 1.0f) {
    g_studio_timeline_playhead_pct = 1.0f;
  }
  return 1;
}

float li_rt_studio_timeline_playhead_pct(void) { return g_studio_timeline_playhead_pct; }

int32_t li_rt_studio_timeline_reset_mock(void) {
  g_studio_timeline_playing = 0;
  g_studio_timeline_playhead_pct = 0.35f;
  return 0;
}

static int32_t g_studio_viewport_error_kind = 0;

int32_t li_rt_studio_viewport_error_kind(void) { return g_studio_viewport_error_kind; }

int32_t li_rt_studio_viewport_error_set_mock(int32_t kind) {
  if (kind < 0 || kind > 2) {
    return g_studio_viewport_error_kind;
  }
  g_studio_viewport_error_kind = kind;
  return kind;
}

int32_t li_rt_studio_viewport_error_retry(void) {
  g_studio_viewport_error_kind = 0;
  return 0;
}

int32_t li_rt_studio_parse_toml_profile_line(const char* line) {
  if (line == NULL) {
    return 0;
  }
  const char* key = "profile";
  const char* p = strstr(line, key);
  if (p == NULL) {
    return 0;
  }
  p += strlen(key);
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  if (*p != '=') {
    return 0;
  }
  p++;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  if (*p != '"') {
    return 0;
  }
  p++;
  const char* start = p;
  while (*p != '\0' && *p != '"') {
    p++;
  }
  if (*p != '"') {
    return 0;
  }
  char buf[64];
  const size_t n = (size_t)(p - start);
  if (n == 0 || n >= sizeof(buf)) {
    return 0;
  }
  memcpy(buf, start, n);
  buf[n] = '\0';
  return li_rt_studio_profile_match_name(buf);
}


/* PH-HW HW-0: lig device layer (was li-gpu stub). */
#define LI_RT_LIG_BACKEND_CUDA 1
#define LI_RT_LIG_BACKEND_ROCM 2
#define LI_RT_LIG_BACKEND_METAL 3
#define LI_RT_LIG_BACKEND_WEBGPU 4

static int32_t g_lig_selected_backend = LI_RT_LIG_BACKEND_WEBGPU;

static int32_t li_rt_lig_backend_probe_available(int32_t backend_id) {
  switch (backend_id) {
    case LI_RT_LIG_BACKEND_CUDA:
      return (getenv("CUDA_HOME") != NULL || getenv("CUDA_PATH") != NULL) ? 1 : 0;
    case LI_RT_LIG_BACKEND_ROCM:
      return (getenv("ROCM_PATH") != NULL || getenv("HIP_PATH") != NULL) ? 1 : 0;
    case LI_RT_LIG_BACKEND_METAL:
#if defined(__APPLE__)
      return 1;
#else
      return 0;
#endif
    case LI_RT_LIG_BACKEND_WEBGPU:
      return 1;
    default:
      return 0;
  }
}

static int32_t li_rt_lig_backend_match_name(const char* name) {
  if (name == NULL) {
    return 0;
  }
  if (strcmp(name, "cuda") == 0) {
    return LI_RT_LIG_BACKEND_CUDA;
  }
  if (strcmp(name, "rocm") == 0 || strcmp(name, "hip") == 0) {
    return LI_RT_LIG_BACKEND_ROCM;
  }
  if (strcmp(name, "metal") == 0) {
    return LI_RT_LIG_BACKEND_METAL;
  }
  if (strcmp(name, "webgpu") == 0 || strcmp(name, "wgpu") == 0) {
    return LI_RT_LIG_BACKEND_WEBGPU;
  }
  return 0;
}

int32_t li_rt_lig_device_kind(void) { return g_lig_selected_backend; }

int32_t li_rt_lig_backend_available(int32_t backend_id) {
  return li_rt_lig_backend_probe_available(backend_id);
}

int32_t li_rt_lig_backend_select_auto(void) {
#if defined(__APPLE__)
  if (li_rt_lig_backend_probe_available(LI_RT_LIG_BACKEND_METAL)) {
    g_lig_selected_backend = LI_RT_LIG_BACKEND_METAL;
    return LI_RT_LIG_BACKEND_METAL;
  }
#endif
  if (li_rt_lig_backend_probe_available(LI_RT_LIG_BACKEND_ROCM)) {
    g_lig_selected_backend = LI_RT_LIG_BACKEND_ROCM;
    return LI_RT_LIG_BACKEND_ROCM;
  }
  if (li_rt_lig_backend_probe_available(LI_RT_LIG_BACKEND_CUDA)) {
    g_lig_selected_backend = LI_RT_LIG_BACKEND_CUDA;
    return LI_RT_LIG_BACKEND_CUDA;
  }
  g_lig_selected_backend = LI_RT_LIG_BACKEND_WEBGPU;
  return LI_RT_LIG_BACKEND_WEBGPU;
}

int32_t li_rt_lig_present_surface_ok(void) {
  return 0;
}

static char li_rt_lig_cap_json_buf[192];

const char* li_rt_lig_capability_json(void) {
  snprintf(li_rt_lig_cap_json_buf, sizeof(li_rt_lig_cap_json_buf),
           "{\"lig_version\":2,\"device_kind\":%d,\"surface_ok\":%d}",
           (int)g_lig_selected_backend, (int)li_rt_lig_present_surface_ok());
  return li_rt_lig_cap_json_buf;
}

int32_t li_rt_lig_parse_toml_backend_line(const char* line) {
  if (line == NULL) {
    return 0;
  }
  const char* key = "backend";
  const char* p = strstr(line, key);
  if (p == NULL) {
    return 0;
  }
  p += strlen(key);
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  if (*p != '=') {
    return 0;
  }
  p++;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  char buf[32];
  const char* start = NULL;
  size_t n = 0;
  if (*p == '"') {
    p++;
    start = p;
    while (*p != '\0' && *p != '"') {
      p++;
    }
    if (*p != '"') {
      return 0;
    }
    n = (size_t)(p - start);
  } else {
    start = p;
    while ((*p >= 'a' && *p <= 'z') || (*p >= '0' && *p <= '9') || *p == '_') {
      p++;
    }
    n = (size_t)(p - start);
  }
  if (n == 0 || n >= sizeof(buf)) {
    return 0;
  }
  memcpy(buf, start, n);
  buf[n] = '\0';
  const int32_t id = li_rt_lig_backend_match_name(buf);
  if (id != 0) {
    g_lig_selected_backend = id;
  }
  return id;
}

/* PH-GD-2 li-world: world_v1 name=... tick=N entity_count=M (text line, no binary). */
#define LI_RT_WORLD_NAME_MAX 64
#define LI_RT_WORLD_LINE_MAX 256

static char li_rt_world_line_buf[LI_RT_WORLD_LINE_MAX];
static struct {
  int32_t name_slot;
  int32_t tick;
  int32_t entity_count;
  int32_t valid;
} li_rt_world_parsed;

static const char* li_rt_world_token_for_slot(int32_t slot) {
  if (slot == 1) {
    return "arena";
  }
  return "default";
}

static int32_t li_rt_world_slot_for_token(const char* name) {
  if (name != NULL && strcmp(name, "arena") == 0) {
    return 1;
  }
  return 0;
}

int32_t li_rt_world_format_version(void) { return 1; }

const char* li_rt_world_serialize_slot(int32_t name_slot, int32_t tick, int32_t entity_count) {
  if (name_slot < 0 || name_slot > 1) {
    name_slot = 0;
  }
  if (tick < 0) {
    tick = 0;
  }
  if (entity_count < 0) {
    entity_count = 0;
  }
  snprintf(li_rt_world_line_buf, sizeof(li_rt_world_line_buf), "world_v1 name=%s tick=%d entity_count=%d",
           li_rt_world_token_for_slot(name_slot), (int)tick, (int)entity_count);
  return li_rt_world_line_buf;
}

int32_t li_rt_world_parse_line(const char* line) {
  li_rt_world_parsed.valid = 0;
  li_rt_world_parsed.name_slot = 0;
  li_rt_world_parsed.tick = 0;
  li_rt_world_parsed.entity_count = 0;
  if (line == NULL) {
    return 0;
  }
  char name[LI_RT_WORLD_NAME_MAX];
  int tick = 0;
  int entity_count = 0;
  if (sscanf(line, "world_v1 name=%63s tick=%d entity_count=%d", name, &tick, &entity_count) != 3) {
    return 0;
  }
  if (tick < 0 || entity_count < 0) {
    return 0;
  }
  li_rt_world_parsed.name_slot = li_rt_world_slot_for_token(name);
  li_rt_world_parsed.tick = (int32_t)tick;
  li_rt_world_parsed.entity_count = (int32_t)entity_count;
  li_rt_world_parsed.valid = 1;
  return 1;
}

int32_t li_rt_world_parsed_name_slot(void) {
  if (li_rt_world_parsed.valid == 0) {
    return 0;
  }
  return li_rt_world_parsed.name_slot;
}

int32_t li_rt_world_parsed_tick(void) {
  if (li_rt_world_parsed.valid == 0) {
    return 0;
  }
  return li_rt_world_parsed.tick;
}

int32_t li_rt_world_parsed_entity_count(void) {
  if (li_rt_world_parsed.valid == 0) {
    return 0;
  }
  return li_rt_world_parsed.entity_count;
}

int32_t li_rt_world_snapshot_eq_fields(int32_t an, int32_t at, int32_t ae, int32_t bn, int32_t bt,
                                     int32_t be) {
  return (an == bn && at == bt && ae == be) ? 1 : 0;
}

int32_t li_rt_world_roundtrip_fields(int32_t name_slot, int32_t tick, int32_t entity_count) {
  const char* line = li_rt_world_serialize_slot(name_slot, tick, entity_count);
  if (li_rt_world_parse_line(line) != 1) {
    return 0;
  }
  if (li_rt_world_parsed.name_slot != name_slot) {
    return 0;
  }
  if (li_rt_world_parsed.tick != tick) {
    return 0;
  }
  if (li_rt_world_parsed.entity_count != entity_count) {
    return 0;
  }
  return 1;
}

int32_t li_rt_path_exact(const char* path, const char* want) {
  return li_rt_str_eq(path, want);
}

int32_t li_rt_path_prefix(const char* path, const char* prefix) {
  if (path == NULL || prefix == NULL || prefix[0] == '\0') {
    return 0;
  }
  const size_t plen = strlen(prefix);
  const size_t pathlen = strlen(path);
  if (pathlen < plen) {
    return 0;
  }
  if (strncmp(path, prefix, plen) != 0) {
    return 0;
  }
  if (pathlen == plen) {
    return 1;
  }
  if (path[plen] == '/') {
    return 1;
  }
  return 0;
}

int32_t li_rt_match_route_fixture(const char* method, const char* path) {
  if (method == NULL || path == NULL) {
    return 0;
  }
  if (strcmp(method, "GET") == 0) {
    if (li_rt_path_exact(path, "/health")) {
      return 1;
    }
    if (li_rt_path_prefix(path, "/v1")) {
      return 3;
    }
    return 0;
  }
  if (strcmp(method, "POST") == 0) {
    if (li_rt_path_prefix(path, "/v1")) {
      return 2;
    }
    return 0;
  }
  return 0;
}

void li_async_frame_enter(void) {}

void li_async_frame_leave(void) {}
