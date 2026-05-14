# Phase 1: Lexer + Parser Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Tokenize and parse the v1 Li surface syntax into an AST.

**Architecture:** `logos` lexer in `li_lexer`; recursive-descent parser in `li_parser` building `li_ast` types; diagnostics via `miette`.

**Tech Stack:** logos, miette, thiserror

**Depends on:** Phase 0  
**Blocks:** Phase 2

---

## v1 grammar (EBNF summary)

```
module      ::= stmt*
stmt        ::= proc_decl | type_decl | var_decl
proc_decl   ::= 'proc' IDENT '(' params? ')' ret_type? raises_clause? '=' INDENT stmt+ DEDENT
type_decl   ::= 'type' INDENT type_def+ DEDENT
type_def    ::= IDENT '=' (enum_def | object_def | array_alias)
enum_def    ::= 'enum' INDENT IDENT (',' IDENT)* DEDENT
object_def  ::= 'object' INDENT field+ DEDENT
field       ::= IDENT ':' type_expr
stmt_body   ::= return_stmt | if_stmt | while_stmt | assign | expr_stmt | var_decl
expr        ::= pratt pipeline (or, and, compare, add, mul, unary, primary)
primary     ::= INT | FLOAT | STRING | IDENT | call | field | index | '(' expr ')'
```

---

### Task 1: AST definitions

**Files:**
- Create: `crates/li_ast/src/lib.rs`
- Create: `crates/li_ast/src/nodes.rs`

- [ ] Define `Module`, `Stmt`, `Expr`, `TypeExpr`, `Param`, `Field`, `EnumVariant`, spans on every node
- [ ] Add `pub type Span = (usize, usize)` for byte offsets
- [ ] Unit test: construct a sample `fib` AST by hand and `assert_eq!` Debug snapshot

---

### Task 2: Lexer

**Files:**
- Create: `crates/li_lexer/src/lib.rs`
- Create: `crates/li_lexer/src/token.rs`
- Test: `crates/li_lexer/tests/tokens.rs`

- [ ] Token enum: keywords (`proc`, `type`, `object`, `enum`, `var`, `let`, `if`, `else`, `elif`, `while`, `return`, `raises`, `echo`, `true`, `false`, `and`, `or`, `not`, `is`), punctuation, literals, `Ident`, `Indent`, `Dedent`, `Newline`, `Eof`
- [ ] Indentation stack: INDENT width 2 spaces; tabs error
- [ ] Fixture test: tokenize `tests/fixtures/fib.li`

---

### Task 3: Parser

**Files:**
- Create: `crates/li_parser/src/lib.rs`
- Create: `crates/li_parser/src/parser.rs`
- Test: `crates/li_parser/tests/parse_fib.rs`

- [ ] `parse_module(source: &str) -> Result<Module, ParseError>`
- [ ] Pratt parser for expressions with precedence table
- [ ] Parse `tests/fixtures/fib.li` → AST insta snapshot

---

### Task 4: CLI hook

**Files:**
- Modify: `crates/lic/src/main.rs`

- [ ] Add `lic parse <file>` subcommand printing AST debug or JSON

---

### Task 5: Fixtures

**Files:**
- Create: `tests/fixtures/fib.li`
- Create: `tests/fixtures/types.li`
- Create: `tests/fixtures/invalid_indent.li`

```nim
# tests/fixtures/fib.li
proc fib(n: int) -> int =
  if n <= 1:
    return n
  return fib(n - 1) + fib(n - 2)
```

---

### Phase 1 exit gate

- [ ] All lexer/parser tests pass
- [ ] `lic parse tests/fixtures/fib.li` succeeds
- [ ] `invalid_indent.li` yields diagnostic with line/column
