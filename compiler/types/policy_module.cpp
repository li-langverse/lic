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

bool contract_uses_disjoint_row(const std::vector<Contract>& contracts) {
  for (const auto& c : contracts) {
    if (c.kind == ContractKind::Requires && c.expr && c.expr->kind == Expr::Kind::Call &&
        c.expr->ident == "disjoint_row") {
      return true;
    }
  }
  return false;
}

bool expr_is_int_lit(const Expr* e, std::int64_t v) {
  return e != nullptr && e->kind == Expr::Kind::IntLit && e->int_value == v;
}

bool expr_is_grid00_index(const Expr* e) {
  if (e == nullptr || e->kind != Expr::Kind::Index || !e->base || !e->index) {
    return false;
  }
  if (!expr_is_int_lit(e->index.get(), 0)) {
    return false;
  }
  if (e->base->kind == Expr::Kind::Ident) {
    return e->base->ident == "grid";
  }
  if (e->base->kind == Expr::Kind::Index) {
    return e->base->base && e->base->base->kind == Expr::Kind::Ident &&
           e->base->base->ident == "grid" && expr_is_int_lit(e->base->index.get(), 0);
  }
  return false;
}

bool par_body_writes_constant_grid00(const std::vector<Stmt>& body) {
  for (const auto& s : body) {
    if (s.kind == Stmt::Kind::Assign && s.init && expr_is_grid00_index(s.init.get())) {
      return true;
    }
  }
  return false;
}

void collect_proc_locals(const std::vector<Stmt>& stmts, std::vector<std::string>& out) {
  for (const auto& s : stmts) {
    if (s.kind == Stmt::Kind::VarDecl) {
      out.push_back(s.var_name);
    }
    collect_proc_locals(s.then_body, out);
    if (s.else_body) {
      collect_proc_locals(*s.else_body, out);
    }
    collect_proc_locals(s.while_body, out);
    collect_proc_locals(s.for_body, out);
    if (s.kind != Stmt::Kind::ParallelFor) {
      collect_proc_locals(s.par_body, out);
    }
  }
}

bool assign_targets_outer_local(const Stmt& s, const std::vector<std::string>& locals) {
  if (s.kind != Stmt::Kind::Assign || !s.init) {
    return false;
  }
  if (s.init->kind != Expr::Kind::Ident) {
    return false;
  }
  for (const auto& name : locals) {
    if (s.init->ident == name) {
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
  if (disjoint && contract_uses_disjoint_row(stmt.par_contracts) &&
      par_body_writes_constant_grid00(stmt.par_body)) {
    diag_error(diags, SourceLoc{file, 1, 1, stmt.span.start}, ErrorCode::E0350,
               "disjoint_row(i, grid) does not justify writing grid[0][0] from every iteration.",
               "Use disjoint_elem(i, ...) for the memory you actually write, or write only "
               "grid[i][...].");
  }
  for (const auto& s : stmt.par_body) {
    if (s.kind == Stmt::Kind::Borrow) {
      diag_error(diags, SourceLoc{file, 1, 1, s.span.start}, ErrorCode::E0350,
                 "borrow mut forbidden across parallel iterations",
                 "Do not borrow inside a parallel loop body; index the buffer directly with "
                 "disjoint_elem(i, buf).");
    }
  }
}

void check_stmt_parallel_capture(const Stmt& stmt, const std::vector<std::string>& outer_locals,
                                 const std::string& file, DiagnosticBag& diags) {
  if (stmt.kind != Stmt::Kind::ParallelFor) {
    return;
  }
  for (const auto& s : stmt.par_body) {
    if (assign_targets_outer_local(s, outer_locals)) {
      diag_error(diags, SourceLoc{file, 1, 1, s.span.start}, ErrorCode::E0350,
                 "parallel mutable capture requires Sync proof",
                 "Do not assign to outer `var` locals from parallel iterations unless you prove "
                 "atomic/Sync semantics.");
    }
  }
}

void walk_stmts(const std::vector<Stmt>& stmts, const std::vector<std::string>& outer_locals,
                const std::string& file, DiagnosticBag& diags) {
  for (const auto& s : stmts) {
    check_stmt_parallel(s, file, diags);
    check_stmt_parallel_capture(s, outer_locals, file, diags);
    walk_stmts(s.then_body, outer_locals, file, diags);
    if (s.else_body) {
      walk_stmts(*s.else_body, outer_locals, file, diags);
    }
    walk_stmts(s.while_body, outer_locals, file, diags);
    walk_stmts(s.for_body, outer_locals, file, diags);
    walk_stmts(s.par_body, outer_locals, file, diags);
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
    std::vector<std::string> locals;
    collect_proc_locals(proc.body, locals);
    walk_stmts(proc.body, locals, file, diags);
  }
}

}  // namespace li
