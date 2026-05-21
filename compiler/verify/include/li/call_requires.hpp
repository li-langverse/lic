#pragma once

#include "li/ast.hpp"

#include <cstdint>
#include <functional>
#include <map>
#include <optional>
#include <set>
#include <string>
#include <vector>

namespace li {

enum class RequiresCheckResult {
  Satisfied,
  Violated,
  Unknown,
};

/// Facts available for lightweight proof discharge (const locals, if-guard assumptions).
struct ProofFacts {
  const std::map<std::string, std::int64_t>& const_int_locals;
  const std::set<std::string>& assum_nonneg_ints;
};

const ProcDecl* find_proc_by_name(const Module& module, const std::string& name);

/// Build `[receiver, ...method_args]` for requires substitution on desugared methods.
std::vector<std::unique_ptr<Expr>> method_call_arg_list(
    const Expr& receiver, const std::vector<std::unique_ptr<Expr>>& method_args);

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
bool folded_discharged_by_proof_facts(const Expr& folded, const ProofFacts& facts);

RequiresCheckResult check_requires_at_call(const ProcDecl& callee, const Expr& call,
                                           const ProofFacts& facts);

/// Method call: substitutes `self` from receiver, then remaining params from `method_args`.
RequiresCheckResult check_requires_at_method_call(
    const ProcDecl& callee, const Expr& receiver,
    const std::vector<std::unique_ptr<Expr>>& method_args, const ProofFacts& facts);

/// When a call provably breaks a callee `requires`, plain-language text for diagnostics.
struct RequiresViolationExplanation {
  std::string message;
  std::string hint;
};

std::optional<RequiresViolationExplanation> explain_requires_violation(
    const ProcDecl& callee, const Expr& call, const ProofFacts& facts);

std::optional<RequiresViolationExplanation> explain_requires_violation_method(
    const ProcDecl& callee, const Expr& receiver, const std::string& method_name,
    const std::vector<std::unique_ptr<Expr>>& method_args, const ProofFacts& facts);

std::string method_call_to_user_string(const Expr& receiver, const std::string& method,
                                       const std::vector<std::unique_ptr<Expr>>& method_args);

std::string expr_to_user_string(const Expr& expr);
std::string call_to_user_string(const Expr& call);

void collect_calls_in_stmts(const std::vector<Stmt>& stmts,
                            std::vector<const Expr*>& out);

void collect_method_calls_in_stmts(const std::vector<Stmt>& stmts,
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

RequiresCheckResult check_refinement_argument(const ResolvedRefinement& refinement,
                                              const Expr& arg, const ProofFacts& facts);

std::optional<RequiresViolationExplanation> explain_refinement_violation(
    const ResolvedRefinement& refinement, const Expr& arg, const ProofFacts& facts);

/// Record `name` as non-negative inside a guarded branch (`if name >= 0`, etc.).
void note_nonneg_assumption_from_cond(const Expr& cond, std::set<std::string>& out);

/// `w.balance` after `w.balance = 5` for method `requires self.balance >= n` folding.
std::optional<std::string> object_field_const_key(const Expr& e);

/// Owned facts for VC emit (const `var` inits + `if n >= 0` guards in procedure body).
struct CallerProofFacts {
  std::map<std::string, std::int64_t> const_int_locals;
  std::set<std::string> assum_nonneg_ints;
  ProofFacts view() const { return ProofFacts{const_int_locals, assum_nonneg_ints}; }
};

CallerProofFacts collect_caller_proof_facts(const ProcDecl& caller);

}  // namespace li
