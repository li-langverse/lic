#include "../common/num_opt_line_search_core.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {{
  li_num_opt_line_search_kernel();
  const double checksum = li_num_opt_line_search_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {{
    printf("%.17g\n", checksum);
    return 0;
  }}
  volatile double sink = checksum;
  (void)sink;
  return 0;
}}
