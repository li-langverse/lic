#pragma once

#include "li/ast.hpp"

#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

namespace li {

enum class RequiresCheckResult {
  Satisfied,
  Violated,
  Unknown,
};

const ProcDecl* find_proc_by_name(const Module& module, const std::string& name);

std::unique_ptr<Expr> substitute_call_params(
    const Expr& expr, const std::vector<std::string>& param_names,
    const std::vector<std::unique_ptr<Expr>>& args);

std::unique_ptr<Expr> fold_const_int_locals(
    const Expr& expr, const std::map<std::string, std::int64_t>& const_int_locals);

bool expr_statically_true(const Expr& expr);
bool expr_statically_false(const Expr& expr);

RequiresCheckResult check_requires_at_call(
    const ProcDecl& callee, const Expr& call,
    const std::map<std::string, std::int64_t>& const_int_locals);

/// When a call provably breaks a callee `requires`, plain-language text for diagnostics.
struct RequiresViolationExplanation {
  std::string message;
  std::string hint;
};

std::optional<RequiresViolationExplanation> explain_requires_violation(
    const ProcDecl& callee, const Expr& call,
    const std::map<std::string, std::int64_t>& const_int_locals);

std::string expr_to_user_string(const Expr& expr);
std::string call_to_user_string(const Expr& call);

void collect_calls_in_stmts(const std::vector<Stmt>& stmts,
                            std::vector<const Expr*>& out);

}  // namespace li
