/* WP-UX-14b Step 1: PPM capture via shared shell paint layout (grandfathered C paint until Step 4). */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../deploy/studio-demo/native/studio_shell_paint_fb.c"

int32_t li_rt_studio_shell_paint_ppm(
    const char* path, int32_t width, int32_t height, int32_t profile_id, int32_t has_selection,
    float playhead_pct) {
  if (path == NULL || path[0] == '\0' || width <= 0 || height <= 0) {
    return 0;
  }
  const ShellProfileVisual* profile = shell_profile_find(profile_id);
  if (profile == NULL) {
    return 0;
  }
  const size_t nbytes = (size_t)width * (size_t)height * 3u;
  unsigned char* rgb = (unsigned char*)malloc(nbytes);
  if (rgb == NULL) {
    return 0;
  }
  shell_paint_frame(rgb, width, height, profile, has_selection, playhead_pct);
  FILE* f = fopen(path, "wb");
  if (f == NULL) {
    free(rgb);
    return 0;
  }
  fprintf(f, "P6\n%d %d\n255\n", (int)width, (int)height);
  if (fwrite(rgb, 1, nbytes, f) != nbytes) {
    fclose(f);
    free(rgb);
    return 0;
  }
  fclose(f);
  free(rgb);
  return 1;
}
