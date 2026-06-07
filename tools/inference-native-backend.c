#include "li_rt_inference_sse.h"

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: inference-native-backend PORT [CANCEL_MARK_PATH]\n");
    return 2;
  }
  const int port = atoi(argv[1]);
  const char* cancel_mark = argc >= 3 ? argv[2] : NULL;
  const int32_t rc = li_rt_inference_native_backend_run((int32_t)port, cancel_mark);
  if (rc == -2) {
    fprintf(stderr, "inference-native-backend: native weights probe failed\n");
    return 3;
  }
  if (rc != 0) {
    fprintf(stderr, "inference-native-backend: run failed rc=%d\n", (int)rc);
    return 1;
  }
  return 0;
}
