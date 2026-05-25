#include "num_rng_pcg_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { N = 10000000 };
static uint64_t state = 0x853c49e6748fea9bULL;
static double g_checksum;
static inline uint32_t pcg32(void) {
  const uint64_t old = state;
  state = old * 6364136223846793005ULL + 0xda3e39cb94b95bdbULL;
  const uint32_t xorshifted = (uint32_t)(((old >> 18u) ^ old) >> 27u);
  const uint32_t rot = (uint32_t)(old >> 59u);
  return (xorshifted >> rot) | (xorshifted << ((~rot + 1u) & 31u));
}
__attribute__((noinline)) void li_num_rng_pcg_kernel(void) {
  double acc = 0.0;
  for (int i = 0; i < N; ++i) {
    acc += (double)pcg32() * 1e-9;
  }
  g_checksum = acc;
}

double li_num_rng_pcg_checksum(void) { return g_checksum; }
