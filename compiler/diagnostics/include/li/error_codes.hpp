#pragma once

#include "li/diagnostics.hpp"

#include <string>
#include <string_view>

namespace li {

/// Stable catalog codes (see docs/language/errors.md).
enum class ErrorCode {
  E0101,  // parse.indent
  E0201,  // type.index
  E0202,  // type.mismatch
  E0301,  // contract.missing_requires
  E0302,  // contract.missing_ensures
  E0310,  // borrow.conflict
  E0311,  // borrow.use_after_move
  E0320,  // policy.parallel_disjoint
  E0321,  // policy.parallel_decorator_disjoint
  E0330,  // policy.stdlib_shadow
  E0340,  // policy.forbidden_any
  E0350,  // policy.parallel_overlap
  E0401,  // control.break_outside_loop
  E0402,  // control.continue_outside_loop
};

/// Numerics / fixed-point hints (warnings by default; do not fail `lic check` unless -Werror).
enum class WarningCode {
  W0501,  // numerics.int_mul_overflow
  W0502,  // numerics.int_div_trunc
};

std::string_view error_code_string(ErrorCode code);
std::string_view warning_code_string(WarningCode code);

struct FormattedDiagnostic {
  std::string code;
  std::string message;
  std::string hint;
};

FormattedDiagnostic format_diagnostic(ErrorCode code, std::string_view message,
                                    std::string_view hint = {});

void diag_error(DiagnosticBag& bag, SourceLoc loc, ErrorCode code,
                std::string_view message, std::string_view hint = {});

void diag_warning(DiagnosticBag& bag, SourceLoc loc, WarningCode code,
                  std::string_view message, std::string_view hint = {});

}  // namespace li
