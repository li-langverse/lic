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
  if (li_rt_str_eq(name, "am_export_print")) {
    return 6;
  }
  if (li_rt_str_eq(name, "chem_dft_run")) {
    return 7;
  }
  if (li_rt_str_eq(name, "studio_adaptive_layout")) {
    return 8;
  }
  if (li_rt_str_eq(name, "studio_set_viewport_background")) {
    return 9;
  }
  if (li_rt_str_eq(name, "studio_set_particle_display")) {
    return 10;
  }
  if (li_rt_str_eq(name, "studio_set_biomol_style")) {
    return 11;
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
    case 6:
      return "am_export_print";
    case 7:
      return "chem_dft_run";
    case 8:
      return "studio_adaptive_layout";
    case 9:
      return "studio_set_viewport_background";
    case 10:
      return "studio_set_particle_display";
    case 11:
      return "studio_set_biomol_style";
    default:
      return "";
  }
}

/* WP-AG-04: patch marker classification for studio_ai_apply_patch loop (smoke/eval contract). */
int32_t li_rt_studio_ai_patch_kind(const char* patch) {
  if (patch == NULL || patch[0] == '\0') {
    return -1;
  }
  if (li_rt_str_eq(patch, "@@fail@@")) {
    return 1;
  }
  if (li_rt_str_eq(patch, "@@retry@@")) {
    return 2;
  }
  return 0;
}

/* PH-UX viewport display — CPU paint_blit placeholders (not wgpu MD/PDB). */
static int32_t g_studio_viewport_bg = 0;
static int32_t g_studio_viewport_particle_tier = -1;
static int32_t g_studio_viewport_particle_draw_points = 0;
static int32_t g_studio_viewport_biomol_style = 0;

int32_t li_rt_studio_viewport_display_bg(void) { return g_studio_viewport_bg; }

int32_t li_rt_studio_viewport_display_set_bg(int32_t bg) {
  if (bg < 0 || bg > 2) {
    return g_studio_viewport_bg;
  }
  g_studio_viewport_bg = bg;
  return g_studio_viewport_bg;
}

int32_t li_rt_studio_viewport_display_particle_tier(void) { return g_studio_viewport_particle_tier; }

int32_t li_rt_studio_viewport_display_set_particle_tier(int32_t tier_id) {
  if (tier_id < -1 || tier_id > 2) {
    return g_studio_viewport_particle_tier;
  }
  g_studio_viewport_particle_tier = tier_id;
  g_studio_viewport_particle_draw_points = 0;
  return g_studio_viewport_particle_tier;
}

int32_t li_rt_studio_viewport_display_particle_draw_points(void) {
  return g_studio_viewport_particle_draw_points;
}

int32_t li_rt_studio_viewport_display_sync_scientific_step(int32_t tier_id, int32_t draw_points) {
  if (tier_id < -1 || tier_id > 2) {
    return 0;
  }
  if (draw_points < 0) {
    return 0;
  }
  g_studio_viewport_particle_tier = tier_id;
  g_studio_viewport_particle_draw_points = draw_points;
  return 1;
}

int32_t li_rt_studio_viewport_display_biomol_style(void) { return g_studio_viewport_biomol_style; }

int32_t li_rt_studio_viewport_display_set_biomol_style(int32_t style) {
  if (style < 0 || style > 2) {
    return g_studio_viewport_biomol_style;
  }
  g_studio_viewport_biomol_style = style;
  return g_studio_viewport_biomol_style;
}

int32_t li_rt_studio_viewport_display_reset_defaults(int32_t profile_id) {
  g_studio_viewport_bg = 0;
  g_studio_viewport_particle_tier = -1;
  g_studio_viewport_particle_draw_points = 0;
  g_studio_viewport_biomol_style = 0;
  if (profile_id == 6) {
    g_studio_viewport_bg = 1;
    g_studio_viewport_particle_tier = 1;
    g_studio_viewport_particle_draw_points = 10000;
    g_studio_viewport_biomol_style = 0;
  }
  if (profile_id == 7) {
    g_studio_viewport_bg = 2;
    g_studio_viewport_particle_tier = 0;
    g_studio_viewport_particle_draw_points = 1000;
    g_studio_viewport_biomol_style = 1;
  }
  return 1;
}

static int32_t g_studio_timeline_playing = 0;
static float g_studio_timeline_playhead_pct = 0.0f;

int32_t li_rt_studio_timeline_playing(void) { return g_studio_timeline_playing; }

int32_t li_rt_studio_timeline_toggle_play(void) {
  g_studio_timeline_playing = g_studio_timeline_playing ? 0 : 1;
  return g_studio_timeline_playing;
}

int32_t li_rt_studio_timeline_tick_frame(void) {
  if (!g_studio_timeline_playing) {
    return 0;
  }
  /* Playhead advances via li_rt_studio_timeline_sync_sim_tick after studio_sim_step_hook. */
  return 1;
}

float li_rt_studio_timeline_playhead_pct(void) { return g_studio_timeline_playhead_pct; }

int32_t li_rt_studio_timeline_set_playhead_pct(float pct) {
  if (pct < 0.0f) {
    pct = 0.0f;
  }
  if (pct > 1.0f) {
    pct = 1.0f;
  }
  g_studio_timeline_playhead_pct = pct;
  return 0;
}

int32_t li_rt_studio_timeline_sync_sim_tick(int32_t tick, int32_t duration_ticks) {
  if (duration_ticks < 1) {
    duration_ticks = 1;
  }
  if (tick < 0) {
    tick = 0;
  }
  float pct = (float)tick / (float)duration_ticks;
  if (pct > 1.0f) {
    pct = 1.0f;
  }
  g_studio_timeline_playhead_pct = pct;
  return tick;
}

int32_t li_rt_studio_timeline_reset_playback(void) {
  g_studio_timeline_playing = 0;
  g_studio_timeline_playhead_pct = 0.0f;
  return 0;
}

int32_t li_rt_studio_timeline_reset_mock(void) {
  return li_rt_studio_timeline_reset_playback();
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

/* WP-SIM-06 — cumulative studio.toml [engine] + [engine.export] line parser. */
#define LI_RT_STUDIO_TOML_SECTION_NONE 0
#define LI_RT_STUDIO_TOML_SECTION_ENGINE 1
#define LI_RT_STUDIO_TOML_SECTION_EXPORT 2

#define LI_RT_STUDIO_EXPORT_FMT_STL (1 << 0)
#define LI_RT_STUDIO_EXPORT_FMT_3MF (1 << 1)
#define LI_RT_STUDIO_EXPORT_FMT_GCODE (1 << 2)

typedef struct {
  int32_t section;
  int32_t profile_id;
  int32_t determinism_tier;
  int32_t export_format_mask;
  int32_t require_sim_pass;
  int32_t printer_profile_slot;
} LiRtStudioTomlState;

static LiRtStudioTomlState g_studio_toml;

static void li_rt_studio_toml_set_defaults(void) {
  g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_NONE;
  g_studio_toml.profile_id = 1;
  g_studio_toml.determinism_tier = 1;
  g_studio_toml.export_format_mask = 0;
  g_studio_toml.require_sim_pass = 0;
  g_studio_toml.printer_profile_slot = 0;
}

int32_t li_rt_studio_toml_reset(void) {
  li_rt_studio_toml_set_defaults();
  return 1;
}

static const char* li_rt_studio_toml_skip_ws(const char* p) {
  while (p != NULL && (*p == ' ' || *p == '\t')) {
    p++;
  }
  return p;
}

static int32_t li_rt_studio_toml_parse_int_value(const char* p) {
  p = li_rt_studio_toml_skip_ws(p);
  if (p == NULL || *p == '\0') {
    return -1;
  }
  const int n = atoi(p);
  if (n < 0) {
    return -1;
  }
  return (int32_t)n;
}

static int32_t li_rt_studio_toml_parse_bool_value(const char* p) {
  p = li_rt_studio_toml_skip_ws(p);
  if (p == NULL) {
    return 0;
  }
  if (strncmp(p, "true", 4) == 0) {
    return 1;
  }
  if (strncmp(p, "false", 5) == 0) {
    return 0;
  }
  return li_rt_studio_toml_parse_int_value(p) == 1 ? 1 : 0;
}

static int32_t li_rt_studio_toml_parse_quoted_value(const char* p, char* out, size_t cap) {
  p = li_rt_studio_toml_skip_ws(p);
  if (p == NULL || *p != '"') {
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
  const size_t n = (size_t)(p - start);
  if (n == 0 || n >= cap) {
    return 0;
  }
  memcpy(out, start, n);
  out[n] = '\0';
  return 1;
}

static int32_t li_rt_studio_toml_parse_formats_mask(const char* line) {
  int32_t mask = 0;
  if (line == NULL) {
    return 0;
  }
  if (strstr(line, "3mf") != NULL) {
    mask |= LI_RT_STUDIO_EXPORT_FMT_3MF;
  }
  if (strstr(line, "gcode") != NULL) {
    mask |= LI_RT_STUDIO_EXPORT_FMT_GCODE;
  }
  if (strstr(line, "stl") != NULL) {
    mask |= LI_RT_STUDIO_EXPORT_FMT_STL;
  }
  return mask;
}

static int32_t li_rt_studio_toml_printer_slot_for_path(const char* path) {
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  if (strstr(path, "bambu") != NULL) {
    return 1;
  }
  return 2;
}

static int32_t li_rt_studio_toml_parse_unquoted_token(const char* p, char* out, size_t cap) {
  p = li_rt_studio_toml_skip_ws(p);
  if (p == NULL || *p == '\0') {
    return 0;
  }
  const char* start = p;
  while (*p != '\0' && *p != ' ' && *p != '\t' && *p != '\r' && *p != '\n') {
    p++;
  }
  const size_t n = (size_t)(p - start);
  if (n == 0 || n >= cap) {
    return 0;
  }
  memcpy(out, start, n);
  out[n] = '\0';
  return 1;
}

static int32_t li_rt_studio_toml_parse_key_value(const char* line, const char* key) {
  const char* p = strstr(line, key);
  if (p == NULL) {
    return 0;
  }
  p += strlen(key);
  p = li_rt_studio_toml_skip_ws(p);
  if (p == NULL || *p != '=') {
    return 0;
  }
  p++;
  p = li_rt_studio_toml_skip_ws(p);
  if (p == NULL) {
    return 0;
  }
  if (li_rt_str_eq(key, "profile")) {
    char buf[64];
    if (li_rt_studio_toml_parse_quoted_value(p, buf, sizeof(buf)) != 1) {
      if (li_rt_studio_toml_parse_unquoted_token(p, buf, sizeof(buf)) != 1) {
        return 0;
      }
    }
    const int32_t id = li_rt_studio_profile_match_name(buf);
    if (id == 0) {
      return 0;
    }
    g_studio_toml.profile_id = id;
    return 1;
  }
  if (li_rt_str_eq(key, "determinism_tier")) {
    const int32_t tier = li_rt_studio_toml_parse_int_value(p);
    if (tier < 0 || tier > 3) {
      return 0;
    }
    g_studio_toml.determinism_tier = tier;
    return 1;
  }
  if (li_rt_str_eq(key, "formats")) {
    const int32_t mask = li_rt_studio_toml_parse_formats_mask(line);
    if (mask == 0) {
      return 0;
    }
    g_studio_toml.export_format_mask = mask;
    return 1;
  }
  if (li_rt_str_eq(key, "require_sim_pass")) {
    g_studio_toml.require_sim_pass = li_rt_studio_toml_parse_bool_value(p);
    return 1;
  }
  if (li_rt_str_eq(key, "printer_profile")) {
    char buf[128];
    if (li_rt_studio_toml_parse_quoted_value(p, buf, sizeof(buf)) != 1) {
      if (li_rt_studio_toml_parse_unquoted_token(p, buf, sizeof(buf)) != 1) {
        return 0;
      }
    }
    g_studio_toml.printer_profile_slot = li_rt_studio_toml_printer_slot_for_path(buf);
    return g_studio_toml.printer_profile_slot == 0 ? 0 : 1;
  }
  return 0;
}

int32_t li_rt_studio_toml_parse_line(const char* line) {
  if (line == NULL) {
    return 0;
  }
  const char* p = li_rt_studio_toml_skip_ws(line);
  if (p == NULL || *p == '\0' || *p == '#') {
    return 0;
  }
  if (*p == '[') {
    if (strstr(p, "[engine.export]") != NULL) {
      g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_EXPORT;
      return 1;
    }
    if (strstr(p, "[engine]") != NULL) {
      g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_ENGINE;
      return 1;
    }
    return 0;
  }
  if (g_studio_toml.section == LI_RT_STUDIO_TOML_SECTION_ENGINE ||
      g_studio_toml.section == LI_RT_STUDIO_TOML_SECTION_NONE) {
    if (li_rt_studio_toml_parse_key_value(line, "profile") == 1) {
      g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_ENGINE;
      return 1;
    }
    if (li_rt_studio_toml_parse_key_value(line, "determinism_tier") == 1) {
      g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_ENGINE;
      return 1;
    }
  }
  if (g_studio_toml.section == LI_RT_STUDIO_TOML_SECTION_EXPORT ||
      g_studio_toml.section == LI_RT_STUDIO_TOML_SECTION_NONE) {
    if (li_rt_studio_toml_parse_key_value(line, "formats") == 1) {
      g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_EXPORT;
      return 1;
    }
    if (li_rt_studio_toml_parse_key_value(line, "require_sim_pass") == 1) {
      g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_EXPORT;
      return 1;
    }
    if (li_rt_studio_toml_parse_key_value(line, "printer_profile") == 1) {
      g_studio_toml.section = LI_RT_STUDIO_TOML_SECTION_EXPORT;
      return 1;
    }
  }
  return 0;
}

int32_t li_rt_studio_toml_parsed_profile(void) { return g_studio_toml.profile_id; }

int32_t li_rt_studio_toml_parsed_determinism_tier(void) { return g_studio_toml.determinism_tier; }

int32_t li_rt_studio_toml_parsed_export_format_mask(void) {
  return g_studio_toml.export_format_mask;
}

int32_t li_rt_studio_toml_parsed_require_sim_pass(void) {
  return g_studio_toml.require_sim_pass;
}

int32_t li_rt_studio_toml_parsed_printer_profile_slot(void) {
  return g_studio_toml.printer_profile_slot;
}


int32_t li_rt_studio_demo_profile_from_env(void) {
  const char* v = getenv("STUDIO_DEMO_PROFILE");
  if (v == NULL || v[0] == '\0') {
    return 1;
  }
  const int32_t id = li_rt_studio_profile_match_name(v);
  if (id == 0) {
    return 1;
  }
  return id;
}

int32_t li_rt_studio_demo_frames_from_env(void) {
  const char* v = getenv("STUDIO_DEMO_FRAMES");
  if (v == NULL || v[0] == '\0') {
    return 3;
  }
  const int n = atoi(v);
  if (n < 1) {
    return 1;
  }
  if (n > 64) {
    return 64;
  }
  return (int32_t)n;
}

static int32_t li_rt_studio_env_flag_one(const char* name);

int32_t li_rt_studio_bench_mode_from_env(void) {
  return li_rt_studio_env_flag_one("STUDIO_BENCH_MODE");
}

static int32_t g_studio_demo_loop_tick = 0;

int32_t li_rt_studio_demo_loop_tick_from_env(void) {
  const char* v = getenv("STUDIO_DEMO_LOOP_TICK");
  if (v != NULL && v[0] != '\0') {
    const int n = atoi(v);
    if (n < 0) {
      return 0;
    }
    if (n > 1000000) {
      return 1000000;
    }
    return (int32_t)n;
  }
  if (li_rt_studio_env_flag_one("STUDIO_DEMO_LOOP_AUTO")) {
    const int32_t t = g_studio_demo_loop_tick;
    g_studio_demo_loop_tick = (t >= 1000000) ? 0 : t + 1;
    return t;
  }
  return 0;
}

static int32_t li_rt_studio_env_flag_one(const char* name) {
  const char* v = getenv(name);
  return (v != NULL && v[0] == '1' && v[1] == '\0') ? 1 : 0;
}

static int32_t g_studio_shell_pointer_down = 0;
static float g_studio_shell_pointer_x = 0.0f;
static float g_studio_shell_pointer_y = 0.0f;
static int32_t g_studio_shell_key_escape = 0;
static int32_t g_studio_shell_key_cmd_k = 0;
static int32_t g_studio_shell_key_digit = 0;

static void li_rt_studio_shell_input_apply_env(void) {
  g_studio_shell_pointer_down = 0;
  g_studio_shell_pointer_x = 0.0f;
  g_studio_shell_pointer_y = 0.0f;
  g_studio_shell_key_escape = 0;
  g_studio_shell_key_cmd_k = 0;
  g_studio_shell_key_digit = 0;

  g_studio_shell_pointer_down = li_rt_studio_env_flag_one("STUDIO_SHELL_POINTER_DOWN");
  const char* px = getenv("STUDIO_SHELL_POINTER_X");
  if (px != NULL && px[0] != '\0') {
    g_studio_shell_pointer_x = (float)atof(px);
  }
  const char* py = getenv("STUDIO_SHELL_POINTER_Y");
  if (py != NULL && py[0] != '\0') {
    g_studio_shell_pointer_y = (float)atof(py);
  }
  g_studio_shell_key_escape = li_rt_studio_env_flag_one("STUDIO_SHELL_KEY_ESCAPE");
  g_studio_shell_key_cmd_k = li_rt_studio_env_flag_one("STUDIO_SHELL_KEY_CMD_K");
  const char* digit = getenv("STUDIO_SHELL_KEY_DIGIT");
  if (digit != NULL && digit[0] != '\0') {
    const int d = atoi(digit);
    if (d >= 1 && d <= 5) {
      g_studio_shell_key_digit = d;
    }
  }

  const char* mock = getenv("STUDIO_SHELL_INPUT_MOCK");
  if (mock != NULL && mock[0] != '\0') {
    if (strstr(mock, "cmd_k") != NULL) {
      g_studio_shell_key_cmd_k = 1;
    }
    if (strstr(mock, "escape") != NULL) {
      g_studio_shell_key_escape = 1;
    }
    const char* digit_mock = strstr(mock, "digit=");
    if (digit_mock != NULL) {
      const int d = atoi(digit_mock + 6);
      if (d >= 1 && d <= 5) {
        g_studio_shell_key_digit = d;
      }
    }
  }
}

/* PH-HW HW-1 — lig.present trusted edge (SDL host; wgpu-rs readback not in-tree). */
#define LI_RT_LIG_PIXEL_SOURCE_NONE 0
#define LI_RT_LIG_PIXEL_SOURCE_HOST_CPU 1
#define LI_RT_LIG_PIXEL_SOURCE_PAINT_BLIT 2
#define LI_RT_LIG_PIXEL_SOURCE_WGPU_READBACK 3
#define LI_RT_LIG_PIXEL_SOURCE_WGPU_DRAW_LIST 4

static int32_t g_lig_host_present_active = 0;
static int32_t g_lig_native_pixels = 0;
static int32_t g_lig_native_pixel_source = LI_RT_LIG_PIXEL_SOURCE_NONE;
static float g_lig_present_dt_ms = 16.667f;
static int32_t g_lig_surface_ok = 0;

static int32_t li_rt_lig_env_host_present(void) {
  const char* v = getenv("LIG_HOST_PRESENT");
  return (v != NULL && v[0] == '1' && v[1] == '\0') ? 1 : 0;
}

static int32_t li_rt_lig_env_wgpu_readback(void) {
  const char* v = getenv("LIG_WGPU_READBACK");
  return (v != NULL && v[0] == '1' && v[1] == '\0') ? 1 : 0;
}

static void li_rt_lig_refresh_host_active(void) {
  g_lig_host_present_active = li_rt_lig_env_host_present();
}

static int32_t li_rt_lig_try_sdl_present_host(int32_t viewport_w, int32_t viewport_h) {
  const char* bin = getenv("STUDIO_SHELL_PRESENT_HOST_BIN");
  if (bin == NULL || bin[0] == '\0') {
    return 0;
  }
  if (viewport_w <= 0 || viewport_h <= 0) {
    return 0;
  }
  char cmd[640];
  snprintf(cmd, sizeof(cmd), "%s --width %d --height %d", bin, (int)viewport_w, (int)viewport_h);
  if (system(cmd) != 0) {
    return 0;
  }
  g_lig_native_pixels = 1;
  g_lig_native_pixel_source = LI_RT_LIG_PIXEL_SOURCE_HOST_CPU;
  g_lig_surface_ok = 1;
  g_lig_present_dt_ms = 16.667f;
  return 1;
}

static int32_t li_rt_lig_profile_tag_h_px(int32_t profile_id) {
  switch (profile_id) { case 1: return 21; case 2: return 22; case 3: return 23; case 4: return 24; case 5: return 25; case 6: return 26; case 7: return 27; default: return 0; }
}
int32_t li_rt_lig_present_blit_rgba8(int32_t viewport_w, int32_t viewport_h, int32_t profile_id, int32_t paint_cmd_count, int32_t tag_h_px) {
  li_rt_lig_refresh_host_active();
  if (!g_lig_host_present_active || viewport_w <= 0 || viewport_h <= 0 || paint_cmd_count <= 0) return 0;
  if (li_rt_lig_profile_tag_h_px(profile_id) != tag_h_px) return 0;
  g_lig_native_pixels = 1; g_lig_native_pixel_source = LI_RT_LIG_PIXEL_SOURCE_PAINT_BLIT; g_lig_surface_ok = 1; g_lig_present_dt_ms = 16.667f; return 1;
}

int32_t li_rt_lig_wgpu_readback_active(void) {
  li_rt_lig_refresh_host_active();
  if (!g_lig_host_present_active) {
    return 0;
  }
  return li_rt_lig_env_wgpu_readback();
}

int32_t li_rt_lig_wgpu_readback_stub(int32_t viewport_w, int32_t viewport_h, int32_t profile_id, int32_t paint_cmd_count, int32_t tag_h_px) {
  li_rt_lig_refresh_host_active();
  if (!li_rt_lig_env_wgpu_readback()) {
    return 0;
  }
  if (!g_lig_host_present_active || viewport_w <= 0 || viewport_h <= 0 || paint_cmd_count <= 0) {
    return 0;
  }
  if (li_rt_lig_profile_tag_h_px(profile_id) != tag_h_px) {
    return 0;
  }
  g_lig_native_pixels = 1;
  g_lig_native_pixel_source = LI_RT_LIG_PIXEL_SOURCE_WGPU_READBACK;
  g_lig_surface_ok = 1;
  g_lig_present_dt_ms = 16.667f;
  return 1;
}

int32_t li_rt_lig_wgpu_draw_list_submit(int32_t viewport_w, int32_t viewport_h, int32_t cmd_count, int32_t pbr_tag) {
  li_rt_lig_refresh_host_active();
  if (viewport_w <= 0 || viewport_h <= 0 || cmd_count <= 0) {
    return 0;
  }
  if (pbr_tag < 21 || pbr_tag > 27) {
    return 0;
  }
  if (g_lig_host_present_active) {
    g_lig_native_pixels = 1;
    g_lig_native_pixel_source = LI_RT_LIG_PIXEL_SOURCE_WGPU_DRAW_LIST;
    g_lig_surface_ok = 1;
    g_lig_present_dt_ms = 16.667f;
    return 1;
  }
  g_lig_surface_ok = 0;
  return 1;
}
int32_t li_rt_lig_host_present_active(void) {
  li_rt_lig_refresh_host_active();
  return g_lig_host_present_active;
}

float li_rt_lig_host_present_dt_ms(void) {
  li_rt_lig_refresh_host_active();
  if (g_lig_host_present_active) {
    return g_lig_present_dt_ms;
  }
  return 16.667f;
}

int32_t li_rt_lig_host_native_pixels(void) {
  li_rt_lig_refresh_host_active();
  if (!g_lig_host_present_active) {
    return 0;
  }
  return g_lig_native_pixels;
}
int32_t li_rt_lig_host_native_pixel_source(void) {
  li_rt_lig_refresh_host_active();
  if (!g_lig_host_present_active) return LI_RT_LIG_PIXEL_SOURCE_NONE;
  return g_lig_native_pixel_source;
}

int32_t li_rt_lig_wgpu_swapchain_create(int32_t viewport_w, int32_t viewport_h) {
  li_rt_lig_refresh_host_active();
  if (viewport_w <= 0 || viewport_h <= 0) {
    g_lig_surface_ok = 0;
    return 0;
  }
  if (g_lig_host_present_active) {
    if (li_rt_lig_try_sdl_present_host(viewport_w, viewport_h)) {
      return 1;
    }
    g_lig_surface_ok = 1;
    return 1;
  }
  g_lig_surface_ok = 0;
  return 1;
}

int32_t li_rt_lig_wgpu_present_frame(int32_t swapchain_ok) {
  li_rt_lig_refresh_host_active();
  if (!swapchain_ok) {
    return 0;
  }
  if (g_lig_host_present_active && g_lig_surface_ok) {
    g_lig_present_dt_ms = 16.667f;
    if (g_lig_native_pixel_source == LI_RT_LIG_PIXEL_SOURCE_NONE) g_lig_native_pixels = 0;
    return 1;
  }
  g_lig_native_pixels = 0; g_lig_native_pixel_source = LI_RT_LIG_PIXEL_SOURCE_NONE;
  return 1;
}

int32_t li_rt_studio_shell_input_pointer_down(void) {
  return g_studio_shell_pointer_down;
}
float li_rt_studio_shell_input_pointer_x(void) {
  return g_studio_shell_pointer_x;
}
float li_rt_studio_shell_input_pointer_y(void) {
  return g_studio_shell_pointer_y;
}
int32_t li_rt_studio_shell_input_key_escape(void) {
  return g_studio_shell_key_escape;
}
int32_t li_rt_studio_shell_input_key_cmd_k(void) {
  return g_studio_shell_key_cmd_k;
}
int32_t li_rt_studio_shell_input_key_digit(void) {
  return g_studio_shell_key_digit;
}

int32_t li_rt_studio_host_present_tick(int32_t viewport_w, int32_t viewport_h) {
  li_rt_studio_shell_input_apply_env();
  (void)li_rt_lig_wgpu_swapchain_create(viewport_w, viewport_h);
  return li_rt_lig_wgpu_present_frame(viewport_w > 0 && viewport_h > 0 ? 1 : 0);
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
  li_rt_lig_refresh_host_active();
  if (g_lig_host_present_active && g_lig_surface_ok) {
    return 1;
  }
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

static int32_t li_rt_world_path_safe(const char* path) {
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  if (strstr(path, "..") != NULL) {
    return 0;
  }
  return 1;
}

int32_t li_rt_world_write_path(const char* path, int32_t name_slot, int32_t tick, int32_t entity_count) {
  if (!li_rt_world_path_safe(path)) {
    return 0;
  }
  const char* line = li_rt_world_serialize_slot(name_slot, tick, entity_count);
  FILE* f = fopen(path, "w");
  if (f == NULL) {
    return 0;
  }
  if (fprintf(f, "%s\n", line) < 0) {
    fclose(f);
    return 0;
  }
  if (fclose(f) != 0) {
    return 0;
  }
  return 1;
}

int32_t li_rt_world_read_path(const char* path) {
  if (!li_rt_world_path_safe(path)) {
    return 0;
  }
  FILE* f = fopen(path, "r");
  if (f == NULL) {
    return 0;
  }
  char buf[LI_RT_WORLD_LINE_MAX];
  if (fgets(buf, sizeof(buf), f) == NULL) {
    fclose(f);
    return 0;
  }
  fclose(f);
  size_t n = strlen(buf);
  while (n > 0 && (buf[n - 1] == '\n' || buf[n - 1] == '\r')) {
    buf[--n] = '\0';
  }
  return li_rt_world_parse_line(buf);
}

int32_t li_rt_world_file_roundtrip_path(const char* path, int32_t name_slot, int32_t tick,
                                        int32_t entity_count) {
  if (li_rt_world_write_path(path, name_slot, tick, entity_count) != 1) {
    return 0;
  }
  if (li_rt_world_read_path(path) != 1) {
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

const char* li_rt_world_checkpoint_path_default(void) {
  const char* v = getenv("LI_WORLD_CHECKPOINT_PATH");
  if (v != NULL && v[0] != '\0' && li_rt_world_path_safe(v)) {
    return v;
  }
  return "/tmp/li_world_checkpoint.li";
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
