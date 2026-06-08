#include "num_quadrature_gauss_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>

enum { REPS = 2000000 };
static const double nodes[5] = {-0.906179845938664, -0.538469310105683, 0.0,
                                0.538469310105683, 0.906179845938664};
static const double weights[5] = {0.236926885056189, 0.478628670499366, 0.568888888888889,
                                  0.478628670499366, 0.236926885056189};
static double g_checksum;

static double gauss_inner_once(void) {
  double s = 0.0;
  for (int k = 0; k < 5; ++k) {
    const double x = 0.5 * (nodes[k] + 1.0);
    s += weights[k] * 0.5 * (x * x + 1.0);
  }
  return s;
}

__attribute__((optnone)) void li_num_quadrature_gauss_kernel(void) {
  const double inner = gauss_inner_once();
  volatile double inner_sink = inner;
  (void)inner_sink;
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {
    acc += inner;
  }
  g_checksum = acc;
}

double li_num_quadrature_gauss_checksum(void) { return g_checksum; }
