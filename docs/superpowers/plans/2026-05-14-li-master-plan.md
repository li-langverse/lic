# Li Master Implementation Plan (rev. 2)

> **For agentic workers:** Execute phases in order. Python 3.14 typing parity is the typechecker north star — not a minimal v1 subset.

**Goal:** Open-source language: **(1) Lean provability (2) Nim syntax (3) LLVM speed** — in that priority order.

**Architecture:** C++ compiler → MIR → LLVM 18 (sole backend). Bootstrap to self-host later.

**Design spec:** `docs/superpowers/specs/2026-05-14-li-language-design.md`

---

## Phase map (revised)

| Phase | Focus | Plan file | Exit gate |
|-------|-------|-----------|-----------|
| 0 | C++ CMake + LLVM bootstrap | `2026-05-14-phase-00-bootstrap.md` (needs C++ rewrite) | Hello binary via LLVM |
| 1 | Nim lexer/parser | `2026-05-14-phase-01-lexer-parser.md` | Parse fixtures |
| 2a | Types: scalars, unions, literals, aliases | `2026-05-14-phase-02a-types-core.md` (new) | mypy-parity fixtures pass |
| 2b | Types: generics PEP 695, Callable, Protocol | `2026-05-14-phase-02b-types-generics.md` (new) | Protocol structural tests |
| 2c | Types: TypedDict, enums, collections | `2026-05-14-phase-02c-types-collections.md` (new) | dict/list/tuple tests |
| 2d | Borrow + effects + `array[N,T]` | `2026-05-14-phase-02-typechecker.md` | borrow error tests |
| 2e | Contracts + refinements | TBD | VC generation |
| 2f | Lean 4 verify | TBD | `lic verify` on integers/reals |
| 3 | MIR + LLVM codegen | `2026-05-14-phase-03-mir-codegen.md` | `lic build` |
| 4 | Stdlib + runtime + deferred annotations | `2026-05-14-phase-04-runtime-stdlib.md` | hello + collections run |
| 5 | Tetris | `2026-05-14-phase-05-tetris.md` | playable game |
| 5b | Benchmarks & sims | `2026-05-14-benchmarks-and-simulations.md` | **Verified** Tier 2 physics + cross-lang CSV |
| 6 | Self-host (post-live) | TBD | `lic` built by li |

**Old 2-week schedule is void.** Type parity alone is ~6 months part-time.

---

## Stack decision record

| Decision | Choice | Rejected |
|----------|--------|----------|
| Compiler host | **C++** | Zig (rejected), Rust v0 (slow link) |
| Codegen | **LLVM 18 only** | Cranelift, interpreted fallback |
| Type baseline | **Python 3.14** | Ad-hoc minimal types |
| Syntax | **Nim-like** | Python syntax (user chose Nim) |
| License | **MIT OR Apache-2.0** | Proprietary |

---

## Sub-plan index

| File | Status |
|------|--------|
| `2026-05-14-phase-00-bootstrap.md` | **Done** — C++ + CMake + LLVM smoke |
| `2026-05-14-phase-01-lexer-parser.md` | Valid structure; retarget paths to `compiler/` |
| `2026-05-14-phase-02-typechecker.md` | Partial; split into 2a–2d |
| `2026-05-14-phase-03-mir-codegen.md` | LLVM-only codegen |
| `2026-05-14-phase-04-runtime-stdlib.md` | Add PEP 649 deferred annotations |
| `2026-05-14-phase-05-tetris.md` | Valid |
| `2026-05-14-benchmarks-and-simulations.md` | Physics, ML, cross-lang harness |

---

## Phase completion tracker

- [x] Phase 0 — C++ / LLVM bootstrap
- [ ] Phase 1 — Lexer + Parser
- [ ] Phase 2a — Type core
- [ ] Phase 2b — Generics + Protocol
- [ ] Phase 2c — Collections + TypedDict
- [ ] Phase 2d — Borrow + effects
- [ ] Phase 3 — MIR + LLVM codegen
- [ ] Phase 4 — Runtime + stdlib
- [ ] Phase 5 — Tetris
- [ ] Phase 5b — Benchmarks & simulations
- [ ] Phase 6 — Self-host
