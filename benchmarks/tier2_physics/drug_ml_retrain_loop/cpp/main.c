#include "../common/drug_ml_retrain_loop_core.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
  li_drug_ml_retrain_loop_kernel();
  const double checksum = li_drug_ml_retrain_loop_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {
    printf("%.17g\n", checksum);
    return 0;
  }
  volatile double sink = checksum;
  (void)sink;
  return 0;
}
