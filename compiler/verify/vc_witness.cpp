#include "li/vc_witness.hpp"

#include <memory>

namespace li {

const Expr* single_return_expr(const ProcDecl& proc) {
  for (const auto& stmt : proc.body) {
    if (stmt.kind == Stmt::Kind::Return && stmt.expr) {
      return stmt.expr.get();
    }
  }
  return nullptr;
}

namespace {

bool numeric_same_value(const Expr& a, const Expr& b) {
  if (a.kind == Expr::Kind::IntLit && b.kind == Expr::Kind::IntLit) {
    return a.int_value == b.int_value;
  }
  if (a.kind == Expr::Kind::FloatLit && b.kind == Expr::Kind::FloatLit) {
    return a.float_value == b.float_value;
  }
  if (a.kind == Expr::Kind::IntLit && b.kind == Expr::Kind::FloatLit) {
    return static_cast<double>(a.int_value) == b.float_value;
  }
  if (a.kind == Expr::Kind::FloatLit && b.kind == Expr::Kind::IntLit) {
    return a.float_value == static_cast<double>(b.int_value);
  }
  return false;
}

bool expr_same_shape(const Expr& a, const Expr& b) {
  if (a.kind != b.kind) {
    return numeric_same_value(a, b);
  }
  switch (a.kind) {
    case Expr::Kind::IntLit:
      return a.int_value == b.int_value;
    case Expr::Kind::FloatLit:
      return a.float_value == b.float_value;
    case Expr::Kind::Ident:
      return a.ident == b.ident;
    case Expr::Kind::Index:
      return a.base && b.base && a.index && b.index && expr_same_shape(*a.base, *b.base) &&
             expr_same_shape(*a.index, *b.index);
    case Expr::Kind::BinOp:
      return a.bin_op == b.bin_op && a.lhs && b.lhs && a.rhs && b.rhs &&
             expr_same_shape(*a.lhs, *b.lhs) && expr_same_shape(*a.rhs, *b.rhs);
    default:
      return false;
  }
}

bool is_true_literal(const Expr& e) {
  return e.kind == Expr::Kind::Ident && e.ident == "true";
}

const Expr* ensures_rhs_eq_result(const Expr& e) {
  if (e.kind != Expr::Kind::BinOp || e.bin_op != BinOp::Eq || !e.lhs || !e.rhs) {
    return nullptr;
  }
  if (e.lhs->kind == Expr::Kind::Ident && e.lhs->ident == "result") {
    return e.rhs.get();
  }
  if (e.rhs->kind == Expr::Kind::Ident && e.rhs->ident == "result") {
    return e.lhs.get();
  }
  return nullptr;
}

std::unique_ptr<Expr> substitute_ident(const Expr& e, const std::string& from,
                                       const std::string& to) {
  auto out = std::make_unique<Expr>();
  out->span = e.span;
  out->kind = e.kind;
  out->int_value = e.int_value;
  out->float_value = e.float_value;
  out->str_value = e.str_value;
  out->ident = e.ident;
  out->bin_op = e.bin_op;
  out->field_name = e.field_name;
  if (e.kind == Expr::Kind::Ident && e.ident == from) {
    out->ident = to;
    return out;
  }
  if (e.lhs) {
    out->lhs = substitute_ident(*e.lhs, from, to);
  }
  if (e.rhs) {
    out->rhs = substitute_ident(*e.rhs, from, to);
  }
  if (e.operand) {
    out->operand = substitute_ident(*e.operand, from, to);
  }
  if (e.base) {
    out->base = substitute_ident(*e.base, from, to);
  }
  if (e.index) {
    out->index = substitute_ident(*e.index, from, to);
  }
  for (const auto& arg : e.args) {
    if (arg) {
      out->args.push_back(substitute_ident(*arg, from, to));
    }
  }
  return out;
}

bool ensures_subst_matches_requires(const ProcDecl& proc, const Contract& ens) {
  if (!ens.expr || ens.kind != ContractKind::Ensures) {
    return false;
  }
  const Expr* ret = single_return_expr(proc);
  if (ret == nullptr || ret->kind != Expr::Kind::Ident) {
    return false;
  }
  const auto sub = substitute_ident(*ens.expr, "result", ret->ident);
  if (!sub) {
    return false;
  }
  for (const auto& rc : proc.contracts) {
    if (rc.kind == ContractKind::Requires && rc.expr && expr_same_shape(*sub, *rc.expr)) {
      return true;
    }
  }
  return false;
}

bool comparison_mirror_requires_ensures(const Expr& req, const Expr& ens,
                                        const std::string& param) {
  if (req.kind != Expr::Kind::BinOp || ens.kind != Expr::Kind::BinOp ||
      req.bin_op != ens.bin_op || !req.lhs || !req.rhs || !ens.lhs || !ens.rhs) {
    return false;
  }
  if (!numeric_same_value(*req.rhs, *ens.rhs)) {
    return false;
  }
  if (req.lhs->kind == Expr::Kind::Ident && req.lhs->ident == param &&
      ens.lhs->kind == Expr::Kind::Ident && ens.lhs->ident == "result") {
    return true;
  }
  if (req.rhs->kind == Expr::Kind::Ident && req.rhs->ident == param &&
      ens.rhs->kind == Expr::Kind::Ident && ens.rhs->ident == "result") {
    return true;
  }
  return false;
}

const MirInsn* last_return_insn(const MirFn& fn) {
  for (auto it = fn.body.rbegin(); it != fn.body.rend(); ++it) {
    switch (it->op) {
      case MirOp::ReturnVoid:
      case MirOp::ReturnInt:
      case MirOp::ReturnFloat:
      case MirOp::ReturnIdent:
        return &*it;
      default:
        break;
    }
  }
  return nullptr;
}

}  // namespace

bool contract_witnessed_trivial(const ProcDecl& proc, const Contract& c) {
  if (!c.expr) {
    return false;
  }
  if (is_true_literal(*c.expr)) {
    return true;
  }
  if (c.kind != ContractKind::Ensures) {
    return false;
  }
  const Expr* rhs = ensures_rhs_eq_result(*c.expr);
  const Expr* ret = single_return_expr(proc);
  if (rhs != nullptr && ret != nullptr && expr_same_shape(*ret, *rhs)) {
    return true;
  }
  if (ret != nullptr && ret->kind == Expr::Kind::Ident) {
    for (const auto& rc : proc.contracts) {
      if (rc.kind == ContractKind::Requires && rc.expr &&
          comparison_mirror_requires_ensures(*rc.expr, *c.expr, ret->ident)) {
        return true;
      }
    }
    if (ensures_subst_matches_requires(proc, c)) {
      return true;
    }
  }
  return false;
}

bool mir_return_links_proc(const MirFn& fn, const ProcDecl& proc) {
  const Expr* ast_ret = single_return_expr(proc);
  const MirInsn* mir_ret = last_return_insn(fn);
  if (ast_ret == nullptr || mir_ret == nullptr) {
    return false;
  }
  switch (ast_ret->kind) {
    case Expr::Kind::IntLit:
      return mir_ret->op == MirOp::ReturnInt && mir_ret->int_value == ast_ret->int_value;
    case Expr::Kind::FloatLit:
      return mir_ret->op == MirOp::ReturnFloat && mir_ret->float_value == ast_ret->float_value;
    case Expr::Kind::Ident:
      return mir_ret->op == MirOp::ReturnIdent && mir_ret->ident == ast_ret->ident;
    default:
      return false;
  }
}

VcWitnessStats compute_vc_witness_stats(const Module& module, const MirModule* mir) {
  VcWitnessStats stats;
  for (const auto& proc : module.procs) {
    if (proc.is_extern) {
      continue;
    }
    bool has_witnessed_ensure = false;
    for (const auto& c : proc.contracts) {
      if (c.kind == ContractKind::Ensures) {
        ++stats.ensures_total;
        if (contract_witnessed_trivial(proc, c)) {
          ++stats.ensures_witnessed;
          has_witnessed_ensure = true;
        }
      }
    }
    if (mir != nullptr && has_witnessed_ensure) {
      for (const auto& fn : mir->functions) {
        if (fn.name == proc.name && mir_return_links_proc(fn, proc)) {
          ++stats.mir_return_linked;
          break;
        }
      }
    }
  }
  return stats;
}

}  // namespace li
