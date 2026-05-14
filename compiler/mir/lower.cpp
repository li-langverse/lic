#include "li/mir.hpp"

namespace li {

MirModule lower_to_mir(const Module& module) {
  MirModule mir;
  for (const auto& proc : module.procs) {
    MirFn fn;
    fn.name = proc.name;
    if (proc.ret_type) {
      const auto& n = proc.ret_type->name;
      fn.returns_float = (n == "float" || n == "f64" || n == "float64");
    }
    for (const auto& p : proc.params) {
      MirParam mp;
      mp.name = p.name;
      const auto& tn = p.type.name;
      mp.is_float = (tn == "float" || tn == "f64" || tn == "float64");
      fn.params.push_back(std::move(mp));
    }
    for (const auto& stmt : proc.body) {
      if (stmt.kind != Stmt::Kind::Return) {
        continue;
      }
      MirInsn ins;
      if (!stmt.expr) {
        ins.op = MirOp::ReturnVoid;
        fn.body.push_back(std::move(ins));
        continue;
      }
      const Expr& e = *stmt.expr;
      if (e.kind == Expr::Kind::IntLit) {
        ins.op = MirOp::ReturnInt;
        ins.int_value = e.int_value;
      } else if (e.kind == Expr::Kind::FloatLit) {
        ins.op = MirOp::ReturnFloat;
        ins.float_value = e.float_value;
      } else if (e.kind == Expr::Kind::Ident) {
        ins.op = MirOp::ReturnIdent;
        ins.ident = e.ident;
        ins.ret_is_float = fn.returns_float;
      } else {
        ins.op = MirOp::ReturnVoid;
      }
      fn.body.push_back(std::move(ins));
    }
    if (fn.body.empty()) {
      MirInsn ins;
      ins.op = MirOp::ReturnVoid;
      fn.body.push_back(std::move(ins));
    }
    mir.functions.push_back(std::move(fn));
  }
  return mir;
}

}  // namespace li
