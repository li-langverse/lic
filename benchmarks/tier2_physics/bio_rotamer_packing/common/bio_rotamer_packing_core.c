#include "bio_rotamer_packing_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { SITES = 32, ROT = 3, TRIALS = 15000 };
static double g_checksum;
__attribute__((noinline)) void li_bio_rotamer_packing_kernel(void) {
  int pick[SITES];
  for (int i = 0; i < SITES; ++i) pick[i] = 0;
  double acc = 0.0;
  for (int t = 0; t < TRIALS; ++t) {
    const int s = t % SITES;
    pick[s] = (pick[s] + 1) % ROT;
    double e = 0.0;
    for (int i = 0; i < SITES; ++i) {
      for (int j = i + 1; j < SITES; ++j) {
        if (pick[i] == pick[j]) e += 1.0;
      }
    }
    acc += e;
  }
  g_checksum = acc;
}

double li_bio_rotamer_packing_checksum(void) { return g_checksum; }
