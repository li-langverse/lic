#include "li/mir.hpp"

#include <algorithm>

namespace li {

namespace {

int temp_counter = 0;

std::string fresh_temp() { return "__t" + std::to_string(temp_counter++); }
std::string fresh_label(const std::string& prefix) {
  return prefix + std::to_string(temp_counter++);
}

bool is_float_type_name(const std::string& n) {
  return n == "float" || n == "f64" || n == "float64";
}

bool is_string_type_name(const std::string& n) {
  return n == "str" || n == "string";
}

bool is_i64_type_name(const std::string& n) {
  return n == "ptr" || n == "int64" || n == "i64" || n == "long";
}

bool is_int_type_name(const std::string& n) {
  return n == "int" || n == "bool" || n == "unit";
}

void push_label(std::vector<MirInsn>& out, const std::string& name) {
  MirInsn ins;
  ins.op = MirOp::Label;
  ins.label = name;
  out.push_back(std::move(ins));
}

void push_jump(std::vector<MirInsn>& out, const std::string& name) {
  MirInsn ins;
  ins.op = MirOp::Jump;
  ins.label = name;
  out.push_back(std::move(ins));
}

void push_branch_if_zero(std::vector<MirInsn>& out, const std::string& ident,
                         const std::string& label) {
  MirInsn ins;
  ins.op = MirOp::BranchIfZero;
  ins.ident = ident;
  ins.label = label;
  out.push_back(std::move(ins));
}

std::string lower_expr_to(const Expr& e, const Module& module, std::vector<MirInsn>& out) {
  switch (e.kind) {
    case Expr::Kind::IntLit: {
      const std::string dest = fresh_temp();
      MirInsn ins;
      ins.op = MirOp::StoreInt;
      ins.ident = dest;
      ins.rhs_is_literal = true;
      ins.rhs_int = e.int_value;
      out.push_back(std::move(ins));
      return dest;
    }
    case Expr::Kind::Ident:
      return e.ident;
    case Expr::Kind::BinOp: {
      const std::string lhs = lower_expr_to(*e.lhs, module, out);
      const std::string rhs = lower_expr_to(*e.rhs, module, out);
      const std::string dest = fresh_temp();
      MirInsn ins;
      ins.op = MirOp::BinOpInt;
      ins.ident = dest;
      ins.lhs_ident = lhs;
      ins.rhs_ident = rhs;
      ins.bin_op = e.bin_op;
      out.push_back(std::move(ins));
      return dest;
    }
    case Expr::Kind::Call: {
      const auto it = std::find_if(module.procs.begin(), module.procs.end(),
                                   [&](const ProcDecl& p) { return p.name == e.ident; });
      if (it != module.procs.end() && !it->is_extern) {
        MirInsn ins;
        ins.op = MirOp::CallProc;
        ins.callee = e.ident;
        for (const auto& arg : e.args) {
          MirArg ma;
          if (arg->kind == Expr::Kind::IntLit) {
            ma.is_literal = true;
            ma.int_value = arg->int_value;
          } else if (arg->kind == Expr::Kind::Ident) {
            ma.ident = arg->ident;
          }
          ins.args.push_back(std::move(ma));
        }
        const std::string dest = fresh_temp();
        ins.ident = dest;
        out.push_back(std::move(ins));
        return dest;
      }
      MirInsn ins;
      ins.op = MirOp::CallExtern;
      ins.callee = e.ident;
      for (const auto& arg : e.args) {
        MirArg ma;
        if (arg->kind == Expr::Kind::StringLit) {
          ma.is_string = true;
          ma.str_value = arg->str_value;
        } else if (arg->kind == Expr::Kind::IntLit) {
          ma.is_literal = true;
          ma.int_value = arg->int_value;
        } else if (arg->kind == Expr::Kind::Ident) {
          ma.ident = arg->ident;
        }
        ins.args.push_back(std::move(ma));
      }
      if (it != module.procs.end() && it->is_extern && it->ret_type &&
          it->ret_type->name != "unit") {
        const std::string dest = fresh_temp();
        ins.ident = dest;
        if (it->ret_type->name == "ptr" || it->ret_type->name == "int64" ||
            it->ret_type->name == "i64") {
          ins.is_i64 = true;
        }
        out.push_back(std::move(ins));
        return dest;
      }
      out.push_back(std::move(ins));
      return fresh_temp();
    }
    case Expr::Kind::Index: {
      if (e.base && e.base->kind == Expr::Kind::Ident && e.index) {
        MirInsn load;
        load.op = MirOp::ArrayLoadInt;
        load.ident = e.base->ident;
        if (e.index->kind == Expr::Kind::IntLit) {
          load.index_is_literal = true;
          load.int_value = e.index->int_value;
        } else if (e.index->kind == Expr::Kind::Ident) {
          load.index_is_literal = false;
          load.index_ident = e.index->ident;
        }
        const std::string dest = fresh_temp();
        load.lhs_ident = dest;
        out.push_back(std::move(load));
        return dest;
      }
      return fresh_temp();
    }
    default:
      return fresh_temp();
  }
}

void lower_echo_arg(const Expr& arg, std::vector<MirInsn>& out) {
  MirInsn ins;
  if (arg.kind == Expr::Kind::IntLit) {
    ins.op = MirOp::EchoInt;
    ins.int_value = arg.int_value;
  } else if (arg.kind == Expr::Kind::Ident) {
    ins.op = MirOp::EchoInt;
    ins.ident = arg.ident;
  } else if (arg.kind == Expr::Kind::StringLit) {
    ins.op = MirOp::EchoString;
    ins.str_value = arg.str_value;
  }
  out.push_back(std::move(ins));
}

void lower_return_expr(const Expr& e, bool returns_float, const Module& module,
                       std::vector<MirInsn>& out) {
  MirInsn ins;
  if (e.kind == Expr::Kind::IntLit) {
    ins.op = MirOp::ReturnInt;
    ins.int_value = e.int_value;
  } else if (e.kind == Expr::Kind::FloatLit) {
    ins.op = MirOp::ReturnFloat;
    ins.float_value = e.float_value;
  } else if (e.kind == Expr::Kind::Ident) {
    ins.op = MirOp::ReturnIdent;
    ins.ident = e.ident;
    ins.ret_is_float = returns_float;
  } else if (e.kind == Expr::Kind::Call || e.kind == Expr::Kind::BinOp ||
             e.kind == Expr::Kind::Index) {
    const std::string tmp = lower_expr_to(e, module, out);
    ins.op = MirOp::ReturnIdent;
    ins.ident = tmp;
  } else {
    ins.op = MirOp::ReturnVoid;
  }
  out.push_back(std::move(ins));
}

void lower_stmts(const std::vector<Stmt>& stmts, const Module& module, bool returns_float,
                 std::vector<MirInsn>& out);

void lower_stmt(const Stmt& stmt, const Module& module, bool returns_float,
                std::vector<MirInsn>& out) {
  switch (stmt.kind) {
    case Stmt::Kind::Return:
      if (!stmt.expr) {
        MirInsn ins;
        ins.op = MirOp::ReturnVoid;
        out.push_back(std::move(ins));
      } else {
        lower_return_expr(*stmt.expr, returns_float, module, out);
      }
      break;
    case Stmt::Kind::VarDecl: {
      if (stmt.var_type.kind == TypeKind::Array && stmt.var_type.elem) {
        MirInsn ins;
        ins.op = MirOp::ArrayAlloc;
        ins.ident = stmt.var_name;
        ins.int_value = stmt.var_type.array_size;
        out.push_back(std::move(ins));
      } else if (is_i64_type_name(stmt.var_type.name)) {
        MirInsn ins;
        ins.op = MirOp::LocalAllocI64;
        ins.ident = stmt.var_name;
        out.push_back(std::move(ins));
        if (stmt.init) {
          MirInsn store;
          store.op = MirOp::StoreI64;
          store.ident = stmt.var_name;
          if (stmt.init->kind == Expr::Kind::IntLit) {
            store.rhs_is_literal = true;
            store.rhs_int = stmt.init->int_value;
          } else if (stmt.init->kind == Expr::Kind::Ident) {
            store.rhs_ident = stmt.init->ident;
          } else {
            const std::string tmp = lower_expr_to(*stmt.init, module, out);
            store.rhs_ident = tmp;
          }
          out.push_back(std::move(store));
        }
      } else {
        MirInsn ins;
        ins.op = MirOp::LocalAllocInt;
        ins.ident = stmt.var_name;
        out.push_back(std::move(ins));
        if (stmt.init) {
          MirInsn store;
          store.op = MirOp::StoreInt;
          store.ident = stmt.var_name;
          if (stmt.init->kind == Expr::Kind::IntLit) {
            store.rhs_is_literal = true;
            store.rhs_int = stmt.init->int_value;
          } else if (stmt.init->kind == Expr::Kind::Ident) {
            store.rhs_ident = stmt.init->ident;
          } else {
            const std::string tmp = lower_expr_to(*stmt.init, module, out);
            store.rhs_ident = tmp;
          }
          out.push_back(std::move(store));
        }
      }
      break;
    }
    case Stmt::Kind::Assign:
      if (stmt.init && stmt.init->kind == Expr::Kind::Index && stmt.init->base &&
          stmt.init->base->kind == Expr::Kind::Ident && stmt.expr) {
        MirInsn ins;
        ins.op = MirOp::ArrayStoreInt;
        ins.ident = stmt.init->base->ident;
        if (stmt.init->index && stmt.init->index->kind == Expr::Kind::IntLit) {
          ins.index_is_literal = true;
          ins.int_value = stmt.init->index->int_value;
        } else if (stmt.init->index && stmt.init->index->kind == Expr::Kind::Ident) {
          ins.index_is_literal = false;
          ins.index_ident = stmt.init->index->ident;
        }
        if (stmt.expr->kind == Expr::Kind::IntLit) {
          ins.rhs_is_literal = true;
          ins.rhs_int = stmt.expr->int_value;
        } else if (stmt.expr->kind == Expr::Kind::Ident) {
          ins.rhs_is_literal = false;
          ins.rhs_ident = stmt.expr->ident;
        } else {
          ins.rhs_ident = lower_expr_to(*stmt.expr, module, out);
          ins.rhs_is_literal = false;
        }
        out.push_back(std::move(ins));
      } else if (stmt.init && stmt.init->kind == Expr::Kind::Ident && stmt.expr) {
        MirInsn ins;
        ins.op = MirOp::StoreInt;
        ins.ident = stmt.init->ident;
        if (stmt.expr->kind == Expr::Kind::IntLit) {
          ins.rhs_is_literal = true;
          ins.rhs_int = stmt.expr->int_value;
        } else if (stmt.expr->kind == Expr::Kind::Ident) {
          ins.rhs_ident = stmt.expr->ident;
        } else {
          ins.rhs_ident = lower_expr_to(*stmt.expr, module, out);
        }
        out.push_back(std::move(ins));
      }
      break;
    case Stmt::Kind::If: {
      if (!stmt.cond) {
        break;
      }
      const std::string cond_tmp = lower_expr_to(*stmt.cond, module, out);
      const std::string else_label = fresh_label("else_");
      const std::string merge_label = fresh_label("merge_");
      push_branch_if_zero(out, cond_tmp, else_label);
      lower_stmts(stmt.then_body, module, returns_float, out);
      if (stmt.else_body) {
        push_jump(out, merge_label);
        push_label(out, else_label);
        lower_stmts(*stmt.else_body, module, returns_float, out);
        push_label(out, merge_label);
      } else {
        push_label(out, else_label);
      }
      break;
    }
    case Stmt::Kind::While: {
      if (!stmt.cond) {
        break;
      }
      const std::string head_label = fresh_label("while_head_");
      const std::string exit_label = fresh_label("while_exit_");
      push_label(out, head_label);
      const std::string cond_tmp = lower_expr_to(*stmt.cond, module, out);
      push_branch_if_zero(out, cond_tmp, exit_label);
      lower_stmts(stmt.while_body, module, returns_float, out);
      push_jump(out, head_label);
      push_label(out, exit_label);
      break;
    }
    case Stmt::Kind::Expr:
      if (stmt.expr && stmt.expr->kind == Expr::Kind::Call) {
        if (stmt.expr->ident == "echo" && !stmt.expr->args.empty()) {
          lower_echo_arg(*stmt.expr->args[0], out);
        } else {
          (void)lower_expr_to(*stmt.expr, module, out);
        }
      }
      break;
    default:
      break;
  }
}

void lower_stmts(const std::vector<Stmt>& stmts, const Module& module, bool returns_float,
                 std::vector<MirInsn>& out) {
  for (const auto& stmt : stmts) {
    lower_stmt(stmt, module, returns_float, out);
    if (!out.empty() && (out.back().op == MirOp::ReturnVoid || out.back().op == MirOp::ReturnInt ||
                         out.back().op == MirOp::ReturnFloat || out.back().op == MirOp::ReturnIdent)) {
      return;
    }
  }
}

bool insn_terminates(MirOp op) {
  return op == MirOp::ReturnVoid || op == MirOp::ReturnInt || op == MirOp::ReturnFloat ||
         op == MirOp::ReturnIdent;
}

void append_implicit_return(std::vector<MirInsn>& body) {
  if (body.empty() || !insn_terminates(body.back().op)) {
    MirInsn ins;
    ins.op = MirOp::ReturnVoid;
    body.push_back(std::move(ins));
  }
}

}  // namespace

MirModule lower_to_mir(const Module& module) {
  temp_counter = 0;
  MirModule mir;
  for (const auto& proc : module.procs) {
    MirFn fn;
    fn.name = proc.name;
    fn.is_extern = proc.is_extern;
    if (proc.ret_type) {
      fn.returns_float = is_float_type_name(proc.ret_type->name);
      fn.returns_void = proc.ret_type->name == "unit";
    } else if (proc.is_extern) {
      fn.returns_void = true;
    }
    for (const auto& p : proc.params) {
      MirParam mp;
      mp.name = p.name;
      mp.is_float = is_float_type_name(p.type.name);
      mp.is_string = is_string_type_name(p.type.name);
      mp.is_i64 = is_i64_type_name(p.type.name);
      fn.params.push_back(std::move(mp));
    }
    if (!proc.is_extern) {
      lower_stmts(proc.body, module, fn.returns_float, fn.body);
      append_implicit_return(fn.body);
    }
    if (!proc.is_extern && fn.body.empty()) {
      MirInsn ins;
      ins.op = MirOp::ReturnVoid;
      fn.body.push_back(std::move(ins));
    }
    mir.functions.push_back(std::move(fn));
  }
  return mir;
}

}  // namespace li
