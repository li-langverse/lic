# Matrix `@` shape rules + lowering — Done gate (PH-2i / G-math / G-bnd)

> **Issue:** [#20](https://github.com/li-langverse/lic/issues/20) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (compile-time shape errors), **Easy** (math surface `A @ B`), **Fast** (lowering to SIMD/OpenMP via **PH-7e**)  
> **Learned from:** [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md), [2026-05-14-li-master-plan.md](./2026-05-14-li-master-plan.md) (Phase **2i** / **7e** rows), [provability-gaps.md](../../verification/provability-gaps.md) (**G-math**, **G-bnd**), [linear-algebra.md](../../language/linear-algebra.md), `compiler/types/typecheck.cpp` (`BinOp::MatMul`), `li-tests/math_linalg/`

## north_star_fit

Scientific computing / HPC linalg (**domain**) · **PH-2i** (math surface types) · **PH-7e** (math → SIMD MIR) · **G-math** (shape errors at compile time) · **G-bnd** (static index proofs on lowered loops). Proof-before-perf: shape + contract gates land before tier-1 perf claims.

## Baseline (2026-06-07, `main`)

| Slice | Status | Evidence |
|-------|--------|----------|
| **1d dot** `array[N,float] @ array[N,float] → float` | **Done (types + MIR)** | `array_dot_matmul.li`, `ArrayDotF64` in `compiler/mir/lower.cpp`; mismatch → `array_dot_mismatch.li` |
| **2d GEMM** `array[M,array[K,float]] @ array[K,array[N,float]]` | **Done (types + MIR)** | `matmul_2x3_ok.li`, `matmul_25x25_at_codegen.li`, `ArrayMatMul2DF64`; inner mismatch → `matmul_dim_mismatch.li` |
| **Element-wise** `a * b` (not `@`) | **Done** | `elementwise_*.li`, length-1 broadcast (`broadcast_len1_*.li`) |
| **`@` vs `*` disambiguation** | **Done in typecheck** | `@` → dot/GEMM only; `*` → element-wise + broadcast rules |
| **3d+ / `tensor[(M,N), f64]`** | **Deferred** | Phase 3 tensor; no rank-3 `@` in v1 |
| **SIMD/blocked matmul lowering** | **Partial (7e)** | `ArrayMatMulBlocked2DF64`, tier-1 `matmul_*` benches; full Done criteria → [#27](https://github.com/li-langverse/lic/issues/27) |
| **Float Lean Props for full matmul** | **Partial (2f)** | `linalg_mat2_at2_float_closed`; loop/GEMM Props open — **P-linalg** |

**REQ-2i-matrix-at:** Formalize `@` shape resolution (1d dot vs 2d GEMM vs reject), seed compile_fail/compile_ok matrix in `math_linalg/`, and wire exit gates so **G-math** + **PH-7e** tracker rows flip only when tests + lowering evidence land — not when spec text alone merges.

## Goal

Close the **planning gap** for matrix `@` under Phase **2i**: a single checkable spec for **GEMM vs dot vs reject**, explicit **non-goals** (element-wise is `*`, 3d deferred), test manifest rows, and a **7e handoff** so codegen agents do not conflate shape surface work with horner/matmul perf (#11, #27).

## Non-goals

- **Element-wise matrix multiply** — use `*`; `@` never lowers to element-wise (`*` rules live under broadcast / #526).
- **3d+ tensor `@`** — deferred to Phase 3 `tensor[(M,N), T]`; v1 rejects rank > 2 at typecheck.
- **NumPy full-rank broadcast on `@`** — [#526](https://github.com/li-langverse/lic/issues/526); orthogonal defer-policy track.
- **PH-7e horner / FMA micro-kernel perf** — [#11](https://github.com/li-langverse/lic/issues/11); codegen perf, not `@` type surface.
- **Doc-c cross-link-only** — [#12](https://github.com/li-langverse/lic/issues/12).
- **`trusted.lean` / `Discharge.lean` edits** — human-approved proof_gap issues only ([#574](https://github.com/li-langverse/lic/issues/574) class).

## Shape resolution spec (v1 binding)

`@` resolves by **operand rank and element type** at typecheck; no runtime dispatch.

| Left | Right | Result | Rule |
|------|-------|--------|------|
| `array[N, float]` | `array[N, float]` | `float` | **1d dot** — same `N`; lowers to `ArrayDotF64` |
| `array[M, array[K, float]]` | `array[K, array[N, float]]` | `array[M, array[N, float]]` | **2d GEMM** — inner `K` must match; lowers to `ArrayMatMul2DF64` (or blocked hook when sized) |
| `array[M, array[K, float]]` | `array[P, array[N, float]]` where `K ≠ P` | — | **compile_fail** — `"inner dimension mismatch"` |
| `array[N, float]` | `array[M, float]` where `N ≠ M` | — | **compile_fail** — `"matrix multiply '@' requires matching float arrays"` |
| `array[N, int]` × any | — | — | **compile_fail** — `@` on numeric arrays requires `float` elem (v1) |
| rank ≥ 3 nested `array` | — | — | **compile_fail** — `"matrix '@' requires 1d dot or 2d nested float arrays"` (message TBD in impl) |

**GEMM vs element-wise:** Only `*` / `+` / `-` / `/` / `**` use element-wise + length-1 broadcast rules. **`@` is never element-wise.**

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-2i-a/b/c** | Element-wise, reductions, 2d `@` MIR already on `main` |
| **PH-7e** | SIMD/blocked lowering exit — [#27](https://github.com/li-langverse/lic/issues/27), [#32](https://github.com/li-langverse/lic/issues/32) |
| **PH-2f / P-linalg** | Float `@` Lean Props — partial; loop dot open |
| **#526** | NumPy-rank broadcast — does not block this plan |
| Human | **`plan-approved`** on #20 before parser/typecheck/MIR changes |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Spec landing** — this plan + `linear-algebra.md` table cites shape rules; `2026-05-16-li-math-linalg-surface.md` cross-link | Handbook matches typecheck behavior |
| **B** | **Typecheck audit** — `typecheck.cpp` `MatMul` branch matches §Shape resolution; int-`@` reject if missing | `compile_fail` for `array[4,int] @ array[4,int]` (new or existing) |
| **C** | **Test matrix** — `math_linalg/`: minimal 2×2 GEMM golden (`verify_ok`), 3d-rank `compile_fail`, manifest.toml rows | `./li-tests/run_all.sh math_linalg` green |
| **D** | **MIR map doc** — table: `@` form → `MirOp` (`ArrayDotF64`, `ArrayMatMul2DF64`, `ArrayMatMulBlocked2DF64`) | `docs/language/linear-algebra.md` §Lowering |
| **E** | **7e exit gate** — checklist block in plan + pointer to [#27](https://github.com/li-langverse/lic/issues/27): tier-1 `matmul_naive` / `matmul_blocked` ≤1.2× C++ under `check-tier1-li-vs-cpp.sh` (strict optional) | **G-math** row cites harness names |
| **F** | **Tracker honesty** — master plan line 447 (**2i**) notes `@` shape slice done; matrix `@` SIMD slice stays partial until **E**; **G-math** partial row updated | Same PR as C–E implementation |

## Tests / benches

### Required (`li-tests/math_linalg/`)

| File | Outcome | Purpose |
|------|---------|---------|
| `array_dot_matmul.li` | `verify_ok` | 1d dot compile + build (existing) |
| `array_dot_mismatch.li` | `compile_fail` | 1d length mismatch (existing) |
| `matmul_2x3_ok.li` | `verify_ok` | minimal 2d GEMM (existing) |
| `matmul_dim_mismatch.li` | `compile_fail` | inner `K` mismatch (existing) |
| `matmul_2x2_golden.li` | `verify_ok` | **new** — 2×2 numeric golden (sub C) |
| `matmul_3d_rank_reject.li` | `compile_fail` | **new** — rank-3 `@` rejected (sub C) |

### Tooling / proof

- `discharge_linalg_int_lean.sh` — no regression on closed int corpus.
- `contracts_verify/linalg_mat2_at2_float_closed.li` — float 2×2 Prop stays green.

### Benchmarks (PH-7e — sub E, not blocking plan merge)

- `benchmarks/tier1_micro/matmul_naive/li/main.li`
- `benchmarks/tier1_micro/matmul_blocked/li/main.li`
- `li-tests/tooling/tier1_li_vs_cpp.sh` / `check-tier1-li-vs-cpp.sh`

## Provability map

| Gap / PH | Before | After implementation (subs B–F) |
|----------|--------|----------------------------------|
| **G-math** | Partial — 1d/2d `@` on `main` | Partial — **shape slice closed**; SIMD matmul + float GEMM Props still partial |
| **G-bnd** | Partial | Unchanged unless new static bound witnesses added for matmul loops |
| **G-lean** | Partial | Unchanged — no `trusted.lean` in this track |
| **PH-2i** | Partial — `@` lowering exists, tracker vague | Partial — shape rules + tests **done**; NumPy broadcast (#526) still open |
| **PH-7e** | Partial | Partial until [#27](https://github.com/li-langverse/lic/issues/27) Done criteria met |

Do **not** mark **G-math** **Done** from shape-only work; perf + Lean corpus remain open.

## PH-7e handoff (exit gate for lowering slice)

Implementation PR(s) after **`plan-approved`** must satisfy **all** before master plan **7e** `@` row advances:

1. `matmul_2x2_golden.li` + `matmul_3d_rank_reject.li` in manifest (sub C).
2. `linear-algebra.md` lowering table matches MIR ops (sub D).
3. Tier-1 `matmul_naive` and `matmul_blocked` documented in **G-math** “How we know” with harness command (sub E; may remain advisory ≤1.2×).
4. Cross-link [#27](https://github.com/li-langverse/lic/issues/27) checklist — SIMD matmul Done is **7e-owned**, not duplicated here.

## Rollout

1. Merge this plan PR → maintainer adds **`plan-approved`** on #20; remove **`plan-needed`**.
2. Implementation PR: subs **B–D** (typecheck audit + new tests + handbook).
3. Follow-on: sub **E** may land with **#27** / **#11** implementers (7e perf).
4. Sub **F** in same PR as step 2 when tests green.
5. Hand to **code_implementer** only after `plan-approved` + plan on `main`.

## Human-only

- Maintainer **`plan-approved`** before product code.
- Confirm v1 rejects rank-3 `@` (vs defer to explicit error message review).
- **`trusted.lean`** changes — separate human issues only.

## Distinct issues (do not duplicate)

| Issue | Scope |
|-------|-------|
| [#11](https://github.com/li-langverse/lic/issues/11) | Horner / FMA codegen perf |
| [#12](https://github.com/li-langverse/lic/issues/12) | Doc-c G-* exit gate linking |
| [#27](https://github.com/li-langverse/lic/issues/27) | PH-7e SIMD matmul Done criteria |
| [#526](https://github.com/li-langverse/lic/issues/526) | NumPy-rank broadcast defer policy |
