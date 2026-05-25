#include "../common/reduce_parallel_core.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned parse_threads(int argc, char** argv) {
  for (int i = 1; i < argc; ++i) {
    if (strncmp(argv[i], "--threads=", 10) == 0) {
      const int n = atoi(argv[i] + 10);
      return n > 0 ? (unsigned)n : 1u;
    }
  }
  const char* env = getenv("LI_OMP_THREADS");
  if (env && env[0]) {
    const int n = atoi(env);
    return n > 0 ? (unsigned)n : 1u;
  }
  return 1u;
}

int main(int argc, char** argv) {
  const unsigned threads = parse_threads(argc, argv);
  li_reduce_parallel_kernel(threads);
  const double checksum = li_reduce_parallel_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {
    printf("%.17g\n", checksum);
    return 0;
  }
  (void)checksum;
  return 0;
}
