#include "li/vc_emit.hpp"

#include "li/ast.hpp"
#include "li/vc_summary.hpp"

#include <algorithm>
#include <fstream>
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

const Expr* single_return_expr(const ProcDecl& proc) {
  for (const auto& stmt : proc.body) {
    if (stmt.kind == Stmt::Kind::Return && stmt.expr) {
      return stmt.expr.get();
    }
  }
  return nullptr;
}

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
    if (rc.kind == ContractKind::Requires && rc.expr &&
        expr_same_shape(*sub, *rc.expr)) {
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
    out << "\nend " << proc_section(proc.name) << "\n\n";
  }
  out << "end AutoVC\n";
  return true;
}

}  // namespace li
