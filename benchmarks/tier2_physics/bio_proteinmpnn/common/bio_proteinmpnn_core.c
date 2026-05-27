#include "bio_proteinmpnn_core.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>


enum { LEN = 64, HID = 128, STEPS = 2500 };
static double g_checksum;
__attribute__((noinline)) void li_bio_proteinmpnn_kernel(void) {
  double h[HID];
  for (int i = 0; i < HID; ++i) h[i] = 0.0;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {
    for (int i = 0; i < HID; ++i) h[i] = 0.0;
    for (int p = 0; p < LEN; ++p) {
      const double x = sin(0.13 * (double)(p + s));
      for (int i = 0; i < HID; ++i) {
        h[i] += tanh(x + 0.01 * (double)i);
      }
    }
    for (int i = 0; i < HID; ++i) acc += h[i];
  }
  g_checksum = acc;
}

double li_bio_proteinmpnn_checksum(void) { return g_checksum; }
