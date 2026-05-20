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

struct TypecheckOptions {
  /// When true, `ensures true` on value-returning `def` is an error (E0303). Otherwise warning
  /// (W0601). Also enable with `LI_STRICT_CONTRACTS=1` or `lic build --strict-contracts`.
  bool strict_contracts = false;
};

TypecheckResult typecheck_module(const Module& module,
                                 TypecheckOptions opts = TypecheckOptions{});

}  // namespace li
