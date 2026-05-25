# Phase 2: Typechecker + Borrow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Reject ill-typed programs; attach types to AST; enforce lexical borrow rules and `raises` effect tracking.

**Architecture:** `li_types` owns `TypeCtx`, unification for int literals, borrow state per scope in `Borrowck`.

**Tech Stack:** indexmap, rustc-hash

**Depends on:** Phase 1  
**Blocks:** Phase 3

**Proof gaps (Doc-c):** [G-vc](../../verification/provability-gaps.md#g-vc) · [G-bnd](../../verification/provability-gaps.md#g-bnd) · [G-def](../../verification/provability-gaps.md#g-def) · [G-math-syn](../../verification/provability-gaps.md#g-math-syn)

---

## Type system (v1)

| Type | Notes |
|------|-------|
| `int`, `uint`, `wrapping_int`, `float64`, `bool`, `unit`, `string` | `int` default |
| `array[N, T]` | `N` const usize |
| `Option[T]` | no null |
| `enum Name` | user enums |
| `object Name` | product types |
| `proc(Args) -> Ret` | effect `!raises` set on decl |

**Rules:**
- Literal `42` → `int`; suffix `42u` → `uint`
- `+` on two `int` → `int`; int + float → error
- Index `a[i]` requires `i: int` and bounds proof for literal `i`
- `while` body requires `raises Loop` or `raises IO` on enclosing proc
- `echo` requires `raises IO`

---

### Task 1: Type representation

**Files:**
- Create: `crates/li_types/src/ty.rs`
- Create: `crates/li_types/src/context.rs`

- [ ] `enum Type { Int, Uint, WrappingInt, Float64, Bool, Unit, String, Array { len: u64, elem: Box<Type> }, Option(Box<Type>), Enum(EnumId), Object(ObjectId), Proc { .. } }`
- [ ] `TypeCtx::define_type`, `lookup`, `define_proc`

---

### Task 2: Typecheck expressions and stmts

**Files:**
- Create: `crates/li_types/src/check.rs`
- Test: `crates/li_types/tests/check_fib.rs`

- [ ] `check_module(&Module) -> Result<TypedModule, Vec<TypeError>>`
- [ ] Return typed wrapper nodes or side table `node_id → Type`

---

### Task 3: Borrow checker (lexical)

**Files:**
- Create: `crates/li_types/src/borrow.rs`
- Test: `crates/li_types/tests/borrow_errors.rs`

- [ ] Track `Owned | BorrowImm | BorrowMut` per local
- [ ] Reject: use after move, two `mut` borrows, mut while imm borrow live
- [ ] v1: no references in struct fields yet

---

### Task 4: Scientific error fixtures

**Files:**
- Create: `tests/fixtures/bad_array_index.li`
- Create: `tests/fixtures/bad_numeric_mix.li`
- Create: `tests/fixtures/bad_overflow_mode.li`

```nim
# bad_array_index.li — board[25, 0] when array[20, array[10, int]]
```

- [ ] Tests assert compile error messages mention dimension / type mismatch

---

### Task 5: CLI `lic check`

**Files:**
- Modify: `crates/lic/src/main.rs`

- [ ] `lic check file.li` — parse + typecheck, exit 1 on errors

---

### Phase 2 exit gate

- [x] `fib.li` typechecks — evidence: `li-tests/manifest.toml` `typecheck/fib.li` `verify_ok`; `./build/compiler/lic/lic check li-tests/typecheck/fib.li` exit 0
- [x] All `bad_*.li` fail with expected errors — evidence: `typecheck/bad_*.li` `compile_fail` + `expected_substr` in manifest
- [x] Borrow double-mut test fails cleanly — evidence: `borrow/double_mut.li` `compile_fail` + `expected_substr = "borrow"`
