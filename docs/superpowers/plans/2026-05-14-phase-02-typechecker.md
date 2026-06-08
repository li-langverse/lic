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

- [x] `enum Type { Int, Uint, WrappingInt, Float64, Bool, Unit, String, Array { len: u64, elem: Box<Type> }, Option(Box<Type>), Enum(EnumId), Object(ObjectId), Proc { .. } }` (C++: `TypeExpr` + `typecheck.cpp`)
- [x] `TypeCtx::define_type`, `lookup`, `define_proc` (C++: `TypecheckState` in `typecheck.cpp`)

---

### Task 2: Typecheck expressions and stmts

**Files:**
- Create: `crates/li_types/src/check.rs`
- Test: `crates/li_types/tests/check_fib.rs`

- [x] `check_module(&Module) -> Result<TypedModule, Vec<TypeError>>` (C++: `typecheck_module`)
- [x] Return typed wrapper nodes or side table `node_id → Type` (C++: `TypecheckResult` + AST type fields)

---

### Task 3: Borrow checker (lexical)

**Files:**
- Create: `crates/li_types/src/borrow.rs`
- Test: `crates/li_types/tests/borrow_errors.rs`

- [x] Track `Owned | BorrowImm | BorrowMut` per local (`borrowck.cpp`)
- [x] Reject: use after move, two `mut` borrows, mut while imm borrow live (`li-tests/borrow/`)
- [x] v1: no references in struct fields yet

---

### Task 4: Scientific error fixtures

**Files:**
- Create: `tests/fixtures/bad_array_index.li`
- Create: `tests/fixtures/bad_numeric_mix.li`
- Create: `tests/fixtures/bad_overflow_mode.li`

```nim
# bad_array_index.li — board[25, 0] when array[20, array[10, int]]
```

- [x] Tests assert compile error messages mention dimension / type mismatch (`li-tests/typecheck/bad_*.li`)

---

### Task 5: CLI `lic check`

**Files:**
- Modify: `crates/lic/src/main.rs`

- [x] `lic check file.li` — parse + typecheck, exit 1 on errors (`compiler/lic/main.cpp`)

---

### Phase 2 exit gate

- [x] `fib.li` typechecks (`li-tests/typecheck/fib.li`)
- [x] All `bad_*.li` fail with expected errors
- [x] Borrow double-mut test fails cleanly (`li-tests/borrow/double_mut.li`)

### Exit gate — G-* register

Every applicable row from [provability-gaps.md](../../verification/provability-gaps.md) is cited below (or **N/A** with rationale). Register status is **Partial** unless noted — this table is cross-link honesty only, not gap closure.

| G-* ID | Applicability | Exit-gate evidence (today) | Notes |
|--------|---------------|------------------------------|-------|
| [**G-vc**](../../verification/provability-gaps.md#g-vc) | **Yes** | `li-tests/contracts_verify/`, `vc_emit_contracts.sh` | Primary 2e overlap; typecheck emits contract hooks (**Partial**) |
| [**G-bnd**](../../verification/provability-gaps.md#g-bnd) | **Yes** | Literal index bounds at typecheck; release path open | MIR refinement in [phase 03](2026-05-14-phase-03-mir-codegen.md) |
| [**G-def**](../../verification/provability-gaps.md#g-def) | **Yes** | `li-tests/encapsulation/`, method/`self` surface | PH-2j overlap |
| [**G-math-syn**](../../verification/provability-gaps.md#g-math-syn) | **Yes** | `li-tests/math_syntax/` | PH-2h |
| [**G-narrow**](../../verification/provability-gaps.md#g-narrow) | **Yes** | `historic_ariane5_narrowing.li` reject | 2e policy |
| [**G-oop**](../../verification/provability-gaps.md#g-oop) | **Yes** | trait/method tests partial | PH-2j |
| **G-lean** | **N/A** | — | Lean gate is **2f**, not phase-02 exit |
| **G-ann** | **N/A** | — | Phase 4 deferred annotations |
| **G-par** | **N/A** | — | Phase 7b parallel surface |
| **G-meta** | **N/A** | — | Research limit per [master plan](2026-05-14-li-master-plan.md#compiler-tasks-vs-proof-gaps) |
