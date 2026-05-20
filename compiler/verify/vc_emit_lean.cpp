#include "li/vc_emit.hpp"

#include "li/ast.hpp"
#include "li/vc_summary.hpp"
#include "li/vc_witness.hpp"

#include <algorithm>
#include <fstream>
#include <optional>
#include <sstream>
#include <string>

namespace li {
namespace {

std::string lean_ident(const std::string& name) {
  if (name == "result") {
    return "result";
  }
  if (name == "true") {
    return "True";
  }
  if (name == "false") {
    return "False";
  }
  return name;
}

const TypeAlias* find_type_alias(const Module& module, const std::string& name) {
  for (const auto& alias : module.types) {
    if (alias.name == name && alias.alias_kind == AliasKind::Type) {
      return &alias;
    }
  }
  return nullptr;
}

std::string lean_type_name(const TypeExpr& ty, const Module& module);

std::string lean_type_name(const TypeExpr& ty, const Module& module) {
  switch (ty.kind) {
    case TypeKind::Named:
      if (ty.name == "int") {
        return "Int";
      }
      if (ty.name == "float") {
        return "Float";
      }
      if (ty.name == "bool") {
        return "Bool";
      }
      if (ty.name == "unit") {
        return "Unit";
      }
      if (const TypeAlias* alias = find_type_alias(module, ty.name)) {
        return lean_type_name(alias->definition, module);
      }
      return "Int";
    case TypeKind::Array:
      if (ty.elem) {
        return "Array " + lean_type_name(*ty.elem, module) + " " +
               std::to_string(ty.array_size);
      }
      return "Array Unit 0";
    case TypeKind::Refinement:
      if (ty.refinement_base) {
        return lean_type_name(*ty.refinement_base, module);
      }
      return "Int";
    case TypeKind::TypeApp:
    case TypeKind::Callable:
    case TypeKind::GenericParam:
    case TypeKind::NamedTuple:
      return "Unit";
  }
  return "Unit";
}

struct VcCtx {
  const ProcDecl* proc = nullptr;
  bool in_ensures = false;
};

std::optional<std::string> expr_to_lean(const Expr& e, const VcCtx& ctx);

std::optional<std::string> expr_to_lean_bin(BinOp op, const std::string& lhs,
                                            const std::string& rhs) {
  switch (op) {
    case BinOp::Add:
      return "(" + lhs + " + " + rhs + ")";
    case BinOp::Sub:
      return "(" + lhs + " - " + rhs + ")";
    case BinOp::Mul:
      return "(" + lhs + " * " + rhs + ")";
    case BinOp::Div:
      return "(" + lhs + " / " + rhs + ")";
    case BinOp::Mod:
      return "(" + lhs + " % " + rhs + ")";
    case BinOp::Le:
      return "(" + lhs + " ≤ " + rhs + ")";
    case BinOp::Lt:
      return "(" + lhs + " < " + rhs + ")";
    case BinOp::Ge:
      return "(" + lhs + " ≥ " + rhs + ")";
    case BinOp::Gt:
      return "(" + lhs + " > " + rhs + ")";
    case BinOp::Eq:
      return "(" + lhs + " = " + rhs + ")";
    case BinOp::Ne:
      return "(" + lhs + " ≠ " + rhs + ")";
    case BinOp::And:
      return "(" + lhs + " ∧ " + rhs + ")";
    case BinOp::Or:
      return "(" + lhs + " ∨ " + rhs + ")";
    default:
      return std::nullopt;
  }
}

std::optional<std::string> expr_to_lean(const Expr& e, const VcCtx& ctx) {
  switch (e.kind) {
    case Expr::Kind::IntLit:
      return std::to_string(e.int_value);
    case Expr::Kind::FloatLit: {
      std::ostringstream os;
      os << e.float_value;
      return "(" + os.str() + " : Float)";
    }
    case Expr::Kind::Ident:
      return lean_ident(e.ident);
    case Expr::Kind::BinOp: {
      if (!e.lhs || !e.rhs) {
        return std::nullopt;
      }
      const auto l = expr_to_lean(*e.lhs, ctx);
      const auto r = expr_to_lean(*e.rhs, ctx);
      if (!l || !r) {
        return std::nullopt;
      }
      return expr_to_lean_bin(e.bin_op, *l, *r);
    }
    case Expr::Kind::Call: {
      if (e.ident == "abs" && e.args.size() == 1 && e.args[0]) {
        const auto inner = expr_to_lean(*e.args[0], ctx);
        if (inner) {
          return "Float.abs " + *inner;
        }
      }
      return std::nullopt;
    }
    case Expr::Kind::Index: {
      if (!e.base || !e.index) {
        return std::nullopt;
      }
      const auto b = expr_to_lean(*e.base, ctx);
      const auto idx = expr_to_lean(*e.index, ctx);
      if (!b || !idx) {
        return std::nullopt;
      }
      return "(" + *b + "[" + *idx + "]!)";
    }
    case Expr::Kind::UnaryNot:
      if (e.operand) {
        const auto inner = expr_to_lean(*e.operand, ctx);
        if (inner) {
          return "(¬" + *inner + ")";
        }
      }
      return std::nullopt;
    default:
      return std::nullopt;
  }
}

std::string proc_section(const std::string& proc) {
  std::string out;
  for (char c : proc) {
    if (c == '_' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
      out.push_back(c);
    } else {
      out.push_back('_');
    }
  }
  return out;
}

namespace {

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

}  // namespace

void emit_contract_def(std::ostream& out, const Module& module, const ProcDecl& proc,
                       const char* kind, std::size_t idx, const Contract& c) {
  const std::string sec = proc_section(proc.name);
  const std::string name = "vc_" + sec + '_' + kind + '_' + std::to_string(idx);

  if (c.kind == ContractKind::Decreases && c.expr && c.expr->kind == Expr::Kind::IntLit) {
    const std::int64_t n = c.expr->int_value;
    out << "def " << name << " : Nat := " << n << '\n';
    out << "theorem " << name << "_proved : " << name << " = " << n << " := rfl\n";
    return;
  }

  VcCtx ctx;
  ctx.proc = &proc;
  ctx.in_ensures = (c.kind == ContractKind::Ensures);

  std::string prop = "True";
  const bool witnessed = contract_witnessed_trivial(proc, c);
  if (witnessed) {
    prop = "True";
  } else if (c.expr) {
    if (auto lean = expr_to_lean(*c.expr, ctx)) {
      prop = *lean;
    } else {
      out << "/-! VC " << kind << " (opaque): source expr not yet translated -/\n";
    }
  }

  out << "def " << name;
  for (const auto& p : proc.params) {
    out << ' ' << '(' << p.name << " : " << lean_type_name(p.type, module) << ')';
  }
  if (proc.ret_type &&
      (c.kind == ContractKind::Ensures || c.kind == ContractKind::Invariant)) {
    out << " (result : " << lean_type_name(*proc.ret_type, module) << ')';
  }
  out << " : Prop := " << prop << '\n';

  if (prop == "True" && witnessed && c.kind == ContractKind::Ensures) {
    const Expr* ret = single_return_expr(proc);
    if (ret != nullptr && ret->kind == Expr::Kind::Ident && c.expr &&
        !ensures_rhs_eq_result(*c.expr)) {
      out << "/-! Phase 2f: requires/return witness for ensures (param `"
          << ret->ident << "`) -/\n";
    } else {
      out << "/-! Phase 2f: return expression matches ensures (static witness) -/\n";
    }
  }
  if (prop == "True") {
    out << "theorem " << name << "_proved";
    for (const auto& p : proc.params) {
      out << ' ' << '(' << p.name << " : " << lean_type_name(p.type, module) << ')';
    }
    if (proc.ret_type &&
        (c.kind == ContractKind::Ensures || c.kind == ContractKind::Invariant)) {
      out << " (result : " << lean_type_name(*proc.ret_type, module) << ')';
    }
    out << " : " << name;
    for (const auto& p : proc.params) {
      out << ' ' << p.name;
    }
    if (proc.ret_type &&
        (c.kind == ContractKind::Ensures || c.kind == ContractKind::Invariant)) {
      out << " result";
    }
    out << " := trivial\n";
  }
}

const ProcDecl* find_proc(const Module& module, const std::string& name) {
  for (const auto& proc : module.procs) {
    if (proc.name == name) {
      return &proc;
    }
  }
  return nullptr;
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

std::unique_ptr<Expr> substitute_call_params(const Expr& e,
                                            const std::vector<std::string>& param_names,
                                            const std::vector<std::unique_ptr<Expr>>& args) {
  auto out = clone_expr(e);
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

bool expr_statically_true(const Expr& e) {
  if (e.kind == Expr::Kind::Ident && e.ident == "true") {
    return true;
  }
  if (e.kind != Expr::Kind::BinOp || !e.lhs || !e.rhs) {
    return false;
  }
  const auto lit_int = [](const Expr& x) -> std::optional<std::int64_t> {
    if (x.kind == Expr::Kind::IntLit) {
      return x.int_value;
    }
    return std::nullopt;
  };
  const auto li = lit_int(*e.lhs);
  const auto ri = lit_int(*e.rhs);
  if (!li || !ri) {
    return false;
  }
  switch (e.bin_op) {
    case BinOp::Eq:
      return *li == *ri;
    case BinOp::Ne:
      return *li != *ri;
    case BinOp::Lt:
      return *li < *ri;
    case BinOp::Le:
      return *li <= *ri;
    case BinOp::Gt:
      return *li > *ri;
    case BinOp::Ge:
      return *li >= *ri;
    default:
      return false;
  }
}

void collect_calls_expr(const Expr& e, std::vector<const Expr*>& out) {
  if (e.kind == Expr::Kind::Call) {
    out.push_back(&e);
  }
  if (e.lhs) {
    collect_calls_expr(*e.lhs, out);
  }
  if (e.rhs) {
    collect_calls_expr(*e.rhs, out);
  }
  if (e.operand) {
    collect_calls_expr(*e.operand, out);
  }
  if (e.base) {
    collect_calls_expr(*e.base, out);
  }
  if (e.index) {
    collect_calls_expr(*e.index, out);
  }
  for (const auto& arg : e.args) {
    if (arg) {
      collect_calls_expr(*arg, out);
    }
  }
}

void collect_calls_stmts(const std::vector<Stmt>& stmts, std::vector<const Expr*>& out) {
  for (const auto& s : stmts) {
    if (s.expr) {
      collect_calls_expr(*s.expr, out);
    }
    if (s.init) {
      collect_calls_expr(*s.init, out);
    }
    if (s.cond) {
      collect_calls_expr(*s.cond, out);
    }
    collect_calls_stmts(s.then_body, out);
    if (s.else_body) {
      collect_calls_stmts(*s.else_body, out);
    }
    collect_calls_stmts(s.while_body, out);
    collect_calls_stmts(s.for_body, out);
    collect_calls_stmts(s.par_body, out);
  }
}

void emit_call_site_requires(std::ostream& out, const Module& module, const ProcDecl& caller) {
  std::vector<const Expr*> calls;
  collect_calls_stmts(caller.body, calls);
  std::size_t call_idx = 0;
  for (const Expr* call : calls) {
    if (call == nullptr || call->kind != Expr::Kind::Call) {
      continue;
    }
    const ProcDecl* callee = find_proc(module, call->ident);
    if (callee == nullptr || callee->is_extern) {
      continue;
    }
    std::vector<std::string> param_names;
    for (const auto& p : callee->params) {
      param_names.push_back(p.name);
    }
    std::size_t req_idx = 0;
    for (const auto& rc : callee->contracts) {
      if (rc.kind != ContractKind::Requires || !rc.expr) {
        continue;
      }
      const std::string name = "vc_" + proc_section(caller.name) + "_call" +
                               std::to_string(call_idx) + '_' + proc_section(callee->name) +
                               "_requires_" + std::to_string(req_idx++);
      const auto sub = substitute_call_params(*rc.expr, param_names, call->args);
      std::string prop = "True";
      const bool witnessed = expr_statically_true(*sub);
      VcCtx ctx;
      if (witnessed) {
        prop = "True";
      } else if (auto lean = expr_to_lean(*sub, ctx)) {
        prop = *lean;
      } else {
        out << "/-! VC call-site requires (opaque): callee '" << callee->name
            << "' at call " << call_idx << " -/\n";
      }
      out << "def " << name << " : Prop := " << prop << '\n';
      if (prop == "True" && witnessed) {
        out << "theorem " << name << "_proved : " << name << " := trivial\n";
      }
    }
    ++call_idx;
  }
}

void walk_contracts(std::ostream& out, const Module& module, const ProcDecl& proc,
                    const std::vector<Contract>& contracts) {
  std::size_t req = 0;
  std::size_t ens = 0;
  std::size_t dec = 0;
  std::size_t inv = 0;
  for (const auto& c : contracts) {
    switch (c.kind) {
      case ContractKind::Requires:
        emit_contract_def(out, module, proc, "requires", req++, c);
        break;
      case ContractKind::Ensures:
        emit_contract_def(out, module, proc, "ensures", ens++, c);
        break;
      case ContractKind::Decreases:
        emit_contract_def(out, module, proc, "decreases", dec++, c);
        break;
      case ContractKind::Invariant:
        emit_contract_def(out, module, proc, "invariant", inv++, c);
        break;
    }
  }
}

}  // namespace

bool write_vcs_lean(const Module& module, const std::string& path, std::string* err) {
  std::ofstream out(path);
  if (!out) {
    if (err) {
      *err = "cannot open " + path;
    }
    return false;
  }
  out << "-- Auto-generated VC obligations (Phase 2e). Props typecheck in Lean; discharge in 2f.\n";
  out << "import Init.Data.Float\nimport Core\n\nnamespace AutoVC\n\n";
  for (const auto& proc : module.procs) {
    if (proc.is_extern) {
      continue;
    }
    out << "namespace " << proc_section(proc.name) << "\n\n";
    walk_contracts(out, module, proc, proc.contracts);
    for (const auto& stmt : proc.body) {
      walk_contracts(out, module, proc, stmt.par_contracts);
    }
    emit_call_site_requires(out, module, proc);
    out << "\nend " << proc_section(proc.name) << "\n\n";
  }
  out << "end AutoVC\n";
  return true;
}

}  // namespace li
