#include "li_parallel.h"

#include <stdio.h>
#include <string.h>

static volatile long long g_seen[256];
static int g_count;

static void mark_body(long long i) {
  if (i >= 0 && i < 256) {
    g_seen[i] = 1;
  }
  __sync_fetch_and_add(&g_count, 1);
}

int main(void) {
  memset((void*)g_seen, 0, sizeof(g_seen));
  g_count = 0;

  li_par_pool_set_team_size(4);
  li_parallel_for_i64(0, 64, mark_body, 4);

  if (g_count != 64) {
    fprintf(stderr, "li_par_pool_smoke: expected 64 iterations, got %d\n", g_count);
    return 1;
  }
  for (int i = 0; i < 64; ++i) {
    if (!g_seen[i]) {
      fprintf(stderr, "li_par_pool_smoke: missing index %d\n", i);
      return 1;
    }
  }

  li_par_pool_shutdown();
  printf("li_par_pool_smoke: ok\n");
  return 0;
}
