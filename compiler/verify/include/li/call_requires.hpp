#pragma once

#include "li/ast.hpp"

#include <cstdint>
#include <functional>
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

/// Replace a single refinement binder (`x` in `{x: int | …}`) with `arg_value`.
std::unique_ptr<Expr> substitute_refinement_binding(const Expr& predicate,
                                                    const std::string& bind_var,
                                                    const Expr& arg_value);

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

/// Resolved refinement on a parameter or variable type (`{x: int | …}` or alias).
struct ResolvedRefinement {
  std::string bind_var;
  std::string type_label;
  const Expr* predicate = nullptr;
};

using AliasTypeLookup = std::function<const TypeExpr*(const std::string&)>;

std::optional<ResolvedRefinement> resolve_refinement_on_type(const TypeExpr& param_type,
                                                             AliasTypeLookup lookup);

RequiresCheckResult check_refinement_argument(
    const ResolvedRefinement& refinement, const Expr& arg,
    const std::map<std::string, std::int64_t>& const_int_locals);

std::optional<RequiresViolationExplanation> explain_refinement_violation(
    const ResolvedRefinement& refinement, const Expr& arg,
    const std::map<std::string, std::int64_t>& const_int_locals);

}  // namespace li
