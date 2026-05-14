#include "li/typecheck.hpp"

#include <map>
#include <memory>
#include <string>

namespace li {
namespace {

enum class TyKind { Int, Float, Bool, Array, Named };

struct Ty {
  TyKind kind = TyKind::Int;
  std::int64_t array_size = 0;
  std::shared_ptr<Ty> elem;
};

using TyPtr = std::shared_ptr<Ty>;

TyPtr make_int() { return std::make_shared<Ty>(Ty{TyKind::Int}); }
TyPtr make_float() { return std::make_shared<Ty>(Ty{TyKind::Float}); }
TyPtr make_bool() { return std::make_shared<Ty>(Ty{TyKind::Bool}); }

struct Ctx {
  std::map<std::string, TyPtr> aliases;
  std::map<std::string, TyPtr> locals;
  DiagnosticBag& diags;
  std::string file;

  SourceLoc loc(const Span& s) const { return SourceLoc{file, 1, 1, s.start}; }

  TyPtr resolve_type(const TypeExpr& te) {
    if (te.kind == TypeKind::Array) {
      auto t = std::make_shared<Ty>();
      t->kind = TyKind::Array;
      t->array_size = te.array_size;
      t->elem = resolve_type(*te.elem);
      return t;
    }
    const auto it = aliases.find(te.name);
    if (it != aliases.end()) {
      return it->second;
    }
    if (te.name == "int") {
      return make_int();
    }
    if (te.name == "float" || te.name == "float64" || te.name == "f64") {
      return make_float();
    }
    if (te.name == "bool") {
      return make_bool();
    }
    if (te.name == "Any") {
      diags.error(loc(te.span), "type 'Any' is forbidden");
      return make_int();
    }
    if (te.name == "unit") {
      return make_int();
    }
    diags.error(loc(te.span), "unknown type '" + te.name + "'");
    return make_int();
  }

  TyPtr type_of(const Expr& e) {
    switch (e.kind) {
      case Expr::Kind::IntLit:
        return make_int();
      case Expr::Kind::FloatLit:
        return make_float();
      case Expr::Kind::Ident: {
        const auto it = locals.find(e.ident);
        if (it == locals.end()) {
          diags.error(loc(e.span), "unknown variable '" + e.ident + "'");
          return make_int();
        }
        return it->second;
      }
      case Expr::Kind::BinOp: {
        const TyPtr l = type_of(*e.lhs);
        const TyPtr r = type_of(*e.rhs);
        if (e.bin_op == BinOp::Add || e.bin_op == BinOp::Sub || e.bin_op == BinOp::Mul ||
            e.bin_op == BinOp::Div) {
          if (l->kind == TyKind::Int && r->kind == TyKind::Int) {
            return make_int();
          }
          if (l->kind == TyKind::Float && r->kind == TyKind::Float) {
            return make_float();
          }
          diags.error(loc(e.span),
                      "cannot mix int and float in arithmetic without explicit cast");
          return make_int();
        }
        return make_bool();
      }
      case Expr::Kind::Call:
        return make_int();
      case Expr::Kind::UnaryNot:
        return make_bool();
      case Expr::Kind::Index: {
        const TyPtr base = type_of(*e.base);
        const TyPtr idx = type_of(*e.index);
        if (idx->kind != TyKind::Int) {
          diags.error(loc(e.span), "array index must be int");
          return make_int();
        }
        if (base->kind != TyKind::Array) {
          diags.error(loc(e.span), "index on non-array type");
          return make_int();
        }
        if (e.index->kind == Expr::Kind::IntLit) {
          const auto i = e.index->int_value;
          if (i < 0 || i >= base->array_size) {
            diags.error(loc(e.span), "array index out of range");
          }
        }
        return base->elem;
      }
    }
    return make_int();
  }

  void check_stmt(const Stmt& s) {
    if (s.kind == Stmt::Kind::VarDecl) {
      const TyPtr declared = resolve_type(s.var_type);
      if (s.init) {
        const TyPtr got = type_of(*s.init);
        if (declared->kind != got->kind) {
          diags.error(loc(s.span), "variable type mismatch for int/float types");
        }
      }
      locals[s.var_name] = declared;
      return;
    }
    if (s.kind == Stmt::Kind::Return && s.expr) {
      type_of(*s.expr);
      return;
    }
    if (s.kind == Stmt::Kind::If) {
      if (s.cond) {
        type_of(*s.cond);
      }
      for (const auto& inner : s.then_body) {
        check_stmt(inner);
      }
      return;
    }
    if (s.expr) {
      type_of(*s.expr);
    }
  }

  void check_proc(const ProcDecl& p) {
    locals.clear();
    bool has_requires = false;
    bool has_ensures = false;
    for (const auto& c : p.contracts) {
      if (c.kind == ContractKind::Requires) {
        has_requires = true;
      }
      if (c.kind == ContractKind::Ensures) {
        has_ensures = true;
      }
    }
    if (!has_requires) {
      diags.error(loc(p.span), "proc missing requires clause");
    }
    if (!has_ensures) {
      diags.error(loc(p.span), "proc missing ensures clause");
    }
    for (const auto& param : p.params) {
      locals[param.name] = resolve_type(param.type);
    }
    for (const auto& s : p.body) {
      check_stmt(s);
    }
  }
};

}  // namespace

TypecheckResult typecheck_module(const Module& module) {
  TypecheckResult result;
  Ctx ctx{{}, {}, result.diagnostics, "module"};
  for (const auto& alias : module.types) {
    ctx.aliases[alias.name] = ctx.resolve_type(alias.definition);
  }
  for (const auto& proc : module.procs) {
    ctx.check_proc(proc);
  }
  result.ok = result.diagnostics.empty();
  return result;
}

}  // namespace li
