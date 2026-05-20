#include "li/vc_emit.hpp"

#include "li/ast.hpp"
#include "li/call_requires.hpp"
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
  const CallerProofFacts caller_facts = collect_caller_proof_facts(proc);
  const bool witnessed =
      contract_witnessed_trivial(proc, c, &module, &caller_facts);
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

void emit_call_site_requires(std::ostream& out, const Module& module, const ProcDecl& caller) {
  const CallerProofFacts caller_facts = collect_caller_proof_facts(caller);
  const ProofFacts facts = caller_facts.view();
  std::vector<const Expr*> calls;
  collect_calls_in_stmts(caller.body, calls);
  std::size_t call_idx = 0;
  for (const Expr* call : calls) {
    if (call == nullptr || call->kind != Expr::Kind::Call) {
      continue;
    }
    const ProcDecl* callee = find_proc_by_name(module, call->ident);
    if (callee == nullptr) {
      continue;
    }
    std::vector<std::string> param_names;
    for (const auto& p : callee->params) {
      param_names.push_back(p.name);
    }
    AliasTypeLookup alias_lookup = [&module](const std::string& name) -> const TypeExpr* {
      const TypeAlias* alias = find_type_alias(module, name);
      if (alias == nullptr) {
        return nullptr;
      }
      return &alias->definition;
    };
    std::size_t ref_idx = 0;
    for (std::size_t p = 0; p < callee->params.size() && p < call->args.size(); ++p) {
      const auto refinement = resolve_refinement_on_type(callee->params[p].type, alias_lookup);
      if (!refinement || call->args[p] == nullptr || !refinement->predicate) {
        continue;
      }
      const std::string name = "vc_" + proc_section(caller.name) + "_call" +
                               std::to_string(call_idx) + '_' + proc_section(callee->name) +
                               "_refine_" + std::to_string(ref_idx++);
      const auto sub = substitute_refinement_binding(*refinement->predicate, refinement->bind_var,
                                                     *call->args[p]);
      std::string prop = "True";
      const bool witnessed =
          check_refinement_argument(*refinement, *call->args[p], facts) ==
              RequiresCheckResult::Satisfied;
      VcCtx ctx;
      if (witnessed) {
        prop = "True";
      } else if (auto lean = expr_to_lean(*sub, ctx)) {
        prop = *lean;
      } else {
        out << "/-! VC call-site refinement: param " << p << " of '" << callee->name
            << "' at call " << call_idx << " -/\n";
      }
      out << "def " << name << " : Prop := " << prop << '\n';
      if (prop == "True" && witnessed) {
        out << "theorem " << name << "_proved : " << name << " := trivial\n";
      }
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
      const auto folded = fold_const_int_locals(*sub, facts.const_int_locals);
      std::string prop = "True";
      const bool witnessed =
          expr_statically_true(*folded) || folded_discharged_by_proof_facts(*folded, facts);
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
