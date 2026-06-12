/* wsg-w4-headless-golden — Li CPU raster PPM (no C layout paint mirror). */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

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

static int32_t li_rt_il_pe_demo_active(void) {
  const char* id = getenv("STUDIO_AIMD_SYSTEM_ID");
  return (id != NULL && strcmp(id, "il_pe_depolymerization") == 0) ? 1 : 0;
}

static uint32_t li_rt_viz_lcg(uint32_t* state) {
  *state = (*state * 1664525u) + 1013904223u;
  return *state;
}

static void li_rt_blend_pixel(unsigned char* p, unsigned char r, unsigned char g, unsigned char b,
                              float alpha) {
  if (alpha < 0.0f) {
    alpha = 0.0f;
  }
  if (alpha > 1.0f) {
    alpha = 1.0f;
  }
  const float inv = 1.0f - alpha;
  p[0] = (unsigned char)((float)p[0] * inv + (float)r * alpha);
  p[1] = (unsigned char)((float)p[1] * inv + (float)g * alpha);
  p[2] = (unsigned char)((float)p[2] * inv + (float)b * alpha);
}

static void li_rt_paint_disc(unsigned char* rgb, int32_t width, int32_t height, int32_t cx, int32_t cy,
                             int32_t radius, unsigned char r, unsigned char g, unsigned char b) {
  if (radius < 1) {
    radius = 1;
  }
  const int32_t r2 = radius * radius;
  for (int32_t dy = -radius; dy <= radius; dy++) {
    const int32_t y = cy + dy;
    if (y < 0 || y >= height) {
      continue;
    }
    for (int32_t dx = -radius; dx <= radius; dx++) {
      const int32_t x = cx + dx;
      if (x < 0 || x >= width) {
        continue;
      }
      const int32_t d2 = dx * dx + dy * dy;
      if (d2 > r2) {
        continue;
      }
      float alpha = 1.0f - (float)d2 / (float)r2;
      alpha = 0.35f + 0.65f * alpha;
      unsigned char* p = rgb + (y * width + x) * 3;
      li_rt_blend_pixel(p, r, g, b, alpha);
    }
  }
}

static void li_rt_paint_il_pe_field(unsigned char* rgb, int32_t width, int32_t height, int32_t digest,
                                    int32_t seed) {
  const int32_t cx = width / 2 + (digest % 41) - 20;
  const int32_t cy = height / 2 + ((digest / 7) % 31) - 15;
  uint32_t rng = (uint32_t)(seed ^ (digest * 2654435761u) ^ 0xC0FFEEu);

  /* Thermal glow — hot PE destruction at 450 K */
  for (int32_t ring = 12; ring >= 1; ring--) {
    const float t = (float)ring / 12.0f;
    const unsigned char gr = (unsigned char)(255.0f * (1.0f - t * 0.55f));
    const unsigned char gg = (unsigned char)(6.0f + 80.0f * t);
    const unsigned char gb = (unsigned char)(110.0f * t);
    li_rt_paint_disc(rgb, width, height, cx, cy, ring * (width > height ? width : height) / 14, gr, gg,
                     gb);
  }

  /* DMSO solvent — amber scatter */
  for (int32_t i = 0; i < 36; i++) {
    const int32_t x = (int32_t)(li_rt_viz_lcg(&rng) % (uint32_t)(width - 40)) + 20;
    const int32_t y = (int32_t)(li_rt_viz_lcg(&rng) % (uint32_t)(height - 40)) + 20;
    const int32_t shade = (int32_t)(li_rt_viz_lcg(&rng) % 40u);
    li_rt_paint_disc(rgb, width, height, x, y, 2 + (int32_t)(li_rt_viz_lcg(&rng) % 3u),
                     (unsigned char)(255 - shade / 2), (unsigned char)(183 - shade), (unsigned char)(3 + shade));
  }

  /* [EMIM]+ cation cluster — electric violet */
  for (int32_t i = 0; i < 14; i++) {
    const int32_t x = cx - 90 + (int32_t)(li_rt_viz_lcg(&rng) % 50u);
    const int32_t y = cy - 40 + (int32_t)(li_rt_viz_lcg(&rng) % 80u);
    const int32_t shade = (int32_t)(li_rt_viz_lcg(&rng) % 35u);
    li_rt_paint_disc(rgb, width, height, x, y, 3 + (int32_t)(li_rt_viz_lcg(&rng) % 2u),
                     (unsigned char)(155 + shade), (unsigned char)(93 + shade / 2),
                     (unsigned char)(229 - shade));
  }

  /* [OAc]- anion — seafoam, attacking PE mid-chain */
  for (int32_t i = 0; i < 10; i++) {
    const int32_t x = cx - 20 + (int32_t)(li_rt_viz_lcg(&rng) % 60u);
    const int32_t y = cy - 10 + (int32_t)(li_rt_viz_lcg(&rng) % 40u);
    const int32_t shade = (int32_t)(li_rt_viz_lcg(&rng) % 30u);
    li_rt_paint_disc(rgb, width, height, x, y, 3,
                     (unsigned char)(shade / 2), (unsigned char)(245 - shade),
                     (unsigned char)(212 - shade / 2));
  }

  /* PE decamer backbone — cream chain with scission gap */
  const int32_t chain_n = 22;
  for (int32_t i = 0; i < chain_n; i++) {
    if (i >= 9 && i <= 11) {
      continue; /* scission gap */
    }
    const float u = (float)i / (float)(chain_n - 1);
    const float angle = u * 6.28318f + (float)digest * 0.001f;
    const int32_t x = cx + (int32_t)(cosf(angle) * (90.0f + u * 40.0f));
    const int32_t y = cy + (int32_t)(sinf(angle * 1.7f) * 35.0f);
    const int32_t shade = (int32_t)(li_rt_viz_lcg(&rng) % 28u);
    li_rt_paint_disc(rgb, width, height, x, y, 4,
                     (unsigned char)(232 - shade), (unsigned char)(228 - shade),
                     (unsigned char)(220 - shade));
  }
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
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      unsigned char* p = rgb + (y * width + x) * 3;
      p[0] = br;
      p[1] = bg;
      p[2] = bb;
    }
  }

  if (li_rt_il_pe_demo_active()) {
    int32_t seed = 4507;
    const char* seed_env = getenv("STUDIO_AIMD_VIZ_SEED");
    if (seed_env != NULL && seed_env[0] != '\0') {
      seed = atoi(seed_env);
    }
    if (seed < 1) {
      seed = 4507;
    }
    li_rt_paint_il_pe_field(rgb, width, height, digest, seed);
  } else {
    const int band_y = 8 + (digest % (height > 16 ? height - 16 : 1));
    const int band_h = 4 + (cmd_count % 12);
    const int stripe_x = 8 + (cpu_pixels % (width > 16 ? width - 16 : 1));
    for (int y = band_y; y < band_y + band_h && y < height; y++) {
      for (int x = 0; x < width; x++) {
        unsigned char* p = rgb + (y * width + x) * 3;
        p[0] = ar;
        p[1] = ag;
        p[2] = ab;
      }
    }
    for (int y = 0; y < height; y++) {
      for (int x = stripe_x; x < stripe_x + 3 && x < width; x++) {
        unsigned char* p = rgb + (y * width + x) * 3;
        p[0] = (unsigned char)((ar + br) / 2);
        p[1] = (unsigned char)((ag + bg) / 2);
        p[2] = (unsigned char)((ab + bb) / 2);
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
