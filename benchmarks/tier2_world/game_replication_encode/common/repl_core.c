#include "repl_core.h"

#include "../../../harness/bench_quick.h"

/* Replication delta encode — GW-2 competitive metric (delta bytes vs full snapshot). */
#define LI_GR_ENTITIES_FULL 1000
#define LI_GR_ENTITIES_QUICK 200
#define LI_GR_BYTES_PER_ENTITY 128
#define LI_GR_ROUNDS_FULL 500
#define LI_GR_ROUNDS_QUICK 100

static double g_li_game_repl_checksum;

static int li_gr_popcount(int mask) {
  int bits = 0;
  int i = 0;
  while (i < 16) {
    if (mask % 2 == 1) {
      ++bits;
    }
    mask = mask / 2;
    ++i;
  }
  return bits;
}

static int li_gr_delta_bytes(int component_mask) {
  return 12 + li_gr_popcount(component_mask) * 8;
}

__attribute__((noinline)) void li_game_repl_kernel(void) {
  const int n = li_bench_pick_int(LI_GR_ENTITIES_QUICK, LI_GR_ENTITIES_FULL);
  const int rounds = li_bench_pick_int(LI_GR_ROUNDS_QUICK, LI_GR_ROUNDS_FULL);
  const int full_snapshot = n * LI_GR_BYTES_PER_ENTITY + 32;

  long long delta_total = 0;
  int r = 0;
  while (r < rounds) {
    int e = 1;
    while (e <= n) {
      const int mask = 7 + (e % 5);
      delta_total += li_gr_delta_bytes(mask);
      ++e;
    }
    ++r;
  }
  /* Checksum = compression ratio proxy (full/delta); stable for --verify. */
  if (delta_total < 1) {
    g_li_game_repl_checksum = 0.0;
    return;
  }
  g_li_game_repl_checksum = (double)full_snapshot / (double)delta_total;
}

double li_game_repl_checksum(void) { return g_li_game_repl_checksum; }
