#include "li_rt.h"

#include <math.h>
#include <stdlib.h>

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

double li_rt_sqrt(double x) {
#if defined(_WIN32)
  return sqrt(x);
#else
  return __builtin_sqrt(x);
#endif
}
