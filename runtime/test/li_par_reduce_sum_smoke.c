#include "li_parallel.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
  enum { N = 65536 };
  double* data = (double*)malloc((size_t)N * sizeof(double));
  if (!data) {
    fprintf(stderr, "li_par_reduce_sum_smoke: malloc failed\n");
    return 1;
  }
  double expect = 0.0;
  for (int i = 0; i < N; ++i) {
    data[i] = (double)(i % 97) * 0.25;
    expect += data[i];
  }

  li_par_pool_set_team_size(4);
  const double got = li_par_reduce_sum_f64(data, N, 4);
  li_par_pool_shutdown();

  if (!isfinite(got) || fabs(got - expect) > 1e-6) {
    fprintf(stderr, "li_par_reduce_sum_smoke: expected %.9f got %.9f\n", expect, got);
    free(data);
    return 1;
  }

  free(data);
  printf("li_par_reduce_sum_smoke: ok\n");
  return 0;
}
