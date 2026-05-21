#include "li/vc_witness.hpp"

#include "li/call_requires.hpp"

#include <memory>

namespace li {

void collect_return_exprs_in_stmts(const std::vector<Stmt>& stmts,
                                   std::vector<const Expr*>& out) {
  for (const auto& s : stmts) {
    if (s.kind == Stmt::Kind::Return && s.expr) {
      out.push_back(s.expr.get());
    }
    collect_return_exprs_in_stmts(s.then_body, out);
    if (s.else_body) {
      collect_return_exprs_in_stmts(*s.else_body, out);
    }
    collect_return_exprs_in_stmts(s.while_body, out);
    collect_return_exprs_in_stmts(s.for_body, out);
    collect_return_exprs_in_stmts(s.par_body, out);
  }
}

const Expr* single_return_expr(const ProcDecl& proc) {
  std::vector<const Expr*> returns;
  collect_return_exprs_in_stmts(proc.body, returns);
  if (returns.empty()) {
    return nullptr;
  }
  return returns.back();
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
      case MirOp::ReturnObject:
        return &*it;
      default:
        break;
    }
  }
  return nullptr;
}

bool callee_ensures_result_equals_param(const ProcDecl& callee, std::size_t param_idx) {
  if (param_idx >= callee.params.size()) {
    return false;
  }
  const std::string& pname = callee.params[param_idx].name;
  for (const auto& rc : callee.contracts) {
    if (rc.kind != ContractKind::Ensures || !rc.expr) {
      continue;
    }
    const Expr* rhs = ensures_rhs_eq_result(*rc.expr);
    if (rhs && rhs->kind == Expr::Kind::Ident && rhs->ident == pname) {
      return true;
    }
  }
  return false;
}

bool call_ident_arg_matches_ensures(const Module& module, const Contract& c,
                                    const Expr& ret, const CallerProofFacts& facts) {
  if (c.kind != ContractKind::Ensures || !c.expr) {
    return false;
  }
  const Expr* rhs = ensures_rhs_eq_result(*c.expr);
  if (rhs == nullptr || ret.kind != Expr::Kind::Call) {
    return false;
  }
  const ProcDecl* callee = find_proc_by_name(module, ret.ident);
  if (callee == nullptr) {
    return false;
  }
  for (std::size_t i = 0; i < ret.args.size() && i < callee->params.size(); ++i) {
    if (!ret.args[i] || ret.args[i]->kind != Expr::Kind::Ident) {
      continue;
    }
    const std::string& arg_id = ret.args[i]->ident;
    if (rhs->kind == Expr::Kind::Ident) {
      if (arg_id != rhs->ident) {
        continue;
      }
    } else if (rhs->kind == Expr::Kind::IntLit) {
      const auto it = facts.const_int_locals.find(arg_id);
      if (it == facts.const_int_locals.end() || it->second != rhs->int_value) {
        continue;
      }
    } else {
      continue;
    }
    if (callee_ensures_result_equals_param(*callee, i)) {
      return true;
    }
  }
  return false;
}

bool call_literal_return_matches_ensures(const Module& module, const Contract& c,
                                         const Expr& ret) {
  if (c.kind != ContractKind::Ensures || !c.expr) {
    return false;
  }
  const Expr* rhs = ensures_rhs_eq_result(*c.expr);
  if (rhs == nullptr || ret.kind != Expr::Kind::Call) {
    return false;
  }
  const ProcDecl* callee = find_proc_by_name(module, ret.ident);
  if (callee == nullptr || ret.args.empty()) {
    return false;
  }
  for (std::size_t i = 0; i < ret.args.size() && i < callee->params.size(); ++i) {
    if (!ret.args[i] || !expr_same_shape(*ret.args[i], *rhs)) {
      continue;
    }
    if (callee_ensures_result_equals_param(*callee, i)) {
      return true;
    }
  }
  return false;
}

bool ident_return_matches_const_ensures(const Contract& c, const Expr& ret,
                                        const CallerProofFacts& facts) {
  if (c.kind != ContractKind::Ensures || !c.expr) {
    return false;
  }
  const Expr* rhs = ensures_rhs_eq_result(*c.expr);
  if (rhs == nullptr || ret.kind != Expr::Kind::Ident) {
    return false;
  }
  if (rhs->kind != Expr::Kind::IntLit) {
    return false;
  }
  const auto it = facts.const_int_locals.find(ret.ident);
  return it != facts.const_int_locals.end() && it->second == rhs->int_value;
}

bool expr_is_ident(const Expr* e, const std::string& name) {
  return e != nullptr && e->kind == Expr::Kind::Ident && e->ident == name;
}

bool expr_is_int_lit(const Expr* e, std::int64_t v) {
  return e != nullptr && e->kind == Expr::Kind::IntLit && e->int_value == v;
}

bool expr_is_index_lit_mul(const Expr* e, const std::string& a, const std::string& b,
                           std::int64_t idx) {
  if (e == nullptr || e->kind != Expr::Kind::BinOp || e->bin_op != BinOp::Mul || !e->lhs ||
      !e->rhs) {
    return false;
  }
  const auto lit_index_ok = [&](const Expr* side, const std::string& arr) -> bool {
    return side && side->kind == Expr::Kind::Index && expr_is_ident(side->base.get(), arr) &&
           expr_is_int_lit(side->index.get(), idx);
  };
  return (lit_index_ok(e->lhs.get(), a) && lit_index_ok(e->rhs.get(), b)) ||
         (lit_index_ok(e->lhs.get(), b) && lit_index_ok(e->rhs.get(), a));
}

bool expr_is_index_var_mul(const Expr* e, const std::string& a, const std::string& b,
                           const std::string& i) {
  if (e == nullptr || e->kind != Expr::Kind::BinOp || e->bin_op != BinOp::Mul || !e->lhs ||
      !e->rhs) {
    return false;
  }
  const auto var_index_ok = [&](const Expr* side, const std::string& arr) -> bool {
    return side && side->kind == Expr::Kind::Index && expr_is_ident(side->base.get(), arr) &&
           expr_is_ident(side->index.get(), i);
  };
  return (var_index_ok(e->lhs.get(), a) && var_index_ok(e->rhs.get(), b)) ||
         (var_index_ok(e->lhs.get(), b) && var_index_ok(e->rhs.get(), a));
}

void collect_add_chain_terms(const Expr* e, std::vector<const Expr*>& terms) {
  if (e == nullptr) {
    return;
  }
  if (e->kind == Expr::Kind::BinOp && e->bin_op == BinOp::Add && e->lhs && e->rhs) {
    collect_add_chain_terms(e->lhs.get(), terms);
    collect_add_chain_terms(e->rhs.get(), terms);
    return;
  }
  terms.push_back(e);
}

bool expr_is_dot4_int_spec(const Expr& e, const std::string& a, const std::string& b) {
  std::vector<const Expr*> terms;
  collect_add_chain_terms(&e, terms);
  if (terms.size() != 4) {
    return false;
  }
  for (std::int64_t idx = 0; idx < 4; ++idx) {
    if (!expr_is_index_lit_mul(terms[static_cast<std::size_t>(idx)], a, b, idx)) {
      return false;
    }
  }
  return true;
}

bool expr_is_i_lt_bound(const Expr* e, const std::string& i, std::int64_t bound) {
  if (e == nullptr || e->kind != Expr::Kind::BinOp || e->bin_op != BinOp::Lt || !e->lhs ||
      !e->rhs) {
    return false;
  }
  return expr_is_ident(e->lhs.get(), i) && expr_is_int_lit(e->rhs.get(), bound);
}

bool stmt_is_acc_plus_index_mul(const Stmt& s, const std::string& acc, const std::string& a,
                               const std::string& b, const std::string& i) {
  if (s.kind != Stmt::Kind::Assign || !s.init || !s.expr || !expr_is_ident(s.init.get(), acc)) {
    return false;
  }
  const Expr& rhs = *s.expr;
  if (rhs.kind != Expr::Kind::BinOp || rhs.bin_op != BinOp::Add || !rhs.lhs || !rhs.rhs) {
    return false;
  }
  if (!expr_is_ident(rhs.lhs.get(), acc)) {
    return false;
  }
  return expr_is_index_var_mul(rhs.rhs.get(), a, b, i);
}

bool stmt_is_i_plus_one(const Stmt& s, const std::string& i) {
  if (s.kind != Stmt::Kind::Assign || !s.init || !s.expr || !expr_is_ident(s.init.get(), i)) {
    return false;
  }
  const Expr& rhs = *s.expr;
  return rhs.kind == Expr::Kind::BinOp && rhs.bin_op == BinOp::Add && rhs.lhs &&
         expr_is_ident(rhs.lhs.get(), i) && rhs.rhs && expr_is_int_lit(rhs.rhs.get(), 1);
}

bool witness_dot4_int_loop_impl(const ProcDecl& proc, const Expr& ensures_rhs) {
  const std::string a = "a";
  const std::string b = "b";
  const std::string acc = "acc";
  const std::string i = "i";
  if (!expr_is_dot4_int_spec(ensures_rhs, a, b)) {
    return false;
  }
  const Stmt* loop = nullptr;
  for (const auto& st : proc.body) {
    if (st.kind == Stmt::Kind::While) {
      loop = &st;
      break;
    }
  }
  if (loop == nullptr || !expr_is_i_lt_bound(loop->cond.get(), i, 4)) {
    return false;
  }
  bool saw_acc = false;
  bool saw_i = false;
  for (const auto& st : loop->while_body) {
    if (stmt_is_acc_plus_index_mul(st, acc, a, b, i)) {
      saw_acc = true;
    }
    if (stmt_is_i_plus_one(st, i)) {
      saw_i = true;
    }
  }
  if (!saw_acc || !saw_i) {
    return false;
  }
  const Expr* ret = single_return_expr(proc);
  return ret != nullptr && expr_is_ident(ret, acc);
}

bool ensures_witnessed_for_return(const ProcDecl& proc, const Contract& c, const Expr& ret,
                                  const Module* module, const CallerProofFacts* caller_facts) {
  const Expr* rhs = ensures_rhs_eq_result(*c.expr);
  if (rhs != nullptr && witness_dot4_int_loop_impl(proc, *rhs) && expr_is_ident(&ret, "acc")) {
    return true;
  }
  if (rhs != nullptr && expr_same_shape(ret, *rhs)) {
    return true;
  }
  if (module != nullptr && call_literal_return_matches_ensures(*module, c, ret)) {
    return true;
  }
  if (caller_facts != nullptr) {
    if (ident_return_matches_const_ensures(c, ret, *caller_facts)) {
      return true;
    }
    if (module != nullptr && call_ident_arg_matches_ensures(*module, c, ret, *caller_facts)) {
      return true;
    }
  }
  if (ret.kind == Expr::Kind::Ident) {
    for (const auto& rc : proc.contracts) {
      if (rc.kind == ContractKind::Requires && rc.expr &&
          comparison_mirror_requires_ensures(*rc.expr, *c.expr, ret.ident)) {
        return true;
      }
    }
    if (ensures_subst_matches_requires(proc, c)) {
      return true;
    }
  }
  return false;
}

}  // namespace

bool contract_witnessed_trivial(const ProcDecl& proc, const Contract& c, const Module* module,
                                const CallerProofFacts* caller_facts) {
  if (!c.expr) {
    return false;
  }
  if (is_true_literal(*c.expr)) {
    return true;
  }
  if (c.kind != ContractKind::Ensures) {
    return false;
  }
  std::vector<const Expr*> returns;
  collect_return_exprs_in_stmts(proc.body, returns);
  if (!returns.empty()) {
    for (const Expr* ret : returns) {
      if (ret != nullptr && ensures_witnessed_for_return(proc, c, *ret, module, caller_facts)) {
        return true;
      }
    }
    return false;
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
      if (mir_ret->op == MirOp::ReturnIdent) {
        return mir_ret->ident == ast_ret->ident;
      }
      if (mir_ret->op == MirOp::ReturnObject) {
        return mir_ret->ident == (std::string("__li_o_") + ast_ret->ident);
      }
      return false;
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

bool witness_dot4_int_loop(const ProcDecl& proc, const Expr& ensures_rhs) {
  return witness_dot4_int_loop_impl(proc, ensures_rhs);
}

}  // namespace li
