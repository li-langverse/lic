#include "li/mir.hpp"

namespace li {

const char* mir_version() { return "0.1.0"; }

std::size_t count_mir_parallel_disjoint_proven(const MirModule& mir) {
  std::size_t n = 0;
  for (const auto& fn : mir.functions) {
    for (const auto& ins : fn.body) {
      if (ins.op == MirOp::OmpParallelFor && ins.parallel_disjoint_proven) {
        ++n;
      }
    }
  }
  return n;
}

}  // namespace li
