// libFuzzer entry: fuzz HTTP request-line witness (li_rt_http_parse_request_len_tag).
// Build: cmake -B build-fuzz -DLI_BUILD_FUZZ=ON -DLLVM_DIR=...
// Run:   ./build-fuzz/compiler/fuzz/http_parse_fuzz compiler/fuzz/corpus/http/ -max_len=65536
#include "li_rt.h"

#include <cstddef>
#include <cstdint>
#include <cstring>
#include <vector>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  constexpr size_t kMax = 1 << 16;
  if (size > kMax) {
    return 0;
  }
  std::vector<char> buf(size + 1, '\0');
  if (size > 0) {
    std::memcpy(buf.data(), data, size);
  }
  (void)li_rt_http_parse_request_len_tag(buf.data(), 8192, 65536);
  return 0;
}
