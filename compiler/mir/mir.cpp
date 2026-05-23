#include "li/mir.hpp"

#include <iostream>

namespace li {

const char* mir_version() { return "0.1.0"; }

void print_mir_decorator_flags(const MirModule& mir, std::ostream& out) {
  for (const auto& fn : mir.functions) {
    out << "mir_decor fn=" << fn.name << " vectorized_lanes=" << fn.vectorized_lanes
        << " no_vectorize=" << (fn.no_vectorize ? 1 : 0) << '\n';
  }
}

}  // namespace li
