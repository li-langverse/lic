#include "li/call_requires.hpp"

#include <optional>
#include <sstream>

namespace li {
namespace {

const char* binop_spelling(BinOp op) {
  switch (op) {
    case BinOp::Eq:
      return "==";
    case BinOp::Ne:
      return "!=";
    case BinOp::Lt:
      return "<";
    case BinOp::Le:
      return "<=";
    case BinOp::Gt:
      return ">";
    case BinOp::Ge:
      return ">=";
    case BinOp::And:
      return "and";
    case BinOp::Or:
      return "or";
    default:
      return "?";
  }
}

std::string false_comparison_phrase(BinOp op, std::int64_t lhs, std::int64_t rhs) {
  std::ostringstream os;
  os << lhs << ' ' << binop_spelling(op) << ' ' << rhs << " is not true";
  return os.str();
}

std::string suggest_fix_for_int_comparison(BinOp op, std::int64_t lhs, std::int64_t rhs) {
  if (op == BinOp::Ge && lhs < 0 && rhs == 0) {
    return "The value " + std::to_string(lhs) + " is negative. Use zero or a positive number "
           "(for example `0` or `5`).";
  }
  if (op == BinOp::Gt && lhs <= rhs) {
    return "The value " + std::to_string(lhs) + " must be greater than " + std::to_string(rhs) +
           ".";
  }
  if (op == BinOp::Le && lhs > rhs) {
    return "The value " + std::to_string(lhs) + " must be less than or equal to " +
           std::to_string(rhs) + ".";
  }
  if (op == BinOp::Lt && lhs >= rhs) {
    return "The value " + std::to_string(lhs) + " must be less than " + std::to_string(rhs) + ".";
  }
  if (op == BinOp::Eq) {
    return "Use " + std::to_string(rhs) + " instead of " + std::to_string(lhs) + ", or change the "
           "callee's `requires` if the rule is wrong.";
  }
  return "Change the argument so the condition holds, or update the callee's `requires` clause "
         "if the rule is wrong.";
}

std::string suggest_fix_for_refinement(BinOp op, std::int64_t lhs, std::int64_t rhs) {
  if (op == BinOp::Ge && lhs < 0 && rhs == 0) {
    return "The value " + std::to_string(lhs) + " is negative. Use zero or a positive number, or "
           "widen the refinement type if the bound is wrong.";
  }
  if (op == BinOp::Gt && lhs <= rhs) {
    return "The value " + std::to_string(lhs) + " must be greater than " + std::to_string(rhs) +
           " for this refinement type.";
  }
  if (op == BinOp::Le && lhs > rhs) {
    return "The value " + std::to_string(lhs) + " must be at most " + std::to_string(rhs) +
           " for this refinement type.";
  }
  if (op == BinOp::Lt && lhs >= rhs) {
    return "The value " + std::to_string(lhs) + " must be less than " + std::to_string(rhs) +
           " for this refinement type.";
  }
  return "Use a value inside the declared range, or relax the refinement on the type alias.";
}

std::unique_ptr<Expr> clone_expr(const Expr& e) {
  auto out = std::make_unique<Expr>();
  out->span = e.span;
  out->kind = e.kind;
  out->int_value = e.int_value;
  out->float_value = e.float_value;
  out->str_value = e.str_value;
  out->ident = e.ident;
  out->bin_op = e.bin_op;
  out->field_name = e.field_name;
  if (e.lhs) {
    out->lhs = clone_expr(*e.lhs);
  }
  if (e.rhs) {
    out->rhs = clone_expr(*e.rhs);
  }
  if (e.operand) {
    out->operand = clone_expr(*e.operand);
  }
  if (e.base) {
    out->base = clone_expr(*e.base);
  }
  if (e.index) {
    out->index = clone_expr(*e.index);
  }
  for (const auto& arg : e.args) {
    if (arg) {
      out->args.push_back(clone_expr(*arg));
    }
  }
  return out;
}

std::optional<std::int64_t> int_lit_value(const Expr& e) {
  if (e.kind == Expr::Kind::IntLit) {
    return e.int_value;
  }
  return std::nullopt;
}

bool compare_int_literals(BinOp op, std::int64_t lhs, std::int64_t rhs) {
  switch (op) {
    case BinOp::Eq:
      return lhs == rhs;
    case BinOp::Ne:
      return lhs != rhs;
    case BinOp::Lt:
      return lhs < rhs;
    case BinOp::Le:
      return lhs <= rhs;
    case BinOp::Gt:
      return lhs > rhs;
    case BinOp::Ge:
      return lhs >= rhs;
    default:
      return false;
  }
}

}  // namespace

std::unique_ptr<Expr> substitute_refinement_binding(const Expr& predicate,
                                                    const std::string& bind_var,
                                                    const Expr& arg_value) {
  const std::vector<std::string> names{bind_var};
  std::vector<std::unique_ptr<Expr>> args;
  args.push_back(clone_expr(arg_value));
  return substitute_call_params(predicate, names, args);
}

const ProcDecl* find_proc_by_name(const Module& module, const std::string& name) {
  for (const auto& proc : module.procs) {
    if (proc.name == name) {
      return &proc;
    }
  }
  return nullptr;
}

std::unique_ptr<Expr> substitute_call_params(
    const Expr& expr, const std::vector<std::string>& param_names,
    const std::vector<std::unique_ptr<Expr>>& args) {
  auto out = clone_expr(expr);
  if (out->kind == Expr::Kind::Ident) {
    for (std::size_t i = 0; i < param_names.size() && i < args.size(); ++i) {
      if (out->ident == param_names[i] && args[i]) {
        return clone_expr(*args[i]);
      }
    }
    return out;
  }
  if (out->lhs) {
    out->lhs = substitute_call_params(*out->lhs, param_names, args);
  }
  if (out->rhs) {
    out->rhs = substitute_call_params(*out->rhs, param_names, args);
  }
  if (out->operand) {
    out->operand = substitute_call_params(*out->operand, param_names, args);
  }
  if (out->base) {
    out->base = substitute_call_params(*out->base, param_names, args);
  }
  if (out->index) {
    out->index = substitute_call_params(*out->index, param_names, args);
  }
  for (auto& arg : out->args) {
    if (arg) {
      arg = substitute_call_params(*arg, param_names, args);
    }
  }
  return out;
}

std::optional<std::string> object_field_const_key(const Expr& e) {
  if (e.kind != Expr::Kind::FieldAccess || !e.base) {
    return std::nullopt;
  }
  const Expr* root = e.base.get();
  while (root && root->kind == Expr::Kind::FieldAccess) {
    root = root->base.get();
  }
  if (!root || root->kind != Expr::Kind::Ident) {
    return std::nullopt;
  }
  return root->ident + "." + e.field_name;
}

void note_object_field_const_assign(const Expr& lhs, const Expr& rhs,
                                    std::map<std::string, std::int64_t>& const_int_locals) {
  const auto key = object_field_const_key(lhs);
  if (!key) {
    return;
  }
  if (rhs.kind == Expr::Kind::IntLit) {
    const_int_locals[*key] = rhs.int_value;
    return;
  }
  if (rhs.kind == Expr::Kind::Ident) {
    const auto it = const_int_locals.find(rhs.ident);
    if (it != const_int_locals.end()) {
      const_int_locals[*key] = it->second;
    }
    const auto fit = object_field_const_key(rhs);
    if (fit) {
      const auto it2 = const_int_locals.find(*fit);
      if (it2 != const_int_locals.end()) {
        const_int_locals[*key] = it2->second;
      }
    }
  }
}

std::unique_ptr<Expr> fold_const_int_locals(
    const Expr& expr, const std::map<std::string, std::int64_t>& const_int_locals) {
  if (expr.kind == Expr::Kind::FieldAccess) {
    const auto key = object_field_const_key(expr);
    if (key) {
      const auto it = const_int_locals.find(*key);
      if (it != const_int_locals.end()) {
        auto lit = std::make_unique<Expr>();
        lit->kind = Expr::Kind::IntLit;
        lit->span = expr.span;
        lit->int_value = it->second;
        return lit;
      }
    }
  }
  if (expr.kind == Expr::Kind::Ident) {
    const auto it = const_int_locals.find(expr.ident);
    if (it != const_int_locals.end()) {
      auto lit = std::make_unique<Expr>();
      lit->kind = Expr::Kind::IntLit;
      lit->span = expr.span;
      lit->int_value = it->second;
      return lit;
    }
    return clone_expr(expr);
  }
  auto out = clone_expr(expr);
  if (out->lhs) {
    out->lhs = fold_const_int_locals(*out->lhs, const_int_locals);
  }
  if (out->rhs) {
    out->rhs = fold_const_int_locals(*out->rhs, const_int_locals);
  }
  if (out->operand) {
    out->operand = fold_const_int_locals(*out->operand, const_int_locals);
  }
  if (out->base) {
    out->base = fold_const_int_locals(*out->base, const_int_locals);
  }
  if (out->index) {
    out->index = fold_const_int_locals(*out->index, const_int_locals);
  }
  for (auto& arg : out->args) {
    if (arg) {
      arg = fold_const_int_locals(*arg, const_int_locals);
    }
  }
  return out;
}

bool expr_statically_true(const Expr& e) {
  if (e.kind == Expr::Kind::Ident && e.ident == "true") {
    return true;
  }
  if (e.kind != Expr::Kind::BinOp || !e.lhs || !e.rhs) {
    return false;
  }
  const auto li = int_lit_value(*e.lhs);
  const auto ri = int_lit_value(*e.rhs);
  if (!li || !ri) {
    return false;
  }
  return compare_int_literals(e.bin_op, *li, *ri);
}

bool expr_statically_false(const Expr& e) {
  if (e.kind == Expr::Kind::Ident && e.ident == "false") {
    return true;
  }
  if (e.kind != Expr::Kind::BinOp || !e.lhs || !e.rhs) {
    return false;
  }
  const auto li = int_lit_value(*e.lhs);
  const auto ri = int_lit_value(*e.rhs);
  if (!li || !ri) {
    return false;
  }
  return !compare_int_literals(e.bin_op, *li, *ri);
}

std::string call_to_user_string(const Expr& call);

std::string expr_to_user_string(const Expr& e) {
  switch (e.kind) {
    case Expr::Kind::IntLit:
      return std::to_string(e.int_value);
    case Expr::Kind::FloatLit: {
      std::ostringstream os;
      os << e.float_value;
      return os.str();
    }
    case Expr::Kind::Ident:
      if (e.ident == "true" || e.ident == "false") {
        return e.ident;
      }
      return e.ident;
    case Expr::Kind::UnaryNot:
      if (e.operand) {
        return "not " + expr_to_user_string(*e.operand);
      }
      return "not ?";
    case Expr::Kind::BinOp:
      if (e.lhs && e.rhs) {
        return expr_to_user_string(*e.lhs) + std::string(" ") + binop_spelling(e.bin_op) +
               std::string(" ") + expr_to_user_string(*e.rhs);
      }
      return "?";
    case Expr::Kind::Call:
      return call_to_user_string(e);
    default:
      return "?";
  }
}

std::string call_to_user_string(const Expr& call) {
  if (call.kind != Expr::Kind::Call) {
    return "?";
  }
  std::ostringstream os;
  os << call.ident << '(';
  for (std::size_t i = 0; i < call.args.size(); ++i) {
    if (i > 0) {
      os << ", ";
    }
    if (call.args[i]) {
      os << expr_to_user_string(*call.args[i]);
    } else {
      os << '?';
    }
  }
  os << ')';
  return os.str();
}

bool is_ge_zero_for_ident(const Expr& e, const std::string& ident) {
  if (e.kind != Expr::Kind::BinOp || e.bin_op != BinOp::Ge || !e.lhs || !e.rhs) {
    return false;
  }
  if (e.lhs->kind != Expr::Kind::Ident || e.lhs->ident != ident) {
    return false;
  }
  const auto rhs = int_lit_value(*e.rhs);
  return rhs && *rhs == 0;
}

bool folded_discharged_by_proof_facts(const Expr& folded, const ProofFacts& facts) {
  if (folded.kind != Expr::Kind::BinOp || !folded.lhs || folded.lhs->kind != Expr::Kind::Ident) {
    return false;
  }
  const std::string& id = folded.lhs->ident;
  if (!is_ge_zero_for_ident(folded, id)) {
    return false;
  }
  if (facts.assum_nonneg_ints.count(id) > 0) {
    return true;
  }
  const auto it = facts.const_int_locals.find(id);
  return it != facts.const_int_locals.end() && it->second >= 0;
}

void note_nonneg_assumption_from_cond(const Expr& cond, std::set<std::string>& out) {
  if (cond.kind == Expr::Kind::BinOp && cond.bin_op == BinOp::And && cond.lhs && cond.rhs) {
    note_nonneg_assumption_from_cond(*cond.lhs, out);
    note_nonneg_assumption_from_cond(*cond.rhs, out);
    return;
  }
  if (cond.kind != Expr::Kind::BinOp || !cond.lhs || !cond.rhs) {
    return;
  }
  if (cond.bin_op == BinOp::Ge) {
    if (cond.lhs->kind == Expr::Kind::Ident) {
      const auto rhs = int_lit_value(*cond.rhs);
      if (rhs && *rhs == 0) {
        out.insert(cond.lhs->ident);
      }
    }
    if (cond.rhs->kind == Expr::Kind::Ident) {
      const auto lhs = int_lit_value(*cond.lhs);
      if (lhs && *lhs == 0) {
        out.insert(cond.rhs->ident);
      }
    }
  }
}

std::vector<std::unique_ptr<Expr>> method_call_arg_list(
    const Expr& receiver, const std::vector<std::unique_ptr<Expr>>& method_args) {
  std::vector<std::unique_ptr<Expr>> args;
  args.push_back(clone_expr(receiver));
  for (const auto& a : method_args) {
    if (a) {
      args.push_back(clone_expr(*a));
    } else {
      args.push_back(nullptr);
    }
  }
  return args;
}

RequiresCheckResult check_requires_with_subst_args(
    const ProcDecl& callee, const std::vector<std::unique_ptr<Expr>>& args,
    const ProofFacts& facts) {
  std::vector<std::string> param_names;
  for (const auto& p : callee.params) {
    param_names.push_back(p.name);
  }
  bool any_unknown = false;
  bool any_violated = false;
  for (const auto& rc : callee.contracts) {
    if (rc.kind != ContractKind::Requires || !rc.expr) {
      continue;
    }
    const auto sub = substitute_call_params(*rc.expr, param_names, args);
    const auto folded = fold_const_int_locals(*sub, facts.const_int_locals);
    if (expr_statically_true(*folded) || folded_discharged_by_proof_facts(*folded, facts)) {
      continue;
    }
    if (expr_statically_false(*folded)) {
      any_violated = true;
      continue;
    }
    any_unknown = true;
  }
  if (any_violated) {
    return RequiresCheckResult::Violated;
  }
  if (any_unknown) {
    return RequiresCheckResult::Unknown;
  }
  return RequiresCheckResult::Satisfied;
}

RequiresCheckResult check_requires_at_call(const ProcDecl& callee, const Expr& call,
                                           const ProofFacts& facts) {
  if (call.kind != Expr::Kind::Call) {
    return RequiresCheckResult::Unknown;
  }
  return check_requires_with_subst_args(callee, call.args, facts);
}

RequiresCheckResult check_requires_at_method_call(
    const ProcDecl& callee, const Expr& receiver,
    const std::vector<std::unique_ptr<Expr>>& method_args, const ProofFacts& facts) {
  return check_requires_with_subst_args(callee, method_call_arg_list(receiver, method_args), facts);
}

std::string method_call_to_user_string(const Expr& receiver, const std::string& method,
                                       const std::vector<std::unique_ptr<Expr>>& method_args) {
  std::ostringstream os;
  os << expr_to_user_string(receiver) << '.' << method << '(';
  for (std::size_t i = 0; i < method_args.size(); ++i) {
    if (i > 0) {
      os << ", ";
    }
    if (method_args[i]) {
      os << expr_to_user_string(*method_args[i]);
    } else {
      os << '?';
    }
  }
  os << ')';
  return os.str();
}

std::optional<RequiresViolationExplanation> explain_requires_violation_with_args(
    const ProcDecl& callee, const std::vector<std::unique_ptr<Expr>>& args,
    const std::string& call_text, const ProofFacts& facts) {
  std::vector<std::string> param_names;
  for (const auto& p : callee.params) {
    param_names.push_back(p.name);
  }
  for (const auto& rc : callee.contracts) {
    if (rc.kind != ContractKind::Requires || !rc.expr) {
      continue;
    }
    const std::string rule_text = expr_to_user_string(*rc.expr);
    const auto sub = substitute_call_params(*rc.expr, param_names, args);
    const auto folded = fold_const_int_locals(*sub, facts.const_int_locals);
    if (!expr_statically_false(*folded) || folded_discharged_by_proof_facts(*folded, facts)) {
      continue;
    }
    RequiresViolationExplanation out;
    const std::string check_text = expr_to_user_string(*folded);
    std::ostringstream msg;
    msg << "Cannot call `" << call_text << "`: `" << callee.name
        << "` requires `" << rule_text << "` before it runs";
    if (check_text != rule_text) {
      msg << ", but here that means `" << check_text << "`";
    }
    msg << ", which is not satisfied";
    if (folded->kind == Expr::Kind::BinOp && folded->lhs && folded->rhs) {
      const auto li = int_lit_value(*folded->lhs);
      const auto ri = int_lit_value(*folded->rhs);
      if (li && ri) {
        msg << " (" << false_comparison_phrase(folded->bin_op, *li, *ri) << ")";
      }
    }
    msg << '.';
    out.message = msg.str();
    std::ostringstream hint;
    hint << "A `requires` clause is a precondition — it must hold for this call. ";
    if (folded->kind == Expr::Kind::BinOp && folded->lhs && folded->rhs) {
      const auto li = int_lit_value(*folded->lhs);
      const auto ri = int_lit_value(*folded->rhs);
      if (li && ri) {
        hint << suggest_fix_for_int_comparison(folded->bin_op, *li, *ri);
      } else {
        hint << "Change the argument so the condition holds, or update the callee's `requires` "
                "if the rule is wrong.";
      }
    } else {
      hint << "Change the argument so the condition holds, or update the callee's `requires` "
              "if the rule is wrong.";
    }
    out.hint = hint.str();
    return out;
  }
  return std::nullopt;
}

std::optional<RequiresViolationExplanation> explain_requires_violation(const ProcDecl& callee,
                                                                       const Expr& call,
                                                                       const ProofFacts& facts) {
  if (call.kind != Expr::Kind::Call) {
    return std::nullopt;
  }
  return explain_requires_violation_with_args(callee, call.args, call_to_user_string(call), facts);
}

std::optional<RequiresViolationExplanation> explain_requires_violation_method(
    const ProcDecl& callee, const Expr& receiver, const std::string& method_name,
    const std::vector<std::unique_ptr<Expr>>& method_args, const ProofFacts& facts) {
  return explain_requires_violation_with_args(
      callee, method_call_arg_list(receiver, method_args),
      method_call_to_user_string(receiver, method_name, method_args), facts);
}

std::optional<ResolvedRefinement> resolve_refinement_on_type(const TypeExpr& te,
                                                             AliasTypeLookup lookup) {
  if (te.kind == TypeKind::Refinement) {
    if (!te.refinement_pred) {
      return std::nullopt;
    }
    ResolvedRefinement out;
    out.bind_var = te.refinement_var;
    out.type_label =
        "{" + te.refinement_var + " | " + expr_to_user_string(*te.refinement_pred) + "}";
    out.predicate = te.refinement_pred.get();
    return out;
  }
  if (te.kind == TypeKind::Named) {
    const TypeExpr* def = lookup(te.name);
    if (def == nullptr) {
      return std::nullopt;
    }
    auto resolved = resolve_refinement_on_type(*def, lookup);
    if (resolved) {
      resolved->type_label = te.name;
    }
    return resolved;
  }
  return std::nullopt;
}

RequiresCheckResult check_refinement_argument(const ResolvedRefinement& refinement,
                                              const Expr& arg, const ProofFacts& facts) {
  if (!refinement.predicate) {
    return RequiresCheckResult::Unknown;
  }
  const auto sub = substitute_refinement_binding(*refinement.predicate, refinement.bind_var, arg);
  const auto folded = fold_const_int_locals(*sub, facts.const_int_locals);
  if (expr_statically_true(*folded) || folded_discharged_by_proof_facts(*folded, facts)) {
    return RequiresCheckResult::Satisfied;
  }
  if (expr_statically_false(*folded)) {
    return RequiresCheckResult::Violated;
  }
  return RequiresCheckResult::Unknown;
}

std::optional<RequiresViolationExplanation> explain_refinement_violation(
    const ResolvedRefinement& refinement, const Expr& arg, const ProofFacts& facts) {
  if (!refinement.predicate) {
    return std::nullopt;
  }
  const std::string value_text = expr_to_user_string(arg);
  const std::string rule_text = expr_to_user_string(*refinement.predicate);
  const auto sub = substitute_refinement_binding(*refinement.predicate, refinement.bind_var, arg);
  const auto folded = fold_const_int_locals(*sub, facts.const_int_locals);
  if (!expr_statically_false(*folded) || folded_discharged_by_proof_facts(*folded, facts)) {
    return std::nullopt;
  }
  RequiresViolationExplanation out;
  const std::string check_text = expr_to_user_string(*folded);
  std::ostringstream msg;
  msg << "Value `" << value_text << "` does not satisfy refinement type `"
      << refinement.type_label << "` (`" << rule_text << "`";
  if (check_text != rule_text) {
    msg << "; here that means `" << check_text << "`";
  }
  msg << "), which is not satisfied";
  if (folded->kind == Expr::Kind::BinOp && folded->lhs && folded->rhs) {
    const auto li = int_lit_value(*folded->lhs);
    const auto ri = int_lit_value(*folded->rhs);
    if (li && ri) {
      msg << " (" << false_comparison_phrase(folded->bin_op, *li, *ri) << ")";
    }
  }
  msg << '.';
  out.message = msg.str();
  std::ostringstream hint;
  hint << "A refinement type declares which values are allowed (e.g. non-negative integers). ";
  if (folded->kind == Expr::Kind::BinOp && folded->lhs && folded->rhs) {
    const auto li = int_lit_value(*folded->lhs);
    const auto ri = int_lit_value(*folded->rhs);
    if (li && ri) {
      hint << suggest_fix_for_refinement(folded->bin_op, *li, *ri);
    } else {
      hint << "Use a value inside the declared range, or relax the refinement on the type alias.";
    }
  } else {
    hint << "Use a value inside the declared range, or relax the refinement on the type alias.";
  }
  out.hint = hint.str();
  return out;
}

void collect_method_calls_in_expr(const Expr& e, std::vector<const Expr*>& out) {
  if (e.kind == Expr::Kind::MethodCall) {
    out.push_back(&e);
  }
  if (e.lhs) {
    collect_method_calls_in_expr(*e.lhs, out);
  }
  if (e.rhs) {
    collect_method_calls_in_expr(*e.rhs, out);
  }
  if (e.operand) {
    collect_method_calls_in_expr(*e.operand, out);
  }
  if (e.base) {
    collect_method_calls_in_expr(*e.base, out);
  }
  if (e.index) {
    collect_method_calls_in_expr(*e.index, out);
  }
  for (const auto& arg : e.args) {
    if (arg) {
      collect_method_calls_in_expr(*arg, out);
    }
  }
}

void collect_idents_in_expr(const Expr& e, std::set<std::string>& out) {
  if (e.kind == Expr::Kind::Ident) {
    out.insert(e.ident);
    return;
  }
  if (e.lhs) {
    collect_idents_in_expr(*e.lhs, out);
  }
  if (e.rhs) {
    collect_idents_in_expr(*e.rhs, out);
  }
  if (e.operand) {
    collect_idents_in_expr(*e.operand, out);
  }
  if (e.base) {
    collect_idents_in_expr(*e.base, out);
  }
  if (e.index) {
    collect_idents_in_expr(*e.index, out);
  }
  for (const auto& arg : e.args) {
    if (arg) {
      collect_idents_in_expr(*arg, out);
    }
  }
}

void collect_calls_in_expr(const Expr& e, std::vector<const Expr*>& out) {
  if (e.kind == Expr::Kind::Call) {
    out.push_back(&e);
  }
  if (e.lhs) {
    collect_calls_in_expr(*e.lhs, out);
  }
  if (e.rhs) {
    collect_calls_in_expr(*e.rhs, out);
  }
  if (e.operand) {
    collect_calls_in_expr(*e.operand, out);
  }
  if (e.base) {
    collect_calls_in_expr(*e.base, out);
  }
  if (e.index) {
    collect_calls_in_expr(*e.index, out);
  }
  for (const auto& arg : e.args) {
    if (arg) {
      collect_calls_in_expr(*arg, out);
    }
  }
}

void collect_method_calls_in_stmts(const std::vector<Stmt>& stmts,
                                   std::vector<const Expr*>& out) {
  for (const auto& s : stmts) {
    if (s.expr) {
      collect_method_calls_in_expr(*s.expr, out);
    }
    if (s.init) {
      collect_method_calls_in_expr(*s.init, out);
    }
    if (s.cond) {
      collect_method_calls_in_expr(*s.cond, out);
    }
    collect_method_calls_in_stmts(s.then_body, out);
    if (s.else_body) {
      collect_method_calls_in_stmts(*s.else_body, out);
    }
    collect_method_calls_in_stmts(s.while_body, out);
    collect_method_calls_in_stmts(s.for_body, out);
    collect_method_calls_in_stmts(s.par_body, out);
  }
}

void collect_calls_in_stmts(const std::vector<Stmt>& stmts,
                            std::vector<const Expr*>& out) {
  for (const auto& s : stmts) {
    if (s.expr) {
      collect_calls_in_expr(*s.expr, out);
    }
    if (s.init) {
      collect_calls_in_expr(*s.init, out);
    }
    if (s.cond) {
      collect_calls_in_expr(*s.cond, out);
    }
    collect_calls_in_stmts(s.then_body, out);
    if (s.else_body) {
      collect_calls_in_stmts(*s.else_body, out);
    }
    collect_calls_in_stmts(s.while_body, out);
    collect_calls_in_stmts(s.for_body, out);
    collect_calls_in_stmts(s.par_body, out);
  }
}

void collect_const_facts_in_stmts(const std::vector<Stmt>& stmts,
                                  std::map<std::string, std::int64_t>& const_int_locals) {
  for (const auto& s : stmts) {
    if (s.kind == Stmt::Kind::VarDecl && s.init && s.init->kind == Expr::Kind::IntLit) {
      const_int_locals[s.var_name] = s.init->int_value;
    }
    if (s.kind == Stmt::Kind::Assign && s.init && s.expr) {
      note_object_field_const_assign(*s.init, *s.expr, const_int_locals);
      if (s.init->kind == Expr::Kind::Ident) {
        if (s.expr->kind == Expr::Kind::IntLit) {
          const_int_locals[s.init->ident] = s.expr->int_value;
        } else if (s.expr->kind == Expr::Kind::Ident) {
          const auto it = const_int_locals.find(s.expr->ident);
          if (it != const_int_locals.end()) {
            const_int_locals[s.init->ident] = it->second;
          }
        }
      }
    }
    collect_const_facts_in_stmts(s.then_body, const_int_locals);
    if (s.else_body) {
      collect_const_facts_in_stmts(*s.else_body, const_int_locals);
    }
    collect_const_facts_in_stmts(s.while_body, const_int_locals);
    collect_const_facts_in_stmts(s.for_body, const_int_locals);
    collect_const_facts_in_stmts(s.par_body, const_int_locals);
  }
}

CallerProofFacts collect_caller_proof_facts(const ProcDecl& caller) {
  CallerProofFacts facts;
  collect_const_facts_in_stmts(caller.body, facts.const_int_locals);
  for (const auto& s : caller.body) {
    if (s.kind == Stmt::Kind::If && s.cond) {
      note_nonneg_assumption_from_cond(*s.cond, facts.assum_nonneg_ints);
    }
  }
  return facts;
}

}  // namespace li
