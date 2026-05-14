#include "li/lexer.hpp"
#include "li/parser.hpp"

#include <utility>

namespace li {

namespace {

struct Parser {
  const std::vector<Token>& tokens;
  std::size_t i = 0;
  std::string file;
  DiagnosticBag& diags;

  explicit Parser(const std::vector<Token>& toks, std::string file_name,
                  DiagnosticBag& bag)
      : tokens(toks), file(std::move(file_name)), diags(bag) {}

  const Token& cur() const { return tokens[i]; }
  const Token& peek(std::size_t off = 0) const {
    const std::size_t j = i + off;
    return j < tokens.size() ? tokens[j] : tokens.back();
  }
  bool at(TokenKind k) const { return cur().kind == k; }
  bool accept(TokenKind k) {
    if (at(k)) {
      i++;
      return true;
    }
    return false;
  }
  bool expect(TokenKind k, const char* what) {
    if (!accept(k)) {
      SourceLoc loc{file, cur().line, cur().column, cur().start};
      diags.error(loc, std::string("expected ") + what);
      return false;
    }
    return true;
  }
  void skip_newlines() {
    while (at(TokenKind::Newline)) {
      i++;
    }
  }

  SourceLoc loc(const Token& t) const {
    return SourceLoc{file, t.line, t.column, t.start};
  }

  std::unique_ptr<Expr> parse_expr(int min_prec = 0);
  std::unique_ptr<Expr> parse_primary();
  std::unique_ptr<Expr> parse_postfix(std::unique_ptr<Expr> base);
  TypeExpr parse_type();
  Param parse_param();
  std::unique_ptr<Expr> parse_contract_expr();
  Contract parse_contract();
  std::vector<Stmt> parse_block();
  Stmt parse_stmt();
  ProcDecl parse_proc();
  TypeAlias parse_type_alias();

  bool parse_module(Module& out) {
    skip_newlines();
    while (!at(TokenKind::Eof)) {
      if (at(TokenKind::KwProc)) {
        out.procs.push_back(parse_proc());
        skip_newlines();
      } else if (at(TokenKind::KwType)) {
        out.types.push_back(parse_type_alias());
        skip_newlines();
      } else {
        diags.error(loc(cur()), "expected top-level declaration");
        return false;
      }
    }
    return true;
  }
};

std::unique_ptr<Expr> Parser::parse_primary() {
  const Token& t = cur();
  if (t.kind == TokenKind::IntLit) {
    i++;
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::IntLit;
    e->span = {t.start, t.end};
    e->int_value = t.int_value;
    return parse_postfix(std::move(e));
  }
  if (t.kind == TokenKind::FloatLit) {
    i++;
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::FloatLit;
    e->span = {t.start, t.end};
    e->float_value = t.float_value;
    return parse_postfix(std::move(e));
  }
  if (t.kind == TokenKind::Ident || t.kind == TokenKind::KwResult ||
      t.kind == TokenKind::KwTrue || t.kind == TokenKind::KwFalse) {
    const std::string name(t.text);
    i++;
    auto e = std::make_unique<Expr>();
    e->span = {t.start, t.end};
    if (accept(TokenKind::LParen)) {
      e->kind = Expr::Kind::Call;
      e->ident = name;
      if (!at(TokenKind::RParen)) {
        do {
          e->args.push_back(parse_expr());
        } while (accept(TokenKind::Comma));
      }
      if (!expect(TokenKind::RParen, "')'")) {
        return nullptr;
      }
    } else {
      e->kind = Expr::Kind::Ident;
      e->ident = name;
    }
    return parse_postfix(std::move(e));
  }
  if (accept(TokenKind::LParen)) {
    auto inner = parse_expr();
    if (!expect(TokenKind::RParen, "')'")) {
      return nullptr;
    }
    return parse_postfix(std::move(inner));
  }
  diags.error(loc(t), "expected expression");
  return nullptr;
}

std::unique_ptr<Expr> Parser::parse_postfix(std::unique_ptr<Expr> base) {
  while (accept(TokenKind::LBracket)) {
    auto idx = parse_expr();
    if (!expect(TokenKind::RBracket, "']'")) {
      return nullptr;
    }
    auto node = std::make_unique<Expr>();
    node->kind = Expr::Kind::Index;
    node->span = {base->span.start, tokens[i - 1].end};
    node->base = std::move(base);
    node->index = std::move(idx);
    base = std::move(node);
  }
  return base;
}

int prec(TokenKind k) {
  switch (k) {
    case TokenKind::KwOr: return 1;
    case TokenKind::KwAnd: return 2;
    case TokenKind::EqEq:
    case TokenKind::Ne:
    case TokenKind::Lt:
    case TokenKind::Le:
    case TokenKind::Gt:
    case TokenKind::Ge: return 3;
    case TokenKind::Plus:
    case TokenKind::Minus: return 4;
    case TokenKind::Star:
    case TokenKind::Slash: return 5;
    default: return -1;
  }
}

BinOp binop(TokenKind k) {
  switch (k) {
    case TokenKind::Plus: return BinOp::Add;
    case TokenKind::Minus: return BinOp::Sub;
    case TokenKind::Star: return BinOp::Mul;
    case TokenKind::Slash: return BinOp::Div;
    case TokenKind::Le: return BinOp::Le;
    case TokenKind::Lt: return BinOp::Lt;
    case TokenKind::Ge: return BinOp::Ge;
    case TokenKind::Gt: return BinOp::Gt;
    case TokenKind::EqEq: return BinOp::Eq;
    case TokenKind::Ne: return BinOp::Ne;
    case TokenKind::KwAnd: return BinOp::And;
    case TokenKind::KwOr: return BinOp::Or;
    default: return BinOp::Add;
  }
}

std::unique_ptr<Expr> Parser::parse_expr(int min_prec) {
  std::unique_ptr<Expr> left;
  if (at(TokenKind::KwNot)) {
    const Token t = cur();
    i++;
    left = std::make_unique<Expr>();
    left->kind = Expr::Kind::UnaryNot;
    left->span = {t.start, t.end};
    left->operand = parse_expr(100);
  } else {
    left = parse_primary();
  }
  if (!left) {
    return nullptr;
  }
  while (true) {
    const int p = prec(cur().kind);
    if (p < 0 || p < min_prec) {
      break;
    }
    const Token op = cur();
    i++;
    auto right = parse_expr(p + 1);
    if (!right) {
      return nullptr;
    }
    auto node = std::make_unique<Expr>();
    node->kind = Expr::Kind::BinOp;
    node->span = {left->span.start, right->span.end};
    node->bin_op = binop(op.kind);
    node->lhs = std::move(left);
    node->rhs = std::move(right);
    left = std::move(node);
  }
  return left;
}

TypeExpr Parser::parse_type() {
  if (at(TokenKind::Ident) && cur().text == "var") {
    i++;
  }
  const Token& t = cur();
  TypeExpr ty;
  ty.span = {t.start, t.end};
  if (t.kind != TokenKind::Ident) {
    diags.error(loc(t), "expected type");
    return ty;
  }
  const std::string name(t.text);
  i++;
  if (name == "array" && accept(TokenKind::LBracket)) {
    ty.kind = TypeKind::Array;
    ty.name = "array";
    if (!at(TokenKind::IntLit)) {
      diags.error(loc(cur()), "expected array size");
      return ty;
    }
    ty.array_size = cur().int_value;
    i++;
    expect(TokenKind::Comma, "','");
    ty.elem = std::make_unique<TypeExpr>(parse_type());
    expect(TokenKind::RBracket, "']'");
  } else {
    ty.kind = TypeKind::Named;
    ty.name = name;
  }
  return ty;
}

Param Parser::parse_param() {
  const Token& t = cur();
  Param p;
  p.span = {t.start, t.end};
  p.name = std::string(t.text);
  i++;
  expect(TokenKind::Colon, "':'");
  p.type = parse_type();
  return p;
}

std::unique_ptr<Expr> Parser::parse_contract_expr() {
  skip_newlines();
  return parse_expr();
}

Contract Parser::parse_contract() {
  Contract c;
  const Token kw = cur();
  if (kw.kind == TokenKind::KwRequires) {
    c.kind = ContractKind::Requires;
  } else if (kw.kind == TokenKind::KwEnsures) {
    c.kind = ContractKind::Ensures;
  } else if (kw.kind == TokenKind::KwDecreases) {
    c.kind = ContractKind::Decreases;
  } else {
    c.kind = ContractKind::Invariant;
  }
  c.span = {kw.start, kw.end};
  i++;
  c.expr = parse_contract_expr();
  skip_newlines();
  return c;
}

std::vector<Stmt> Parser::parse_block() {
  std::vector<Stmt> body;
  skip_newlines();
  if (!expect(TokenKind::Indent, "indented block")) {
    return body;
  }
  skip_newlines();
  while (!at(TokenKind::Dedent) && !at(TokenKind::Eof)) {
    const std::size_t before = i;
    body.push_back(parse_stmt());
    if (i == before) {
      diags.error(loc(cur()), "failed to parse statement");
      break;
    }
    skip_newlines();
  }
  expect(TokenKind::Dedent, "dedent");
  return body;
}

Stmt Parser::parse_stmt() {
  Stmt s;
  if (at(TokenKind::KwVar)) {
    const Token t = cur();
    s.kind = Stmt::Kind::VarDecl;
    s.span = {t.start, t.end};
    i++;
    const Token name = cur();
    s.var_name = std::string(name.text);
    i++;
    expect(TokenKind::Colon, "':'");
    s.var_type = parse_type();
    if (accept(TokenKind::Eq)) {
      s.init = parse_expr();
    }
    skip_newlines();
    return s;
  }
  if (at(TokenKind::KwWhile)) {
    const Token t = cur();
    s.kind = Stmt::Kind::Expr;
    s.span = {t.start, t.end};
    i++;
    while (!at(TokenKind::Dedent) && !at(TokenKind::Eof) && !at(TokenKind::Eq)) {
      i++;
    }
    if (at(TokenKind::Eq)) {
      i++;
    }
    skip_newlines();
    if (at(TokenKind::Indent)) {
      parse_block();
    }
    return s;
  }
  if (at(TokenKind::Ident) && cur().text == "parallel") {
    s.kind = Stmt::Kind::Expr;
    s.span = {cur().start, cur().end};
    while (!at(TokenKind::Dedent) && !at(TokenKind::Eof)) {
      const std::size_t b = i;
      i++;
      if (at(TokenKind::Eq)) {
        i++;
        skip_newlines();
        if (at(TokenKind::Indent)) {
          parse_block();
        }
        break;
      }
      if (i == b) {
        break;
      }
    }
    return s;
  }
  if (at(TokenKind::KwReturn)) {
    const Token t = cur();
    s.kind = Stmt::Kind::Return;
    s.span = {t.start, t.end};
    i++;
    s.expr = parse_expr();
    skip_newlines();
    return s;
  }
  if (at(TokenKind::KwIf)) {
    const Token t = cur();
    s.kind = Stmt::Kind::If;
    s.span = {t.start, t.end};
    i++;
    s.cond = parse_expr();
    expect(TokenKind::Colon, "':'");
    skip_newlines();
    s.then_body = parse_block();
    return s;
  }
  s.kind = Stmt::Kind::Expr;
  s.expr = parse_expr();
  skip_newlines();
  return s;
}

ProcDecl Parser::parse_proc() {
  ProcDecl proc;
  expect(TokenKind::KwProc, "'proc'");
  const Token name = cur();
  proc.span = {name.start, name.end};
  proc.name = std::string(name.text);
  i++;
  expect(TokenKind::LParen, "'('");
  if (!at(TokenKind::RParen)) {
    do {
      proc.params.push_back(parse_param());
    } while (accept(TokenKind::Comma));
  }
  expect(TokenKind::RParen, "')'");
  if (accept(TokenKind::Arrow)) {
    proc.ret_type = parse_type();
  }
  skip_newlines();
  while (at(TokenKind::KwRequires) || at(TokenKind::KwEnsures) ||
         at(TokenKind::KwDecreases) || at(TokenKind::KwInvariant)) {
    proc.contracts.push_back(parse_contract());
  }
  expect(TokenKind::Eq, "'='");
  skip_newlines();
  proc.body = parse_block();
  return proc;
}

TypeAlias Parser::parse_type_alias() {
  TypeAlias alias;
  expect(TokenKind::KwType, "'type'");
  const Token name = cur();
  alias.span = {name.start, name.end};
  alias.name = std::string(name.text);
  i++;
  expect(TokenKind::Eq, "'='");
  alias.definition = parse_type();
  skip_newlines();
  return alias;
}

}  // namespace

ParseResult parse_module(std::string source, std::string file) {
  ParseResult result;
  Lexer lexer(std::move(source), file);
  if (!lexer.tokenize(result.diagnostics)) {
    return result;
  }
  Parser p{lexer.tokens(), file, result.diagnostics};
  Module m;
  if (p.parse_module(m)) {
    result.module = std::move(m);
  }
  return result;
}

}  // namespace li
