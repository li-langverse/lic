#include "sim_phys_core.h"

#include "../../../harness/bench_quick.h"

/* Game physics frame: semi-implicit rigid + substeps (physics.runtime profile). */
#define LI_SP_BODIES_FULL 12
#define LI_SP_BODIES_QUICK 12
#define LI_SP_FRAMES_FULL 2000
#define LI_SP_FRAMES_QUICK 400
#define LI_SP_SUBSTEPS 4
#define LI_SP_DT (1.0f / 60.0f)
#define LI_SP_G -9.81f

static double g_li_sim_phys_checksum;

typedef struct LiSpBody {
  float px, py, pz;
  float vx, vy, vz;
  float inv_mass;
} LiSpBody;

static void li_sp_integrate(LiSpBody* b, float dt) {
  if (b->inv_mass > 0.0f) {
    b->vx += 0.0f * b->inv_mass * dt;
    b->vy += 0.0f * b->inv_mass * dt;
    b->vz += LI_SP_G * b->inv_mass * dt;
  }
  b->px += b->vx * dt;
  b->py += b->vy * dt;
  b->pz += b->vz * dt;
  if (b->py < 0.0f) {
    b->py = 0.0f;
    b->vy = 0.0f;
  }
}

__attribute__((noinline)) void li_sim_physics_frame_kernel(void) {
  const int bodies = li_bench_pick_int(LI_SP_BODIES_QUICK, LI_SP_BODIES_FULL);
  const int frames = li_bench_pick_int(LI_SP_FRAMES_QUICK, LI_SP_FRAMES_FULL);
  LiSpBody stack[12];
  int i = 0;
  while (i < bodies) {
    stack[i].px = (float)(i % 4) * 0.25f;
    stack[i].py = 1.0f + (float)i * 0.1f;
    stack[i].pz = 0.0f;
    stack[i].vx = 0.0f;
    stack[i].vy = 0.0f;
    stack[i].vz = 0.0f;
    stack[i].inv_mass = 1.0f;
    ++i;
  }
  int f = 0;
  while (f < frames) {
    const float sub_dt = LI_SP_DT / (float)LI_SP_SUBSTEPS;
    int s = 0;
    while (s < LI_SP_SUBSTEPS) {
      int b = 0;
      while (b < bodies) {
        li_sp_integrate(&stack[b], sub_dt);
        ++b;
      }
      ++s;
    }
    ++f;
  }
  g_li_sim_phys_checksum = stack[bodies - 1].py;
}

double li_sim_physics_frame_checksum(void) { return g_li_sim_phys_checksum; }
