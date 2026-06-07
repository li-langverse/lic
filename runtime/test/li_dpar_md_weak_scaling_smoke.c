/* WP-PAR-20/22 — programmed cluster + MD weak-scaling specimen (independent replica per rank). */
#include "li_dpar.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void li_md_kernel(void);
extern double li_md_checksum(void);

static int expect_close(double got, double want, double tol) {
  if (fabs(got - want) > tol) {
    fprintf(stderr, "li_dpar_md_weak_scaling_smoke: expected %.9f got %.9f\n", want, got);
    return 1;
  }
  return 0;
}

int main(void) {
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();

  if (world > 1) {
    const char* hosts = getenv("LI_DPAR_HOSTS");
    if (hosts == NULL || hosts[0] == '\0') {
      fprintf(stderr, "rank %d: LI_DPAR_HOSTS required for programmed cluster\n", rank);
      return 1;
    }
  }

  li_md_kernel();
  const double local_drift = li_md_checksum();

  li_dpar_barrier();

  double gathered[64];
  memset(gathered, 0, sizeof(gathered));
  li_dpar_gather_f64(&local_drift, gathered, 1, 0);
  if (rank == 0) {
    for (int p = 1; p < world; ++p) {
      if (expect_close(gathered[p], gathered[0], 1e-9) != 0) {
        fprintf(stderr, "replica drift mismatch rank %d vs rank 0 (world=%d)\n", p, world);
        li_dpar_finalize();
        return 1;
      }
    }
    printf("li_dpar_md_weak_scaling_smoke: ok (world=%d drift=%.6e)\n", world, local_drift);
  }

  li_dpar_barrier();
  li_dpar_finalize();
  return 0;
}
