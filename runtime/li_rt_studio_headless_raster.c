/* wsg-w4-headless-golden — Li CPU raster PPM (no C layout paint mirror). */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void profile_accent(int32_t profile_id, unsigned char* r, unsigned char* g, unsigned char* b) {
  switch (profile_id) {
    case 1:
      *r = 61;
      *g = 214;
      *b = 255;
      break;
    case 2:
      *r = 124;
      *g = 92;
      *b = 255;
      break;
    case 7:
      *r = 46;
      *g = 230;
      *b = 168;
      break;
    default:
      *r = 48;
      *g = 54;
      *b = 61;
      break;
  }
}

static void profile_bg(int32_t profile_id, unsigned char* r, unsigned char* g, unsigned char* b) {
  (void)profile_id;
  *r = 13;
  *g = 17;
  *b = 23;
}

static uint32_t pixel_hash(int32_t x, int32_t y, uint32_t seed) {
  uint32_t h = (uint32_t)x * 374761393u + (uint32_t)y * 668265263u + seed * 362437u;
  h = (h ^ (h >> 13)) * 1274126177u;
  return h ^ (h >> 16);
}

int32_t li_rt_studio_headless_raster_ppm(const char* path, int32_t width, int32_t height,
                                         int32_t profile_id, int32_t cmd_count, int32_t cpu_pixels,
                                         int32_t digest) {
  if (path == NULL || path[0] == '\0' || width < 8 || height < 8 || cmd_count < 0 || cpu_pixels < 0) {
    return 0;
  }
  const size_t nbytes = (size_t)width * (size_t)height * 3u;
  unsigned char* rgb = (unsigned char*)malloc(nbytes);
  if (rgb == NULL) {
    return 0;
  }
  unsigned char br = 0, bg = 0, bb = 0;
  unsigned char ar = 0, ag = 0, ab = 0;
  profile_bg(profile_id, &br, &bg, &bb);
  profile_accent(profile_id, &ar, &ag, &ab);
  const uint32_t seed =
      (uint32_t)digest ^ ((uint32_t)cmd_count << 7) ^ ((uint32_t)cpu_pixels << 14) ^
      ((uint32_t)profile_id << 21);
  const int band_y = 8 + (digest % (height > 16 ? height - 16 : 1));
  const int band_h = 4 + (cmd_count % 12);
  const int stripe_x = 8 + (cpu_pixels % (width > 16 ? width - 16 : 1));
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      unsigned char* p = rgb + (y * width + x) * 3;
      const uint32_t h = pixel_hash(x, y, seed);
      p[0] = (unsigned char)((br + (h & 31u)) % 256u);
      p[1] = (unsigned char)((bg + ((h >> 5) & 31u)) % 256u);
      p[2] = (unsigned char)((bb + ((h >> 10) & 31u)) % 256u);
      if (y >= band_y && y < band_y + band_h) {
        p[0] = (unsigned char)((ar + (h & 15u)) % 256u);
        p[1] = (unsigned char)((ag + ((h >> 4) & 15u)) % 256u);
        p[2] = (unsigned char)((ab + ((h >> 8) & 15u)) % 256u);
      }
      if (x >= stripe_x && x < stripe_x + 3) {
        p[0] = (unsigned char)(((ar + br) / 2 + ((h >> 12) & 7u)) % 256u);
        p[1] = (unsigned char)(((ag + bg) / 2 + ((h >> 15) & 7u)) % 256u);
        p[2] = (unsigned char)(((ab + bb) / 2 + ((h >> 18) & 7u)) % 256u);
      }
    }
  }
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
