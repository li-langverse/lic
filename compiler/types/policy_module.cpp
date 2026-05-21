#include "li/policy.hpp"

#include "li/error_codes.hpp"

#include <string>

namespace li {
namespace {

bool expr_references_disjoint(const Expr& e) {
  switch (e.kind) {
    case Expr::Kind::Ident:
      return e.ident == "disjoint_elem" || e.ident == "disjoint_row" ||
             e.ident == "disjoint_slice";
    case Expr::Kind::Call:
      return e.ident == "disjoint_elem" || e.ident == "disjoint_row" ||
             e.ident == "disjoint_slice";
    case Expr::Kind::BinOp:
      return (e.lhs && expr_references_disjoint(*e.lhs)) ||
             (e.rhs && expr_references_disjoint(*e.rhs));
    case Expr::Kind::UnaryNot:
      return e.operand && expr_references_disjoint(*e.operand);
    case Expr::Kind::Index:
      return (e.base && expr_references_disjoint(*e.base)) ||
             (e.index && expr_references_disjoint(*e.index));
    case Expr::Kind::MethodCall:
      if (e.base && expr_references_disjoint(*e.base)) {
        return true;
      }
      for (const auto& arg : e.args) {
        if (arg && expr_references_disjoint(*arg)) {
          return true;
        }
      }
      return false;
    default:
      return false;
  }
}

bool contract_has_disjoint(const std::vector<Contract>& contracts) {
  for (const auto& c : contracts) {
    if (c.kind == ContractKind::Requires && c.expr && expr_references_disjoint(*c.expr)) {
      return true;
    }
  }
  return false;
}

bool decorator_has_disjoint_arg(const Decorator& d) {
  if (d.name != "parallel") {
    return false;
  }
  for (const auto& arg : d.args) {
    if (arg.name == "disjoint" && arg.value && expr_references_disjoint(*arg.value)) {
      return true;
    }
  }
  return false;
}

bool decorator_parallel_has_disjoint(const std::vector<Decorator>& decos) {
  for (const auto& d : decos) {
    if (decorator_has_disjoint_arg(d)) {
      return true;
    }
  }
  return false;
}

std::int64_t decorator_vectorized_lanes(const Decorator& d) {
  if (d.name != "vectorized") {
    return 0;
  }
  for (const auto& arg : d.args) {
    if (arg.name == "lanes" && arg.value && arg.value->kind == Expr::Kind::IntLit) {
      return arg.value->int_value;
    }
  }
  return 4;
}

void check_stmt_decorators(const Stmt& stmt, const std::string& file, DiagnosticBag& diags) {
  for (const auto& d : stmt.decorators) {
    if (d.name == "vectorized") {
      const std::int64_t lanes = decorator_vectorized_lanes(d);
      if (lanes != 4) {
        diag_error(diags, SourceLoc{file, 1, 1, d.span.start}, ErrorCode::E0322,
                   "`@vectorized` supports only `lanes=4` today (f64x4 codegen).",
                   "Use `@vectorized(lanes=4)` or omit `lanes` for the default.");
      }
    }
  }
}

void check_stmt_parallel(const Stmt& stmt, const std::string& file, DiagnosticBag& diags) {
  check_stmt_decorators(stmt, file, diags);
  if (stmt.kind != Stmt::Kind::ParallelFor) {
    return;
  }
  const bool disjoint = contract_has_disjoint(stmt.par_contracts) ||
                        decorator_parallel_has_disjoint(stmt.decorators);
  if (!disjoint) {
    diag_error(diags, SourceLoc{file, 1, 1, stmt.span.start}, ErrorCode::E0320,
               "A `parallel for` must prove that iterations do not touch the same memory.",
               "Add `requires disjoint_elem(...)` in the loop block, or `@parallel(disjoint=...)` "
               "on the loop.");
  }
}

void walk_stmts(const std::vector<Stmt>& stmts, const std::string& file,
                DiagnosticBag& diags) {
  for (const auto& s : stmts) {
    check_stmt_parallel(s, file, diags);
    walk_stmts(s.then_body, file, diags);
    if (s.else_body) {
      walk_stmts(*s.else_body, file, diags);
    }
    walk_stmts(s.while_body, file, diags);
    walk_stmts(s.for_body, file, diags);
    walk_stmts(s.par_body, file, diags);
  }
}

}  // namespace

void check_proc_decorators(const std::vector<Decorator>& decos, const std::string& file,
                           DiagnosticBag& diags) {
  for (const auto& d : decos) {
    if (d.name == "parallel" && !decorator_has_disjoint_arg(d)) {
      diag_error(diags, SourceLoc{file, 1, 1, d.span.start}, ErrorCode::E0321,
                 "parallel_requires_disjoint: `@parallel` must include a `disjoint=` proof "
                 "argument.",
                 "Use `@parallel(disjoint=disjoint_elem(...))`.");
    }
    if (d.name == "vectorized") {
      const std::int64_t lanes = decorator_vectorized_lanes(d);
      if (lanes != 4) {
        diag_error(diags, SourceLoc{file, 1, 1, d.span.start}, ErrorCode::E0322,
                   "`@vectorized` supports only `lanes=4` today (f64x4 codegen).",
                   "Use `@vectorized(lanes=4)` or omit `lanes` for the default.");
      }
    }
  }
}

void check_module_policies(const Module& module, const std::string& file,
                           DiagnosticBag& diags) {
  for (const auto& proc : module.procs) {
    check_proc_decorators(proc.decorators, file, diags);
    walk_stmts(proc.body, file, diags);
  }
}

}  // namespace li
