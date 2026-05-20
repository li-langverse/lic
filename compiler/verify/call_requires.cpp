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

std::unique_ptr<Expr> fold_const_int_locals(
    const Expr& expr, const std::map<std::string, std::int64_t>& const_int_locals) {
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

RequiresCheckResult check_requires_at_call(
    const ProcDecl& callee, const Expr& call,
    const std::map<std::string, std::int64_t>& const_int_locals) {
  if (call.kind != Expr::Kind::Call) {
    return RequiresCheckResult::Unknown;
  }
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
    const auto sub = substitute_call_params(*rc.expr, param_names, call.args);
    const auto folded = fold_const_int_locals(*sub, const_int_locals);
    if (expr_statically_true(*folded)) {
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

std::optional<RequiresViolationExplanation> explain_requires_violation(
    const ProcDecl& callee, const Expr& call,
    const std::map<std::string, std::int64_t>& const_int_locals) {
  if (call.kind != Expr::Kind::Call) {
    return std::nullopt;
  }
  std::vector<std::string> param_names;
  for (const auto& p : callee.params) {
    param_names.push_back(p.name);
  }
  const std::string call_text = call_to_user_string(call);
  for (const auto& rc : callee.contracts) {
    if (rc.kind != ContractKind::Requires || !rc.expr) {
      continue;
    }
    const std::string rule_text = expr_to_user_string(*rc.expr);
    const auto sub = substitute_call_params(*rc.expr, param_names, call.args);
    const auto folded = fold_const_int_locals(*sub, const_int_locals);
    if (!expr_statically_false(*folded)) {
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

RequiresCheckResult check_refinement_argument(
    const ResolvedRefinement& refinement, const Expr& arg,
    const std::map<std::string, std::int64_t>& const_int_locals) {
  if (!refinement.predicate) {
    return RequiresCheckResult::Unknown;
  }
  const auto sub = substitute_refinement_binding(*refinement.predicate, refinement.bind_var, arg);
  const auto folded = fold_const_int_locals(*sub, const_int_locals);
  if (expr_statically_true(*folded)) {
    return RequiresCheckResult::Satisfied;
  }
  if (expr_statically_false(*folded)) {
    return RequiresCheckResult::Violated;
  }
  return RequiresCheckResult::Unknown;
}

std::optional<RequiresViolationExplanation> explain_refinement_violation(
    const ResolvedRefinement& refinement, const Expr& arg,
    const std::map<std::string, std::int64_t>& const_int_locals) {
  if (!refinement.predicate) {
    return std::nullopt;
  }
  const std::string value_text = expr_to_user_string(arg);
  const std::string rule_text = expr_to_user_string(*refinement.predicate);
  const auto sub = substitute_refinement_binding(*refinement.predicate, refinement.bind_var, arg);
  const auto folded = fold_const_int_locals(*sub, const_int_locals);
  if (!expr_statically_false(*folded)) {
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

}  // namespace li
