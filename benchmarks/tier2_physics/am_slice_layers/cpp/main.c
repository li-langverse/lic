#include "../common/am_slice_layers_core.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
  li_am_slice_layers_kernel();
  const double checksum = li_am_slice_layers_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {
    printf("%.17g\n", checksum);
    return 0;
  }
  volatile double sink = checksum;
  (void)sink;
  return 0;
}
