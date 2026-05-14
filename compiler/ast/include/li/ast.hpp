#pragma once

#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <vector>

namespace li {

struct Span {
  std::size_t start = 0;
  std::size_t end = 0;
};

struct TypeExpr {
  Span span;
  std::string name;
};

struct Param {
  Span span;
  std::string name;
  TypeExpr type;
};

enum class ContractKind { Requires, Ensures, Decreases, Invariant };

enum class BinOp { Add, Sub, Mul, Div, Le, Lt, Ge, Gt, Eq, Ne, And, Or };

struct Expr {
  enum class Kind { IntLit, Ident, BinOp, Call, UnaryNot };
  Kind kind = Kind::IntLit;
  Span span;
  std::int64_t int_value = 0;
  std::string ident;
  BinOp bin_op = BinOp::Add;
  std::unique_ptr<Expr> lhs;
  std::unique_ptr<Expr> rhs;
  std::unique_ptr<Expr> operand;
  std::vector<std::unique_ptr<Expr>> args;
};

struct Contract {
  ContractKind kind;
  Span span;
  std::unique_ptr<Expr> expr;
};

struct Stmt {
  enum class Kind { Return, If, Expr };
  Kind kind = Kind::Return;
  Span span;
  std::unique_ptr<Expr> expr;
  std::unique_ptr<Expr> cond;
  std::vector<Stmt> then_body;
  std::optional<std::vector<Stmt>> else_body;
};

struct ProcDecl {
  Span span;
  std::string name;
  std::vector<Param> params;
  std::optional<TypeExpr> ret_type;
  std::vector<Contract> contracts;
  std::vector<Stmt> body;
};

struct Module {
  std::vector<ProcDecl> procs;
};

std::string debug_expr(const Expr& e, int indent = 0);
std::string debug_module(const Module& m);

}  // namespace li
