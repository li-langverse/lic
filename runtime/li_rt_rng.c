#include "li_rt.h"

#include <errno.h>
#include <stdint.h>
#include <string.h>

#if defined(__linux__)
#include <sys/random.h>
#elif defined(__APPLE__)
#include <stdlib.h>
#endif

/* Trusted OS CSPRNG seam — getrandom(2) / arc4random_buf; no crypto in C. */
int32_t li_rt_rng_fill_bytes(intptr_t out_buf, int32_t n) {
  if (n < 0) {
    return -1;
  }
  if (n == 0) {
    return 0;
  }
  unsigned char* out = (unsigned char*)out_buf;
  if (out == NULL) {
    return -2;
  }
#if defined(__linux__)
  ssize_t got = 0;
  while (got < n) {
    ssize_t chunk = getrandom(out + got, (size_t)(n - got), 0);
    if (chunk < 0) {
      if (errno == EINTR) {
        continue;
      }
      return -3;
    }
    if (chunk == 0) {
      return -4;
    }
    got += chunk;
  }
  return n;
#elif defined(__APPLE__)
  arc4random_buf(out, (size_t)n);
  return n;
#else
  /* Fallback for bring-up hosts without getrandom — not production-safe. */
  for (int32_t i = 0; i < n; ++i) {
    out[i] = (unsigned char)(rand() & 0xFF);
  }
  return n;
#endif
}
