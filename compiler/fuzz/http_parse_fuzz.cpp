// libFuzzer entry: fuzz HTTP request-line + header parse (no network I/O).
// Build: cmake -B build-fuzz -DLI_BUILD_FUZZ=ON -DLLVM_DIR=...
// Run:   ./build-fuzz/compiler/fuzz/http_parse_fuzz compiler/fuzz/corpus/http/ -max_len=65536
#include "li_rt.h"

#include <cstddef>
#include <cstdint>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  constexpr size_t kMax = 1 << 16;
  if (size > kMax) {
    return 0;
  }
  (void)li_rt_http_fuzz_parse_request(data, size);
  return 0;
}
