#include "search_core.h"

#include <stdint.h>
#include <stdlib.h>

enum { LI_BSEARCH_N = 1000000, LI_BSEARCH_QUERIES = 200000 };

static int64_t* g_sorted;
static double g_checksum;

__attribute__((noinline)) void li_stdlib_bsearch_kernel(void) {
  if (!g_sorted) {
    g_sorted = (int64_t*)malloc((size_t)LI_BSEARCH_N * sizeof(int64_t));
    if (!g_sorted) {
      g_checksum = 0.0;
      return;
    }
  }
  for (int i = 0; i < LI_BSEARCH_N; ++i) {
    g_sorted[i] = (int64_t)(i * 3 + (i % 7));
  }
  double acc = 0.0;
  for (int q = 0; q < LI_BSEARCH_QUERIES; ++q) {
    const int64_t target = (int64_t)((q * 7919) % LI_BSEARCH_N);
    int lo = 0;
    int hi = LI_BSEARCH_N - 1;
    int64_t found = -1;
    while (lo <= hi) {
      const int mid = lo + (hi - lo) / 2;
      const int64_t v = g_sorted[mid];
      if (v == target) {
        found = v;
        break;
      }
      if (v < target) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    acc += (double)found;
  }
  g_checksum = acc;
}

double li_stdlib_bsearch_checksum(void) { return g_checksum; }
