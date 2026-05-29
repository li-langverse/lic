#include "../common/am_polygon_clip_core.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
  li_am_polygon_clip_kernel();
  const double checksum = li_am_polygon_clip_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {
    printf("%.17g\n", checksum);
    return 0;
  }
  volatile double sink = checksum;
  (void)sink;
  return 0;
}
