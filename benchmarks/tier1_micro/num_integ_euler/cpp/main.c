#include "../common/num_integ_euler_core.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {{
  li_num_integ_euler_kernel();
  const double checksum = li_num_integ_euler_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {{
    printf("%.17g\n", checksum);
    return 0;
  }}
  volatile double sink = checksum;
  (void)sink;
  return 0;
}}
