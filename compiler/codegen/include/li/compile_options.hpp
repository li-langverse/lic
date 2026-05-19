#pragma once

namespace li {

struct CompileOptions {
  bool release = false;
  /** Enable cancellation-safe MIR rewrites and compensated reductions. */
  bool fp_numerically_stable = false;
};

}  // namespace li
