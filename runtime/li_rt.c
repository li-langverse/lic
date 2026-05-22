#include "li_rt.h"

#include <math.h>
#include <stdlib.h>
#include <string.h>

#if defined(_OPENMP)
#include <omp.h>
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

void li_omp_parallel_for_i64(long long start, long long end,
                             void (*body)(long long)) {
#if defined(_OPENMP)
  long long n = end - start;
  if (n <= 0) {
    return;
  }
  const char* nt = getenv("LI_OMP_THREADS");
  if (nt && *nt) {
    int threads = atoi(nt);
    if (threads > 0) {
      omp_set_num_threads(threads);
    }
  }
#pragma omp parallel for schedule(static)
  for (long long i = start; i < end; ++i) {
    body(i);
  }
#else
  for (long long i = start; i < end; ++i) {
    body(i);
  }
#endif
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

int32_t li_async_await_i32(int32_t pending) {
  (void)li_async_poll(0u);
  return pending;
}

int32_t li_async_poll(uint32_t slot) {
  (void)slot;
  return 1;
}
