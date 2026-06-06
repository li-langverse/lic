#include "li_dpar.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static volatile long long g_seen[256];
static int g_count;

static void mark_body(long long i) {
  if (i >= 0 && i < 256) {
    g_seen[i] = 1;
  }
  ++g_count;
}

int main(void) {
  memset((void*)g_seen, 0, sizeof(g_seen));
  g_count = 0;

  setenv("LI_DPAR_RANK", "0", 1);
  setenv("LI_DPAR_WORLD_SIZE", "1", 1);
  li_distributed_for_i64(0, 64, mark_body);

  if (g_count != 64) {
    fprintf(stderr, "li_dpar_for_smoke: expected 64 iterations, got %d\n", g_count);
    return 1;
  }
  for (int i = 0; i < 64; ++i) {
    if (!g_seen[i]) {
      fprintf(stderr, "li_dpar_for_smoke: missing index %d\n", i);
      return 1;
    }
  }

  li_dpar_finalize();
  printf("li_dpar_for_smoke: ok\n");
  return 0;
}
