#include "../common/num_quadrature_gauss_core.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {{
  li_num_quadrature_gauss_kernel();
  const double checksum = li_num_quadrature_gauss_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {{
    printf("%.17g\n", checksum);
    return 0;
  }}
  volatile double sink = checksum;
  (void)sink;
  return 0;
}}
