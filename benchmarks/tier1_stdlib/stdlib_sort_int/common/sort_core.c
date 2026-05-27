#include "sort_core.h"

#include <stdlib.h>
#include <string.h>

enum { LI_SORT_N = 1000000 };

static int64_t* g_buf;
static double g_checksum;

static uint64_t xorshift64(uint64_t* state) {
  uint64_t x = *state;
  x ^= x >> 12;
  x ^= x << 25;
  x ^= x >> 27;
  *state = x;
  return x * 0x2545F4914F6CDD1DULL;
}

static int cmp_i64(const void* a, const void* b) {
  const int64_t x = *(const int64_t*)a;
  const int64_t y = *(const int64_t*)b;
  return (x > y) - (x < y);
}

__attribute__((noinline)) void li_stdlib_sort_kernel(void) {
  if (!g_buf) {
    g_buf = (int64_t*)malloc((size_t)LI_SORT_N * sizeof(int64_t));
    if (!g_buf) {
      g_checksum = 0.0;
      return;
    }
  }
  uint64_t rng = 0x9E3779B97F4A7C15ULL;
  for (int i = 0; i < LI_SORT_N; ++i) {
    g_buf[i] = (int64_t)(xorshift64(&rng) % 1000003ULL);
  }
  qsort(g_buf, (size_t)LI_SORT_N, sizeof(int64_t), cmp_i64);
  double acc = 0.0;
  for (int i = 0; i < LI_SORT_N; ++i) {
    acc += (double)g_buf[i];
  }
  g_checksum = acc;
}

double li_stdlib_sort_checksum(void) { return g_checksum; }
