/* WP-PAR-60–65 — federated learning hardening smoke (partial ranks, stragglers, compressed halos). */
#include "li_dpar.h"
#include "li_fl.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int expect_close(double got, double want, double tol) {
  if (fabs(got - want) > tol) {
    fprintf(stderr, "li_fl_smoke: expected %.9f got %.9f\n", want, got);
    return 1;
  }
  return 0;
}

static void overlap_compute(void* ctx) {
  int* flag = (int*)ctx;
  *flag = 1;
}

static int test_compressed_halo(void) {
  float src[4] = {0.0f, 0.25f, 0.5f, 1.0f};
  float dst[4];
  li_fl_compressed_payload payload;
  li_fl_compress_f32(src, 4, &payload);
  li_fl_decompress_f32(&payload, dst);
  for (int i = 0; i < 4; ++i) {
    if (fabsf(dst[i] - src[i]) > 0.02f) {
      fprintf(stderr, "li_fl_smoke: compress roundtrip[%d] %.4f vs %.4f\n", i, dst[i], src[i]);
      return 1;
    }
  }
  return 0;
}

static int test_shrink_mask(void) {
  const uint64_t active = 0xFULL;
  const uint64_t failed = 0x4ULL;
  const uint64_t shrunk = li_fl_shrink_mask(active, failed);
  if (shrunk != 0xBULL) {
    fprintf(stderr, "li_fl_smoke: shrink mask got 0x%llx want 0xb\n", (unsigned long long)shrunk);
    return 1;
  }
  return 0;
}

int main(void) {
  li_fl_init_from_env();
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();

  if (rank == 0 && test_compressed_halo() != 0) {
    return 1;
  }
  if (rank == 0 && test_shrink_mask() != 0) {
    return 1;
  }

  static const li_fl_device_kind devices[4] = {
      LI_FL_DEVICE_CPU, LI_FL_DEVICE_GPU, LI_FL_DEVICE_TPU, LI_FL_DEVICE_ASIC};
  li_fl_set_device_kind(devices[rank % 4]);

  const double local = (double)(rank + 1);
  uint64_t active_mask = li_fl_active_mask();
  if (active_mask == 0) {
    for (int i = 0; i < world && i < 64; ++i) {
      active_mask |= (1ULL << i);
    }
  }

  /* WP-PAR-60: partial participation — drop rank 2 when world>=4. */
  if (world >= 4) {
    active_mask &= ~(1ULL << 2);
  }
  li_fl_set_active_mask(active_mask);

  double avg = li_fl_fedavg_masked_f64(local, active_mask);
  if (world >= 4 && rank == 0) {
    const double want = (1.0 + 2.0 + 4.0) / 3.0;
    if (expect_close(avg, want, 1e-9) != 0) {
      return 1;
    }
  } else if (world == 1) {
    if (expect_close(avg, local, 1e-9) != 0) {
      return 1;
    }
  }

  /* WP-PAR-63: hetero device kinds gathered at root. */
  li_fl_device_kind kinds[64];
  memset(kinds, 0, sizeof(kinds));
  li_fl_gather_device_kinds(kinds, world);
  if (rank == 0 && world >= 4) {
    if (kinds[0] != LI_FL_DEVICE_CPU || kinds[1] != LI_FL_DEVICE_GPU ||
        kinds[2] != LI_FL_DEVICE_TPU || kinds[3] != LI_FL_DEVICE_ASIC) {
      fprintf(stderr, "li_fl_smoke: hetero device gather mismatch\n");
      return 1;
    }
  }

  /* WP-PAR-64: comm/compute overlap hook runs on active ranks. */
  int overlap_ran = 0;
  double overlap_avg = li_fl_fedavg_overlap_f64(local, active_mask, overlap_compute, &overlap_ran,
                                              &overlap_ran);
  if (((active_mask >> rank) & 1ULL) && overlap_ran != 1) {
    fprintf(stderr, "li_fl_smoke: overlap compute did not run on active rank %d\n", rank);
    return 1;
  }
  (void)overlap_avg;

  /* WP-PAR-61/65: straggler timeout + shrink when world>=4. */
  if (world >= 4) {
    uint64_t timed_out = 0;
    const uint64_t full_mask = active_mask | (1ULL << 2);
    li_fl_set_active_mask(full_mask);
    avg = li_fl_fedavg_straggler_f64(local, full_mask, 50, &timed_out);
    if (rank == 0) {
      if ((timed_out & (1ULL << 2)) == 0) {
        fprintf(stderr, "li_fl_smoke: expected rank 2 straggler timeout (mask=0x%llx)\n",
                (unsigned long long)timed_out);
        return 1;
      }
      const uint64_t shrunk = li_fl_shrink_mask(full_mask, timed_out);
      if (shrunk != (full_mask & ~(1ULL << 2))) {
        fprintf(stderr, "li_fl_smoke: shrink after straggler unexpected\n");
        return 1;
      }
    }
  }

  li_dpar_barrier();
  li_dpar_finalize();
  if (rank == 0) {
    printf("li_fl_smoke: ok (world=%d partial=%d straggler=%d compressed=1 hetero=1 overlap=1 shrink=1)\n",
           world, world >= 4, world >= 4);
  }
  return 0;
}
