#include "li/advisory.hpp"

#include "li/error_codes.hpp"

namespace li {
namespace {

SourceLoc loc_at(const std::string& file) { return SourceLoc{file, 1, 1, 0}; }

void walk_stmts_unreachable(const std::vector<Stmt>& stmts, const std::string& file,
                          const std::string& proc_name, DiagnosticBag& diags,
                          bool& seen_return) {
  for (const auto& stmt : stmts) {
    if (seen_return) {
      diag_warning(diags, loc_at(file), WarningCode::W0402,
                   "unreachable statement after unconditional return in '" + proc_name + "'",
                   "remove dead code or guard with a condition");
      return;
    }
    if (stmt.kind == Stmt::Kind::Return) {
      seen_return = true;
      continue;
    }
    if (stmt.kind == Stmt::Kind::If) {
      walk_stmts_unreachable(stmt.then_body, file, proc_name, diags, seen_return);
      if (stmt.else_body) {
        walk_stmts_unreachable(*stmt.else_body, file, proc_name, diags, seen_return);
      }
      continue;
    }
    if (stmt.kind == Stmt::Kind::While) {
      bool inner_return = false;
      walk_stmts_unreachable(stmt.while_body, file, proc_name, diags, inner_return);
      seen_return = seen_return || inner_return;
      continue;
    }
    if (stmt.kind == Stmt::Kind::For) {
      bool inner_return = false;
      walk_stmts_unreachable(stmt.for_body, file, proc_name, diags, inner_return);
      seen_return = seen_return || inner_return;
      continue;
    }
    if (stmt.kind == Stmt::Kind::ParallelFor) {
      bool inner_return = false;
      walk_stmts_unreachable(stmt.par_body, file, proc_name, diags, inner_return);
      seen_return = seen_return || inner_return;
    }
  }
}

void check_unreachable_after_return(const Module& module, const std::string& file,
                                    DiagnosticBag& diags) {
  for (const auto& proc : module.procs) {
    bool seen_return = false;
    walk_stmts_unreachable(proc.body, file, proc.name, diags, seen_return);
  }
}

void check_ensures_mentions_result(const Module& module, const std::string& file,
                                   DiagnosticBag& diags) {
  for (const auto& proc : module.procs) {
    if (!proc.ret_type.has_value()) {
      continue;
    }
    if (proc.ret_type->kind == TypeKind::Named && proc.ret_type->name == "unit") {
      continue;
    }
    for (const auto& c : proc.contracts) {
      if (c.kind != ContractKind::Ensures || !c.expr) {
        continue;
      }
      const std::string debug = debug_expr(*c.expr);
      if (debug.find("result") == std::string::npos) {
        diag_note(diags, loc_at(file), NoteCode::N0401,
                  "ensures on '" + proc.name + "' does not mention `result`",
                  "tie the postcondition to the return value when possible");
      }
    }
  }
}

}  // namespace

void run_advisory_passes(const Module& module, const std::string& file_path,
                         const AdvisoryOptions& options, DiagnosticBag& diags) {
  (void)options;
  check_unreachable_after_return(module, file_path, diags);
  check_ensures_mentions_result(module, file_path, diags);
}

}  // namespace li
