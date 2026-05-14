#include "li/mir.hpp"

#include <algorithm>

namespace li {

namespace {

bool is_float_type_name(const std::string& n) {
  return n == "float" || n == "f64" || n == "float64";
}

bool is_string_type_name(const std::string& n) {
  return n == "str" || n == "string";
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

void lower_call(const Expr& call, const Module& module, std::vector<MirInsn>& out) {
  const auto it = std::find_if(module.procs.begin(), module.procs.end(),
                               [&](const ProcDecl& p) { return p.name == call.ident; });
  if (it == module.procs.end() || !it->is_extern) {
    return;
  }
  MirInsn ins;
  ins.op = MirOp::CallExtern;
  ins.callee = call.ident;
  if (!call.args.empty()) {
    const Expr& arg = *call.args[0];
    if (arg.kind == Expr::Kind::StringLit) {
      ins.str_value = arg.str_value;
    } else if (arg.kind == Expr::Kind::IntLit) {
      ins.rhs_is_literal = true;
      ins.rhs_int = arg.int_value;
    } else if (arg.kind == Expr::Kind::Ident) {
      ins.ident = arg.ident;
    }
  }
  out.push_back(std::move(ins));
}

void lower_return_expr(const Expr& e, bool returns_float, std::vector<MirInsn>& out) {
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
  } else if (e.kind == Expr::Kind::Index && e.base && e.base->kind == Expr::Kind::Ident &&
             e.index) {
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
    out.push_back(std::move(load));
    ins.op = MirOp::ReturnInt;
    ins.use_loaded_int = true;
  } else {
    ins.op = MirOp::ReturnVoid;
  }
  out.push_back(std::move(ins));
}

void lower_stmt(const Stmt& stmt, const Module& module, bool returns_float,
                std::vector<MirInsn>& out) {
  switch (stmt.kind) {
    case Stmt::Kind::Return:
      if (!stmt.expr) {
        MirInsn ins;
        ins.op = MirOp::ReturnVoid;
        out.push_back(std::move(ins));
      } else {
        lower_return_expr(*stmt.expr, returns_float, out);
      }
      break;
    case Stmt::Kind::VarDecl:
      if (stmt.var_type.kind == TypeKind::Array && stmt.var_type.elem) {
        MirInsn ins;
        ins.op = MirOp::ArrayAlloc;
        ins.ident = stmt.var_name;
        ins.int_value = stmt.var_type.array_size;
        out.push_back(std::move(ins));
      }
      break;
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
        }
        out.push_back(std::move(ins));
      }
      break;
    case Stmt::Kind::Expr:
      if (stmt.expr && stmt.expr->kind == Expr::Kind::Call) {
        if (stmt.expr->ident == "echo" && !stmt.expr->args.empty()) {
          lower_echo_arg(*stmt.expr->args[0], out);
        } else {
          lower_call(*stmt.expr, module, out);
        }
      }
      break;
    default:
      break;
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
  MirModule mir;
  for (const auto& proc : module.procs) {
    MirFn fn;
    fn.name = proc.name;
    fn.is_extern = proc.is_extern;
    if (proc.ret_type) {
      fn.returns_float = is_float_type_name(proc.ret_type->name);
    }
    for (const auto& p : proc.params) {
      MirParam mp;
      mp.name = p.name;
      mp.is_float = is_float_type_name(p.type.name);
      mp.is_string = is_string_type_name(p.type.name);
      fn.params.push_back(std::move(mp));
    }
    if (!proc.is_extern) {
      for (const auto& stmt : proc.body) {
        lower_stmt(stmt, module, fn.returns_float, fn.body);
      }
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
