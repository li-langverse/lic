#include "render_present_core.h"

#include "../../../harness/bench_quick.h"

/* Present path: RGBA fill + fake swapchain (li-render PH-GD-5). */
#define LI_RF_WIDTH 1280
#define LI_RF_HEIGHT 720
#define LI_RF_FRAMES_FULL 600
#define LI_RF_FRAMES_QUICK 120

static double g_li_render_present_checksum;

__attribute__((noinline)) void li_render_frame_present_kernel(void) {
  const int frames = li_bench_pick_int(LI_RF_FRAMES_QUICK, LI_RF_FRAMES_FULL);
  const int pixels = LI_RF_WIDTH * LI_RF_HEIGHT;
  unsigned int acc = 0;
  int f = 0;
  while (f < frames) {
    int i = 0;
    while (i < pixels) {
      const unsigned int v = (unsigned int)((f + i) % 251);
      acc = acc + v;
      ++i;
    }
    ++f;
  }
  g_li_render_present_checksum = (double)acc;
}

double li_render_frame_present_checksum(void) {
  return g_li_render_present_checksum;
}
