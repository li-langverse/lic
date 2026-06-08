#include "li_dpar.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int expect_close(double got, double want) {
  if (fabs(got - want) > 1e-9) {
    fprintf(stderr, "li_dpar_collective_smoke: expected %.6f got %.6f\n", want, got);
    return 1;
  }
  return 0;
}

int main(void) {
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();

  double recv[4];
  double send_scatter[16];
  if (rank == 0) {
    for (int i = 0; i < world * 4; ++i) {
      send_scatter[i] = (double)(100 + i);
    }
  }
  li_dpar_scatter_f64(rank == 0 ? send_scatter : NULL, recv, 4, 0);
  for (int i = 0; i < 4; ++i) {
    const double want = (double)(100 + rank * 4 + i);
    if (expect_close(recv[i], want) != 0) {
      return 1;
    }
  }

  double send_gather[4];
  for (int i = 0; i < 4; ++i) {
    send_gather[i] = (double)(rank * 10 + i);
  }
  double gathered[16];
  memset(gathered, 0, sizeof(gathered));
  li_dpar_gather_f64(send_gather, gathered, 4, 0);
  if (rank == 0) {
    for (int p = 0; p < world; ++p) {
      for (int i = 0; i < 4; ++i) {
        const double want = (double)(p * 10 + i);
        if (expect_close(gathered[p * 4 + i], want) != 0) {
          return 1;
        }
      }
    }
  }

  const double local = (double)(rank + 1);
  double scan_out = -1.0;
  li_dpar_scan_sum_f64(local, &scan_out);
  double want_scan = 0.0;
  for (int i = 0; i < rank; ++i) {
    want_scan += (double)(i + 1);
  }
  if (expect_close(scan_out, want_scan) != 0) {
    return 1;
  }

  li_dpar_barrier();

  li_dpar_finalize();
  if (rank == 0) {
    printf("li_dpar_collective_smoke: ok (world=%d)\n", world);
  }
  return 0;
}
