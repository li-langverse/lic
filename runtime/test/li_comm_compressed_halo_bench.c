/* WP-PAR-75 — compressed halo roundtrip bench (int8 payload, 64-wide tiles). */
#include "li_fl.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

enum { N = 4096, TILE = 64, MIN_RATIO = 3 };

static double now_sec(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

int main(void) {
  float src[N];
  float dst[N];
  for (int i = 0; i < N; ++i) {
    src[i] = (float)(i % 17) * 0.01f;
  }

  const double t0 = now_sec();
  size_t compressed_bytes = 0;
  for (int off = 0; off < N; off += TILE) {
    const int chunk = (off + TILE <= N) ? TILE : (N - off);
    li_fl_compressed_payload payload;
    li_fl_compress_f32(src + off, chunk, &payload);
    li_fl_decompress_f32(&payload, dst + off);
    compressed_bytes += (size_t)payload.count;
  }
  const double elapsed = now_sec() - t0;

  for (int i = 0; i < N; ++i) {
    if (fabsf(dst[i] - src[i]) > 0.02f) {
      fprintf(stderr, "li_comm_compressed_halo_bench: roundtrip mismatch at %d (%.4f vs %.4f)\n", i,
              dst[i], src[i]);
      return 1;
    }
  }

  const int ratio = (int)((sizeof(float) * (size_t)N) / compressed_bytes);
  if (ratio < MIN_RATIO) {
    fprintf(stderr, "li_comm_compressed_halo_bench: compression ratio %d < %d\n", ratio, MIN_RATIO);
    return 1;
  }

  printf("li_comm_compressed_halo_bench: ok (n=%d ratio=%dx elapsed=%.6fs)\n", N, ratio, elapsed);
  return 0;
}
