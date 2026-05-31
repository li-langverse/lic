/* WP-UX-14b: PPM capture retired from lic — native paint hosts live in studio repo. */
#include <stdint.h>

int32_t li_rt_studio_shell_paint_ppm(
    const char* path, int32_t width, int32_t height, int32_t profile_id, int32_t has_selection,
    float playhead_pct) {
  (void)path;
  (void)width;
  (void)height;
  (void)profile_id;
  (void)has_selection;
  (void)playhead_pct;
  /* Product capture moved to github.com/li-langverse/studio (deploy/studio-demo/native). */
  return 0;
}
