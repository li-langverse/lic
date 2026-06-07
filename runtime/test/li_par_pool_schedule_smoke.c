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

static int run_schedule(LiParScheduleKind schedule, const char* name) {
  memset((void*)g_seen, 0, sizeof(g_seen));
  g_count = 0;

  li_par_pool_set_team_size(4);
  li_par_pool_set_schedule(schedule);
  li_par_pool_set_chunk_size(7);
  li_parallel_for_i64(0, 64, mark_body, 4);

  if (g_count != 64) {
    fprintf(stderr, "li_par_pool_schedule_smoke[%s]: expected 64 iterations, got %d\n", name,
            g_count);
    return 1;
  }
  for (int i = 0; i < 64; ++i) {
    if (!g_seen[i]) {
      fprintf(stderr, "li_par_pool_schedule_smoke[%s]: missing index %d\n", name, i);
      return 1;
    }
  }
  return 0;
}

int main(void) {
  if (run_schedule(LI_PAR_SCHED_DYNAMIC, "dynamic") != 0) {
    return 1;
  }
  if (run_schedule(LI_PAR_SCHED_GUIDED, "guided") != 0) {
    return 1;
  }

  li_par_pool_set_schedule(LI_PAR_SCHED_STATIC);
  li_par_pool_shutdown();
  printf("li_par_pool_schedule_smoke: ok\n");
  return 0;
}
