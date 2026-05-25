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
  E0303,  // contract.weak_ensures_true
  E0304,  // contract.callee_requires_not_met
  E0305,  // type.refinement_not_met
  E0310,  // borrow.conflict
  E0311,  // borrow.use_after_move
  E0320,  // policy.parallel_disjoint
  E0321,  // policy.parallel_decorator_disjoint
  E0322,  // policy.vectorized_lanes_unsupported
  E0323,  // policy.vectorized_no_vectorize_conflict
  E0330,  // policy.stdlib_shadow
  E0340,  // policy.forbidden_any
  E0350,  // policy.parallel_overlap
  E0360,  // codegen.extern_ptr_abi
  E0401,  // control.break_outside_loop
  E0402,  // control.continue_outside_loop
  E0501,  // httpd.config.io
  E0502,  // httpd.config.route_key
  E0503,  // httpd.config.path_traversal
  E0504,  // httpd.config.overlap
};

std::string_view error_code_string(ErrorCode code);

struct FormattedDiagnostic {
  std::string code;
  std::string message;
  std::string hint;
};

FormattedDiagnostic format_diagnostic(ErrorCode code, std::string_view message,
                                    std::string_view hint = {});

void diag_error(DiagnosticBag& bag, SourceLoc loc, ErrorCode code,
                std::string_view message, std::string_view hint = {});

}  // namespace li
