/* WP-PAR-17 — scoped team(cores=N) push/pop restores outer team size. */
#include "li_exec_plan.h"
#include "li_parallel.h"

#include <stdio.h>
#include <stdlib.h>

int main(void) {
  li_par_pool_set_team_size(8);
  if (li_par_pool_team_size() != 8) {
    fprintf(stderr, "li_exec_team_scope_smoke: expected outer team 8, got %d\n",
            li_par_pool_team_size());
    return 1;
  }

  li_exec_team_push(2);
  if (li_par_pool_team_size() != 2) {
    fprintf(stderr, "li_exec_team_scope_smoke: expected inner team 2, got %d\n",
            li_par_pool_team_size());
    return 1;
  }

  li_exec_team_push(0);
  if (li_par_pool_team_size() != 2) {
    fprintf(stderr, "li_exec_team_scope_smoke: team(cores=0) should inherit inner team, got %d\n",
            li_par_pool_team_size());
    return 1;
  }
  li_exec_team_pop();

  li_exec_team_pop();
  if (li_par_pool_team_size() != 8) {
    fprintf(stderr, "li_exec_team_scope_smoke: expected restored team 8, got %d\n",
            li_par_pool_team_size());
    return 1;
  }

  li_exec_team_pop();
  if (li_par_pool_team_size() <= 0) {
    fprintf(stderr, "li_exec_team_scope_smoke: pop past root should fall back to auto cores\n");
    return 1;
  }

  li_par_pool_shutdown();
  printf("li_exec_team_scope_smoke: ok (outer=8 inner=2 auto-inherit cores=%d max=%d)\n",
         li_par_pool_team_size(), li_par_max_threads());
  return 0;
}
