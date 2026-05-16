#include "li/mir.hpp"

#include <algorithm>
#include <unordered_map>
#include <unordered_set>

namespace li {

namespace {

int temp_counter = 0;
int par_counter = 0;

struct LowerArrayCtx {
  std::unordered_map<std::string, std::int64_t> float_array_sizes;
  std::unordered_map<std::string, std::int64_t> int_array_sizes;
  const std::unordered_set<std::string>* float_array_names = nullptr;
};

LowerArrayCtx* g_arr_ctx = nullptr;

std::string fresh_temp() { return "__t" + std::to_string(temp_counter++); }

void copy_decorators(const std::vector<Decorator>& src, std::vector<MirDecorator>& dst) {
  for (const auto& d : src) {
    MirDecorator md;
    md.name = d.name;
    dst.push_back(std::move(md));
  }
}

bool is_float_type_name(const std::string& n) {
  return n == "float" || n == "f64" || n == "float64";
}

bool is_simd_type(const TypeExpr& t) {
  return t.kind == TypeKind::TypeApp && t.name == "simd";
}

bool is_float_array_type(const TypeExpr& t) {
  return t.kind == TypeKind::Array && t.elem && is_float_type_name(t.elem->name);
}

std::int64_t simd_lanes_from_type(const TypeExpr& t) {
  if (t.array_size > 0) {
    return t.array_size;
  }
  return 4;
}

struct LowerCtx {
  const Module* module = nullptr;
  MirModule* mir = nullptr;
  std::string proc_name;
};
std::string fresh_label(const std::string& prefix) {
  return prefix + std::to_string(temp_counter++);
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

bool is_arith_binop(BinOp op) {
  return op == BinOp::Add || op == BinOp::Sub || op == BinOp::Mul || op == BinOp::Div ||
         op == BinOp::Mod || op == BinOp::FloorDiv || op == BinOp::Pow;
}

bool is_float_expr(const Expr& e, const std::unordered_set<std::string>& float_names) {
  switch (e.kind) {
    case Expr::Kind::FloatLit:
      return true;
    case Expr::Kind::Ident:
      return float_names.count(e.ident) > 0;
    case Expr::Kind::BinOp:
      if (!is_arith_binop(e.bin_op)) {
        return false;
      }
      return is_float_expr(*e.lhs, float_names) || is_float_expr(*e.rhs, float_names);
    default:
      return false;
  }
}

const ProcDecl* find_proc(const Module& module, const std::string& name) {
  const auto it = std::find_if(module.procs.begin(), module.procs.end(),
                               [&](const ProcDecl& p) { return p.name == name; });
  return it != module.procs.end() ? &*it : nullptr;
}

void seed_float_params(const MirFn& fn, std::unordered_set<std::string>& float_names) {
  for (const auto& p : fn.params) {
    if (p.is_float) {
      float_names.insert(p.name);
    }
  }
}

std::string lower_expr_to(const Expr& e, const Module& module, std::vector<MirInsn>& out,
                          std::unordered_set<std::string>& float_names,
                          std::unordered_set<std::string>& simd_names) {
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
    case Expr::Kind::FloatLit: {
      const std::string dest = fresh_temp();
      MirInsn ins;
      ins.op = MirOp::StoreFloat;
      ins.ident = dest;
      ins.rhs_is_literal = true;
      ins.float_value = e.float_value;
      out.push_back(std::move(ins));
      float_names.insert(dest);
      return dest;
    }
    case Expr::Kind::Ident:
      return e.ident;
    case Expr::Kind::BinOp: {
      if (e.bin_op == BinOp::MatMul && e.lhs && e.lhs->kind == Expr::Kind::Ident && e.rhs &&
          e.rhs->kind == Expr::Kind::Ident && g_arr_ctx &&
          g_arr_ctx->float_array_names) {
        const auto& names = *g_arr_ctx->float_array_names;
        const auto sz_a = g_arr_ctx->float_array_sizes.find(e.lhs->ident);
        const auto sz_b = g_arr_ctx->float_array_sizes.find(e.rhs->ident);
        if (names.count(e.lhs->ident) > 0 && names.count(e.rhs->ident) > 0 &&
            sz_a != g_arr_ctx->float_array_sizes.end() &&
            sz_b != g_arr_ctx->float_array_sizes.end() && sz_a->second == sz_b->second) {
          const std::string dest = fresh_temp();
          MirInsn dot;
          dot.op = MirOp::ArrayDotF64;
          dot.ident = dest;
          dot.lhs_ident = e.lhs->ident;
          dot.rhs_ident = e.rhs->ident;
          dot.int_value = sz_a->second;
          out.push_back(std::move(dot));
          float_names.insert(dest);
          return dest;
        }
      }
      const std::string lhs = lower_expr_to(*e.lhs, module, out, float_names, simd_names);
      const std::string rhs = lower_expr_to(*e.rhs, module, out, float_names, simd_names);
      const std::string dest = fresh_temp();
      MirInsn ins;
      const bool flt = is_float_expr(e, float_names);
      ins.op = flt ? MirOp::BinOpFloat : MirOp::BinOpInt;
      ins.ident = dest;
      ins.lhs_ident = lhs;
      ins.rhs_ident = rhs;
      ins.bin_op = e.bin_op;
      out.push_back(std::move(ins));
      if (flt) {
        float_names.insert(dest);
      }
      return dest;
    }
    case Expr::Kind::Call: {
      if (e.ident == "__li_simd_splat_f64" && e.args.size() == 1) {
        const std::string dest = fresh_temp();
        const std::string scalar = lower_expr_to(*e.args[0], module, out, float_names, simd_names);
        MirInsn ins;
        ins.op = MirOp::SimdSplatF64;
        ins.ident = dest;
        ins.rhs_ident = scalar;
        ins.simd_lanes = 4;
        out.push_back(std::move(ins));
        simd_names.insert(dest);
        return dest;
      }
      if (e.ident == "__li_simd_mul_f64" && e.args.size() == 2) {
        const std::string dest = fresh_temp();
        const std::string lhs = lower_expr_to(*e.args[0], module, out, float_names, simd_names);
        const std::string rhs = lower_expr_to(*e.args[1], module, out, float_names, simd_names);
        MirInsn ins;
        ins.op = MirOp::SimdMulF64;
        ins.ident = dest;
        ins.lhs_ident = lhs;
        ins.rhs_ident = rhs;
        ins.simd_lanes = 4;
        out.push_back(std::move(ins));
        simd_names.insert(dest);
        return dest;
      }
      if (e.ident == "__li_simd_add_f64" && e.args.size() == 2) {
        const std::string dest = fresh_temp();
        const std::string lhs = lower_expr_to(*e.args[0], module, out, float_names, simd_names);
        const std::string rhs = lower_expr_to(*e.args[1], module, out, float_names, simd_names);
        MirInsn ins;
        ins.op = MirOp::SimdAddF64;
        ins.ident = dest;
        ins.lhs_ident = lhs;
        ins.rhs_ident = rhs;
        ins.simd_lanes = 4;
        out.push_back(std::move(ins));
        simd_names.insert(dest);
        return dest;
      }
      if (e.ident == "sum" && e.args.size() == 1 && e.args[0]->kind == Expr::Kind::Ident &&
          g_arr_ctx) {
        const std::string arr = e.args[0]->ident;
        const std::string dest = fresh_temp();
        if (g_arr_ctx->float_array_names &&
            g_arr_ctx->float_array_names->count(arr) > 0) {
          const auto sz = g_arr_ctx->float_array_sizes.find(arr);
          if (sz != g_arr_ctx->float_array_sizes.end()) {
            MirInsn ins;
            ins.op = MirOp::ArraySumF64;
            ins.ident = dest;
            ins.lhs_ident = arr;
            ins.int_value = sz->second;
            out.push_back(std::move(ins));
            float_names.insert(dest);
            return dest;
          }
        }
        {
          const auto sz = g_arr_ctx->int_array_sizes.find(arr);
          if (sz != g_arr_ctx->int_array_sizes.end()) {
            MirInsn ins;
            ins.op = MirOp::ArraySumI64;
            ins.ident = dest;
            ins.lhs_ident = arr;
            ins.int_value = sz->second;
            out.push_back(std::move(ins));
            return dest;
          }
        }
      }
      if (e.ident == "__li_horiz_sum_f64" && e.args.size() == 1) {
        const std::string dest = fresh_temp();
        const std::string vec = lower_expr_to(*e.args[0], module, out, float_names, simd_names);
        MirInsn ins;
        ins.op = MirOp::SimdHorizSumF64;
        ins.ident = dest;
        ins.lhs_ident = vec;
        ins.simd_lanes = 4;
        out.push_back(std::move(ins));
        float_names.insert(dest);
        return dest;
      }
      const ProcDecl* callee = find_proc(module, e.ident);
      if (callee && !callee->is_extern) {
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
        if (callee->ret_type && is_float_type_name(callee->ret_type->name)) {
          ins.ret_is_float = true;
          float_names.insert(dest);
        }
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
        } else {
          ma.ident = lower_expr_to(*arg, module, out, float_names, simd_names);
        }
        ins.args.push_back(std::move(ma));
      }
      if (callee && callee->is_extern && callee->ret_type &&
          callee->ret_type->name != "unit") {
        const std::string dest = fresh_temp();
        ins.ident = dest;
        if (callee->ret_type->name == "ptr" || callee->ret_type->name == "int64" ||
            callee->ret_type->name == "i64") {
          ins.is_i64 = true;
        } else if (is_float_type_name(callee->ret_type->name)) {
          ins.ret_is_float = true;
          float_names.insert(dest);
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
                       std::vector<MirInsn>& out, std::unordered_set<std::string>& float_names,
                       std::unordered_set<std::string>& simd_names) {
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
    ins.ret_is_float = returns_float || float_names.count(e.ident) > 0;
  } else if (e.kind == Expr::Kind::Call || e.kind == Expr::Kind::BinOp ||
             e.kind == Expr::Kind::Index) {
    const std::string tmp = lower_expr_to(e, module, out, float_names, simd_names);
    ins.op = MirOp::ReturnIdent;
    ins.ident = tmp;
    ins.ret_is_float = returns_float || is_float_expr(e, float_names);
  } else {
    ins.op = MirOp::ReturnVoid;
  }
  out.push_back(std::move(ins));
}

void append_implicit_return(std::vector<MirInsn>& body);

void lower_stmts(const std::vector<Stmt>& stmts, LowerCtx& ctx, bool returns_float,
                 std::vector<MirInsn>& out, std::unordered_set<std::string>& float_names,
                 std::unordered_set<std::string>& simd_names,
                 std::unordered_set<std::string>& float_array_names);

void lower_stmt(const Stmt& stmt, LowerCtx& ctx, bool returns_float, std::vector<MirInsn>& out,
                std::unordered_set<std::string>& float_names,
                std::unordered_set<std::string>& simd_names,
                std::unordered_set<std::string>& float_array_names) {
  const Module& module = *ctx.module;
  switch (stmt.kind) {
    case Stmt::Kind::Return:
      if (!stmt.expr) {
        MirInsn ins;
        ins.op = MirOp::ReturnVoid;
        out.push_back(std::move(ins));
      } else {
        lower_return_expr(*stmt.expr, returns_float, module, out, float_names, simd_names);
      }
      break;
    case Stmt::Kind::VarDecl: {
      if (is_simd_type(stmt.var_type)) {
        MirInsn ins;
        ins.op = MirOp::LocalAllocSimdF64;
        ins.ident = stmt.var_name;
        ins.simd_lanes = simd_lanes_from_type(stmt.var_type);
        out.push_back(std::move(ins));
        simd_names.insert(stmt.var_name);
      } else if (stmt.var_type.kind == TypeKind::Array && stmt.var_type.elem) {
        MirInsn ins;
        ins.op = MirOp::ArrayAlloc;
        ins.ident = stmt.var_name;
        ins.int_value = stmt.var_type.array_size;
        ins.array_is_float = is_float_array_type(stmt.var_type);
        out.push_back(std::move(ins));
        if (ins.array_is_float) {
          float_array_names.insert(stmt.var_name);
          if (g_arr_ctx) {
            g_arr_ctx->float_array_sizes[stmt.var_name] = stmt.var_type.array_size;
          }
        } else if (stmt.var_type.elem && stmt.var_type.elem->kind == TypeKind::Named &&
                   stmt.var_type.elem->name == "int" && g_arr_ctx) {
          g_arr_ctx->int_array_sizes[stmt.var_name] = stmt.var_type.array_size;
        }
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
            store.rhs_is_literal = false;
            store.rhs_ident = stmt.init->ident;
          } else {
            const std::string tmp =
                lower_expr_to(*stmt.init, module, out, float_names, simd_names);
            store.rhs_is_literal = false;
            store.rhs_ident = tmp;
          }
          out.push_back(std::move(store));
        }
      } else if (is_float_type_name(stmt.var_type.name)) {
        MirInsn ins;
        ins.op = MirOp::LocalAllocFloat;
        ins.ident = stmt.var_name;
        out.push_back(std::move(ins));
        float_names.insert(stmt.var_name);
        if (stmt.init) {
          MirInsn store;
          store.op = MirOp::StoreFloat;
          store.ident = stmt.var_name;
          if (stmt.init->kind == Expr::Kind::FloatLit) {
            store.rhs_is_literal = true;
            store.float_value = stmt.init->float_value;
          } else if (stmt.init->kind == Expr::Kind::Ident) {
            store.rhs_is_literal = false;
            store.rhs_ident = stmt.init->ident;
          } else {
            const std::string tmp =
                lower_expr_to(*stmt.init, module, out, float_names, simd_names);
            store.rhs_is_literal = false;
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
            store.rhs_is_literal = false;
            store.rhs_ident = stmt.init->ident;
          } else {
            const std::string tmp =
                lower_expr_to(*stmt.init, module, out, float_names, simd_names);
            store.rhs_is_literal = false;
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
        const bool fa = float_array_names.count(stmt.init->base->ident) > 0;
        MirInsn ins;
        ins.op = fa ? MirOp::ArrayStoreFloat : MirOp::ArrayStoreInt;
        ins.ident = stmt.init->base->ident;
        if (stmt.init->index && stmt.init->index->kind == Expr::Kind::IntLit) {
          ins.index_is_literal = true;
          ins.int_value = stmt.init->index->int_value;
        } else if (stmt.init->index && stmt.init->index->kind == Expr::Kind::Ident) {
          ins.index_is_literal = false;
          ins.index_ident = stmt.init->index->ident;
        }
        if (fa && stmt.expr->kind == Expr::Kind::FloatLit) {
          ins.rhs_is_literal = true;
          ins.float_value = stmt.expr->float_value;
        } else if (!fa && stmt.expr->kind == Expr::Kind::IntLit) {
          ins.rhs_is_literal = true;
          ins.rhs_int = stmt.expr->int_value;
        } else if (stmt.expr->kind == Expr::Kind::Ident) {
          ins.rhs_is_literal = false;
          ins.rhs_ident = stmt.expr->ident;
        } else {
          ins.rhs_ident = lower_expr_to(*stmt.expr, module, out, float_names, simd_names);
          ins.rhs_is_literal = false;
        }
        out.push_back(std::move(ins));
      } else if (stmt.init && stmt.init->kind == Expr::Kind::Ident && stmt.expr) {
        if (simd_names.count(stmt.init->ident) > 0) {
          const std::string tmp =
              lower_expr_to(*stmt.expr, module, out, float_names, simd_names);
          MirInsn ins;
          ins.op = MirOp::SimdCopyF64;
          ins.ident = stmt.init->ident;
          ins.rhs_ident = tmp;
          ins.simd_lanes = 4;
          out.push_back(std::move(ins));
          break;
        }
        const bool flt = float_names.count(stmt.init->ident) > 0;
        MirInsn ins;
        ins.op = flt ? MirOp::StoreFloat : MirOp::StoreInt;
        ins.ident = stmt.init->ident;
        if (stmt.expr->kind == Expr::Kind::IntLit && !flt) {
          ins.rhs_is_literal = true;
          ins.rhs_int = stmt.expr->int_value;
        } else if (stmt.expr->kind == Expr::Kind::FloatLit && flt) {
          ins.rhs_is_literal = true;
          ins.float_value = stmt.expr->float_value;
        } else if (stmt.expr->kind == Expr::Kind::Ident) {
          ins.rhs_is_literal = false;
          ins.rhs_ident = stmt.expr->ident;
        } else {
          ins.rhs_ident = lower_expr_to(*stmt.expr, module, out, float_names, simd_names);
          ins.rhs_is_literal = false;
        }
        out.push_back(std::move(ins));
      }
      break;
    case Stmt::Kind::ParallelFor: {
      if (!ctx.mir) {
        break;
      }
      const std::string par_name =
          "__li_par_" + ctx.proc_name + "_" + std::to_string(par_counter++);
      MirFn par_fn;
      par_fn.name = par_name;
      copy_decorators(stmt.decorators, par_fn.decorators);
      MirParam ip;
      ip.name = stmt.par_iter;
      ip.is_i64 = true;
      par_fn.params.push_back(ip);
      std::unordered_set<std::string> par_floats;
      std::unordered_set<std::string> par_simd;
      std::unordered_set<std::string> par_float_arrays;
      LowerCtx par_ctx{ctx.module, ctx.mir, par_name};
      lower_stmts(stmt.par_body, par_ctx, false, par_fn.body, par_floats, par_simd,
                  par_float_arrays);
      append_implicit_return(par_fn.body);
      ctx.mir->functions.push_back(std::move(par_fn));
      MirInsn call;
      call.op = MirOp::OmpParallelFor;
      call.callee = par_name;
      call.int_value = stmt.par_start;
      call.rhs_int = stmt.par_end;
      out.push_back(std::move(call));
      ctx.mir->uses_openmp = true;
      break;
    }
    case Stmt::Kind::If: {
      if (!stmt.cond) {
        break;
      }
      const std::string cond_tmp =
          lower_expr_to(*stmt.cond, module, out, float_names, simd_names);
      const std::string else_label = fresh_label("else_");
      const std::string merge_label = fresh_label("merge_");
      push_branch_if_zero(out, cond_tmp, else_label);
      lower_stmts(stmt.then_body, ctx, returns_float, out, float_names, simd_names,
                  float_array_names);
      if (stmt.else_body) {
        push_jump(out, merge_label);
        push_label(out, else_label);
        lower_stmts(*stmt.else_body, ctx, returns_float, out, float_names, simd_names,
                    float_array_names);
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
      const std::string cond_tmp =
          lower_expr_to(*stmt.cond, module, out, float_names, simd_names);
      push_branch_if_zero(out, cond_tmp, exit_label);
      lower_stmts(stmt.while_body, ctx, returns_float, out, float_names, simd_names,
                  float_array_names);
      push_jump(out, head_label);
      push_label(out, exit_label);
      break;
    }
    case Stmt::Kind::Expr:
      if (stmt.expr && stmt.expr->kind == Expr::Kind::Call) {
        if (stmt.expr->ident == "echo" && !stmt.expr->args.empty()) {
          lower_echo_arg(*stmt.expr->args[0], out);
        } else {
          (void)lower_expr_to(*stmt.expr, module, out, float_names, simd_names);
        }
      }
      break;
    default:
      break;
  }
}

void lower_stmts(const std::vector<Stmt>& stmts, LowerCtx& ctx, bool returns_float,
                 std::vector<MirInsn>& out, std::unordered_set<std::string>& float_names,
                 std::unordered_set<std::string>& simd_names,
                 std::unordered_set<std::string>& float_array_names) {
  for (const auto& stmt : stmts) {
    lower_stmt(stmt, ctx, returns_float, out, float_names, simd_names, float_array_names);
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
  par_counter = 0;
  MirModule mir;
  for (const auto& proc : module.procs) {
    MirFn fn;
    fn.name = proc.name;
    fn.is_extern = proc.is_extern;
    copy_decorators(proc.decorators, fn.decorators);
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
      std::unordered_set<std::string> float_names;
      std::unordered_set<std::string> simd_names;
      std::unordered_set<std::string> float_array_names;
      LowerArrayCtx arr_ctx;
      arr_ctx.float_array_names = &float_array_names;
      g_arr_ctx = &arr_ctx;
      seed_float_params(fn, float_names);
      LowerCtx ctx{&module, &mir, proc.name};
      lower_stmts(proc.body, ctx, fn.returns_float, fn.body, float_names, simd_names,
                  float_array_names);
      g_arr_ctx = nullptr;
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
