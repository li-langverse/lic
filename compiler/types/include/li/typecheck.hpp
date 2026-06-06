#pragma once

#include "li/ast.hpp"
#include "li/diagnostics.hpp"

#include <optional>
#include <string>

namespace li {

struct TypecheckResult {
  bool ok = false;
  DiagnosticBag diagnostics;
};

TypecheckResult typecheck_module(const Module& module);

/// Fold `for i in range(n)` to `0..<n` when `n` is a compile-time int witness.
void resolve_for_range_bounds(Module& module, const std::string& file, DiagnosticBag& diags);

}  // namespace li
