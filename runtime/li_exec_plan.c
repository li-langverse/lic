#include "li_exec_plan.h"

#include "li_comm_plan.h"
#include "li_dpar.h"
#include "li_parallel.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak))
#endif
const LiExecPlan __li_exec_plan = {
    0u,
    LI_EXEC_PLAN_VERSION,
    0,
    0,
    "",
    0u,
    0u,
};

#define LI_EXEC_TEAM_STACK 16

static int g_saved_team[LI_EXEC_TEAM_STACK];
static int g_team_depth = 0;

void li_exec_plan_apply(void) {
  if (__li_exec_plan.magic != LI_EXEC_PLAN_MAGIC) {
    return;
  }
  if (__li_exec_plan.team_cores > 0) {
    li_par_pool_set_team_size(__li_exec_plan.team_cores);
  }
  if (__li_exec_plan.cluster_world > 0) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%d", __li_exec_plan.cluster_world);
#if defined(_WIN32)
    _putenv_s("LI_DPAR_WORLD_SIZE", buf);
#else
    setenv("LI_DPAR_WORLD_SIZE", buf, 0);
#endif
  }
  if (__li_exec_plan.cluster_hosts[0] != '\0') {
#if defined(_WIN32)
    _putenv_s("LI_DPAR_HOSTS", __li_exec_plan.cluster_hosts);
#else
    setenv("LI_DPAR_HOSTS", __li_exec_plan.cluster_hosts, 0);
#endif
  }
  if (__li_exec_plan.cluster_world > 0 || __li_exec_plan.cluster_hosts[0] != '\0') {
    (void)li_dpar_init_from_env();
  }
}

void li_exec_team_push(int cores) {
  if (cores <= 0) {
    cores = li_par_pool_team_size();
  }
  if (g_team_depth < LI_EXEC_TEAM_STACK) {
    g_saved_team[g_team_depth] = li_par_pool_team_size();
    g_team_depth++;
  }
  li_par_pool_set_team_size(cores);
}

void li_exec_team_pop(void) {
  if (g_team_depth <= 0) {
    li_par_pool_set_team_size(0);
    return;
  }
  g_team_depth--;
  li_par_pool_set_team_size(g_saved_team[g_team_depth]);
}

void li_exec_overlap_comm(void) {
  li_comm_overlap_region();
}
