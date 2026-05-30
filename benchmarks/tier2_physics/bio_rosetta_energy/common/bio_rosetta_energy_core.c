#include "bio_rosetta_energy_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { RES = 48, PAIR = 20000 };
static double g_checksum;
__attribute__((noinline)) void li_bio_rosetta_energy_kernel(void) {
  double phi[RES], psi[RES];
  for (int i = 0; i < RES; ++i) {
    phi[i] = -1.0 + 0.1 * (double)i;
    psi[i] = 1.0 - 0.08 * (double)i;
  }
  double acc = 0.0;
  for (int p = 0; p < PAIR; ++p) {
    const int i = p % RES;
    const int j = (p * 5 + 7) % RES;
    const double dphi = phi[i] - phi[j];
    const double dpsi = psi[i] - psi[j];
    acc += dphi * dphi + dpsi * dpsi;
  }
  g_checksum = acc;
}

double li_bio_rosetta_energy_checksum(void) { return g_checksum; }
