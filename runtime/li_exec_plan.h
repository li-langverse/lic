#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LI_EXEC_PLAN_MAGIC 0x5045494cu /* 'LIEP' */
#define LI_EXEC_PLAN_VERSION 1u

typedef struct LiExecPlan {
  uint32_t magic;
  uint32_t version;
  int32_t team_cores;
  int32_t cluster_world;
  char cluster_hosts[512];
  uint32_t offload_count;
  uint32_t overlap_comm_count;
} LiExecPlan;

extern const LiExecPlan __li_exec_plan;

void li_exec_plan_apply(void);
void li_exec_team_push(int cores);
void li_exec_team_pop(void);
void li_exec_overlap_comm(void);

#ifdef __cplusplus
}
#endif
