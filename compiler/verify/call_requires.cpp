#include "li/call_requires.hpp"

#include <optional>

namespace li {
namespace {

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
