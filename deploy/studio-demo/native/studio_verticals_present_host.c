/* Per-vertical native frame — CPU framebuffer (no RenderReadPixels); honest native_pixels for MP4.
 * Profile chip height/color aligned with packages/li-studio/src/lib.li contracts. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  int id;
  const char* slug;
  int tag_h;
  unsigned char r;
  unsigned char g;
  unsigned char b;
} ProfileVisual;

static const ProfileVisual k_profiles[] = {
    {1, "game", 21, 61, 214, 255},
    {2, "sim_rl", 22, 46, 230, 168},
    {3, "sim_automotive", 23, 255, 179, 71},
    {4, "sim_robotics", 24, 255, 179, 71},
    {5, "sim_additive", 25, 255, 179, 71},
    {6, "sim_scientific", 26, 255, 179, 71},
    {7, "sim_drug_design", 27, 124, 92, 255},
};

static const ProfileVisual* find_profile(int profile_id) {
  for (size_t i = 0; i < sizeof(k_profiles) / sizeof(k_profiles[0]); i++) {
    if (k_profiles[i].id == profile_id) {
      return &k_profiles[i];
    }
  }
  return NULL;
}

static void put_px(unsigned char* rgb, int w, int h, int x, int y, unsigned char r,
                   unsigned char g, unsigned char b) {
  if (x < 0 || y < 0 || x >= w || y >= h) {
    return;
  }
  unsigned char* p = rgb + (y * w + x) * 3;
  p[0] = r;
  p[1] = g;
  p[2] = b;
}

static void fill_rect(unsigned char* rgb, int w, int h, int x, int y, int rw, int rh,
                      unsigned char r, unsigned char g, unsigned char b) {
  for (int yy = y; yy < y + rh && yy < h; yy++) {
    for (int xx = x; xx < x + rw && xx < w; xx++) {
      put_px(rgb, w, h, xx, yy, r, g, b);
    }
  }
}

static void draw_hline(unsigned char* rgb, int w, int h, int x0, int x1, int y,
                       unsigned char r, unsigned char g, unsigned char b) {
  for (int x = x0; x <= x1; x++) {
    put_px(rgb, w, h, x, y, r, g, b);
  }
}

static void draw_vline(unsigned char* rgb, int w, int h, int x, int y0, int y1,
                       unsigned char r, unsigned char g, unsigned char b) {
  for (int y = y0; y <= y1; y++) {
    put_px(rgb, w, h, x, y, r, g, b);
  }
}

static void draw_viewport_profile(unsigned char* rgb, int w, int h, const ProfileVisual* pv) {
  int sx = w / 4;
  int sy = h / 4;
  int sw = w / 2;
  int sh = h / 2;
  for (int i = 0; i < sw; i++) {
    put_px(rgb, w, h, sx + i, sy, 251, 146, 60);
    put_px(rgb, w, h, sx + i, sy + sh, 251, 146, 60);
  }
  for (int i = 0; i < sh; i++) {
    put_px(rgb, w, h, sx, sy + i, 251, 146, 60);
    put_px(rgb, w, h, sx + sw, sy + i, 251, 146, 60);
  }
  int marker_w = 120;
  int marker_h = pv->tag_h;
  int mx = sx + (sw - marker_w) / 2;
  int my = sy + (sh - marker_h) / 2;
  fill_rect(rgb, w, h, mx, my, marker_w, marker_h, pv->r, pv->g, pv->b);
  if (pv->id == 1) {
    int cx = mx + marker_w / 2;
    int cy = my + marker_h / 2;
    for (int d = -8; d <= 8; d++) {
      put_px(rgb, w, h, cx + d, cy, 255, 255, 255);
      put_px(rgb, w, h, cx, cy + d, 255, 255, 255);
    }
  }
  if (pv->id == 2) {
    for (int a = 0; a < 360; a += 45) {
      int ox = mx + marker_w / 2 + (a % 2 == 0 ? 24 : 12);
      int oy = my + marker_h / 2 + (a / 45);
      fill_rect(rgb, w, h, ox - 2, oy - 2, 4, 4, 255, 255, 255);
    }
  }
  if (pv->id >= 3 && pv->id <= 6) {
    for (int lane = 0; lane < 3; lane++) {
      int ly = my + 4 + lane * (marker_h / 3);
      draw_hline(rgb, w, h, mx + 8, mx + marker_w - 8, ly, 255, 255, 255);
    }
  }
  if (pv->id == 7) {
    fill_rect(rgb, w, h, mx + 12, my + 4, marker_w - 24, marker_h - 8, 91, 33, 182);
    draw_hline(rgb, w, h, mx + 16, mx + marker_w - 16, my + marker_h / 2, 196, 181, 253);
  }
}

static void draw_shell(unsigned char* rgb, int w, int h, const ProfileVisual* pv) {
  fill_rect(rgb, w, h, 0, 0, w, h, 13, 17, 23);
  for (int x = 0; x < w; x += 64) {
    draw_vline(rgb, w, h, x, 0, h - 1, 48, 54, 61);
  }
  for (int y = 0; y < h; y += 64) {
    draw_hline(rgb, w, h, 0, w - 1, y, 48, 54, 61);
  }
  draw_viewport_profile(rgb, w, h, pv);
  int chip_w = 88;
  int chip_x = w - chip_w - 12;
  fill_rect(rgb, w, h, chip_x, 12, chip_w, pv->tag_h, pv->r, pv->g, pv->b);
  fill_rect(rgb, w, h, 12, h - 36, 520, 24, 34, 197, 94);
}

static int save_ppm(const unsigned char* rgb, int w, int h, const char* path) {
  FILE* f = fopen(path, "wb");
  if (!f) {
    return -1;
  }
  fprintf(f, "P6\n%d %d\n255\n", w, h);
  fwrite(rgb, 1, (size_t)w * (size_t)h * 3, f);
  fclose(f);
  return 0;
}


static int profile_from_env_slug(const char** slug_out) {
  const char* env = getenv("STUDIO_DEMO_PROFILE");
  if (env == NULL || env[0] == '\0') {
    return 0;
  }
  for (size_t i = 0; i < sizeof(k_profiles) / sizeof(k_profiles[0]); i++) {
    if (strcmp(k_profiles[i].slug, env) == 0) {
      *slug_out = k_profiles[i].slug;
      return k_profiles[i].id;
    }
  }
  return 0;
}

int main(int argc, char** argv) {
  int width = 1920;
  int height = 1080;
  int profile_id = 1;
  const char* out_dir = ".";
  const char* slug = "game";
  const int env_pid = profile_from_env_slug(&slug);
  if (env_pid > 0) {
    profile_id = env_pid;
  }
  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--width") == 0 && i + 1 < argc) {
      width = atoi(argv[++i]);
    } else if (strcmp(argv[i], "--height") == 0 && i + 1 < argc) {
      height = atoi(argv[++i]);
    } else if (strcmp(argv[i], "--profile-id") == 0 && i + 1 < argc) {
      profile_id = atoi(argv[++i]);
    } else if (strcmp(argv[i], "--slug") == 0 && i + 1 < argc) {
      slug = argv[++i];
    } else if (strcmp(argv[i], "--out") == 0 && i + 1 < argc) {
      out_dir = argv[++i];
    }
  }
  const ProfileVisual* pv = find_profile(profile_id);
  if (!pv) {
    fprintf(stderr, "unknown profile_id %d\n", profile_id);
    return 1;
  }
  size_t n = (size_t)width * (size_t)height * 3;
  unsigned char* rgb = (unsigned char*)calloc(n, 1);
  if (!rgb) {
    return 2;
  }
  draw_shell(rgb, width, height, pv);
  char path[512];
  snprintf(path, sizeof(path), "%s/frame-000.ppm", out_dir);
  int ok = save_ppm(rgb, width, height, path);
  free(rgb);
  printf(
      "{\"native_pixels\":%s,\"profile_id\":%d,\"slug\":\"%s\",\"slug_expected\":\"%s\","
      "\"ppm\":\"%s\",\"width\":%d,\"height\":%d,\"backend\":\"cpu_framebuffer\"}\n",
      ok == 0 ? "1" : "0", profile_id, slug, pv->slug, path, width, height);
  return ok == 0 ? 0 : 5;
}
