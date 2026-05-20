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

int32_t bytes_len(const char* b) {
  if (b == NULL) {
    return 0;
  }
  return (int32_t)strlen(b);
}

const char* bytes_slice(const char* b, int32_t off, int32_t n) {
  if (b == NULL) {
    if (off != 0 || n != 0) {
      li_panic("bytes_slice: out of bounds");
    }
    return "";
  }
  const int32_t len = bytes_len(b);
  if (off < 0 || n < 0 || off > len || off + n > len) {
    li_panic("bytes_slice: out of bounds");
  }
  if (n == 0) {
    return "";
  }
  char* out = (char*)malloc((size_t)n + 1u);
  if (out == NULL) {
    li_panic("bytes_slice: alloc failed");
  }
  memcpy(out, b + off, (size_t)n);
  out[n] = '\0';
  return out;
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
