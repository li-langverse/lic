#include "game_world_core.h"

#include "../../../harness/bench_quick.h"

#include <string.h>

/* SoA entity tick — mirrors li-world GW-1 (10k entity budget, 64-wide chunks). */
#define LI_GW_ENTITY_BUDGET_FULL 10240
#define LI_GW_ENTITY_BUDGET_QUICK 2048
#define LI_GW_CHUNK 64
#define LI_GW_TICKS_FULL 600
#define LI_GW_TICKS_QUICK 120
#define LI_GW_DT 0.016

static double g_li_game_world_checksum;

static int li_gw_entity_budget(void) {
  return li_bench_pick_int(LI_GW_ENTITY_BUDGET_QUICK, LI_GW_ENTITY_BUDGET_FULL);
}

static int li_gw_ticks(void) {
  return li_bench_pick_int(LI_GW_TICKS_QUICK, LI_GW_TICKS_FULL);
}

static int li_gw_tick_chunk(
    int* entity_ids, float* pos_x, float* pos_y, int filled, float dt) {
  int i = 0;
  while (i < filled) {
    if (entity_ids[i] > 0) {
      pos_x[i] = pos_x[i] + dt;
      pos_y[i] = pos_y[i] + dt * 0.5f;
    }
    ++i;
  }
  return filled;
}

__attribute__((noinline)) void li_game_world_soa_kernel(void) {
  const int budget = li_gw_entity_budget();
  const int chunks = budget / LI_GW_CHUNK;
  const int ticks = li_gw_ticks();

  int entity_ids[LI_GW_CHUNK];
  float pos_x[LI_GW_CHUNK];
  float pos_y[LI_GW_CHUNK];
  int filled = 0;
  while (filled < LI_GW_CHUNK) {
    entity_ids[filled] = filled + 1;
    pos_x[filled] = (float)(filled % 8) * 0.1f;
    pos_y[filled] = 0.0f;
    ++filled;
  }

  double acc = 0.0;
  int t = 0;
  while (t < ticks) {
    int c = 0;
    while (c < chunks) {
      acc += (double)li_gw_tick_chunk(entity_ids, pos_x, pos_y, filled, (float)LI_GW_DT);
      ++c;
    }
    ++t;
  }
  g_li_game_world_checksum = acc;
}

double li_game_world_soa_checksum(void) { return g_li_game_world_checksum; }
