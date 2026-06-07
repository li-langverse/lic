#pragma once

namespace li {

struct CompileOptions {
  bool release = false;
  /** Enable cancellation-safe MIR rewrites and compensated reductions. */
  bool fp_numerically_stable = false;
  /** Baked into `li_parallel_for_i64` team_size at codegen (0 = runtime host default). */
  int runtime_team_size = 0;
};

}  // namespace li
