#pragma once

#include <string>

namespace li {

struct CompileOptions {
  bool release = false;
  /** Enable cancellation-safe MIR rewrites and compensated reductions. */
  bool fp_numerically_stable = false;
  /** Baked into `li_parallel_for_i64` team_size at codegen (0 = runtime host default). */
  int runtime_team_size = 0;
  /** LLVM-style target triple; `x86_64-unknown-none` selects freestanding kernel link. */
  std::string target_triple;

  bool is_freestanding() const {
    return target_triple.find("-none") != std::string::npos ||
           target_triple.find("-unknown-none") != std::string::npos;
  }
};

}  // namespace li
