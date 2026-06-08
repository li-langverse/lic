# PH-7e SIMD / blocked GEMM matmul — Done criteria (G-math)

> **Issue:** [#27](https://github.com/li-langverse/lic/issues/27) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-math), **Fast** (tier-1 ≤1.2× C++ after proof)  
> **Learned from:** [master plan §7e](2026-05-14-li-master-plan.md), [phase 07 native HPC](2026-05-14-phase-07-native-hpc.md), [math-linalg surface](2026-05-16-li-math-linalg-surface.md), [PH-7e tier-1 honesty plan](2026-05-30-ph7e-tier1-red-benchmark-honesty.md), [matmul-blocked-7e study](../numerics/studies/2026-05-30-matmul-blocked-7e.md)

**north_star_fit:** Scientific computing / HPC — **PH-7e**, **PH-2i**, **PH-5b**, **G-math**

## Goal

Define a short, checkable checklist for **SIMD and blocked GEMM-style matmul** lowering in Li so agents know when the master-plan **Phase 7e** `- [ ]` may flip and when work is **explicitly deferred** with a superseding PH-ID / issue.

This plan is **documentation-only** — no compiler changes until **`plan-approved`** on #27 and implementation issues (#463, #11, …) are staffed.

## Non-goals

- Weakening `threshold_ratio_cpp` in **benchmarks** to green incomplete kernels.
- Claiming **G-math Done** from narrative edits without harness evidence.
- `trusted.lean` edits (human-approved issues only).
- Full **P-linalg** float Props or MIR↔Lean codegen preservation (tracked under **#32**, **G-trust**).

## Dependencies

| ID | Role |
|----|------|
| **PH-7e** | Math → SIMD MIR (`ArrayDotF64`, `ArrayMatMul2DF64`, `ArrayMatMulBlocked2DF64`) |
| **PH-2i** | Shape-checked `A @ B` surface (#20 for full matrix `@` lowering plan) |
| **PH-5b** | Tier-1 cross-lang harness + dashboard ingest |
| **PH-2f** | FMA / `fp_numerically_stable` policy (`horner_pure_li`) |
| [#463](https://github.com/li-langverse/lic/issues/463) | Tier-1 red-row closure (implementation, post-`plan-approved`) |
| [#32](https://github.com/li-langverse/lic/issues/32) | Lean/VC + matmul deferral register sync |

## Done criteria checklist

Status legend: **Done** · **Partial** · **Deferred** (superseding track)

### Slice 7e-a/d — 1d `@` / dot (SIMD gather)

| # | Gate | Harness / test | Status |
|---|------|----------------|--------|
| A1 | `a @ b` on `array[N, float]` lowers to `MirOp::ArrayDotF64` | `compiler/codegen/emit.cpp`; `sum_dot_product_equiv_gap.sh` | **Done** |
| A2 | 4-wide gather + horizontal sum (no wide vector load segfault) | `docs/release-notes/2026-05-21-7ed-simd-dot-codegen.md` | **Done** |
| A3 | Tier-1 `simd_dot` pure-Li math source (`a @ b`, no `__li_simd_*`) | `benchmarks/tier1_micro/simd_dot/li/main.li`, `bench.py --tier 1` | **Done** |
| A4 | `simd_dot` ≤1.2× C++ on ingest CSV | `scripts/check-tier1-li-vs-cpp.sh`, `li-tests/tooling/tier1_li_vs_cpp.sh` | **Done** (advisory + strict) |

### Slice 7e-b — 2D naive GEMM (`ArrayMatMul2DF64`)

| # | Gate | Harness / test | Status |
|---|------|----------------|--------|
| B1 | `C = A @ B` on nested `array[M, array[K, float]]` operands | `li-tests/math_linalg/matmul_*.li`, `mat2_at2_codegen_probe.li` | **Done** |
| B2 | IKJ accumulation + LLVM `fmuladd` (`-ffp-contract=fast`) | `matmul_loop_codegen_witness_gap.sh`, `emit_matmul2d_ijk_*` | **Done** |
| B3 | Large M×N×K loop codegen (no compile OOM; unroll cap) | `matmul_25x25_at_codegen.li` (n>24 unroll threshold) | **Done** |
| B4 | Tier-1 `matmul_naive` pure-Li hot path uses `@` | `benchmarks/tier1_micro/matmul_naive/li/main.li` | **Done** |
| B5 | `matmul_naive` ≤1.2× C++ on dashboard ingest | `check-tier1-li-vs-cpp.sh` (`LI_TIER1_PERF_STRICT=1`) | **Partial** — superseding **#463** sub-phase C, **PH-5b** |

### Slice 7e-b — Blocked GEMM (`ArrayMatMulBlocked2DF64`)

| # | Gate | Harness / test | Status |
|---|------|----------------|--------|
| C1 | 512³ `@` routes to `MirOp::ArrayMatMulBlocked2DF64` (BK=64) | `compiler/mir/lower.cpp`, `emit_matmul2d_blocked_ijk` | **Done** |
| C2 | Tier-1 `matmul_blocked` pure-Li `C = A @ B` (no stub proc) | `benchmarks/tier1_micro/matmul_blocked/li/main.li` | **Done** |
| C3 | Blocked IKJ matches C oracle structure (BK=64 tiles) | `common/matmul_blocked_core.c` parity; [matmul-blocked-7e study](../numerics/studies/2026-05-30-matmul-blocked-7e.md) | **Done** (correctness) |
| C4 | `matmul_blocked` ≤1.2× C++ on dashboard ingest | `check-tier1-li-vs-cpp.sh`, `bench.py --tier 1 --only matmul_blocked` | **Partial** (~1.26× local; target ≤1.2×) — superseding **#463** sub-phase B |
| C5 | Explicit SIMD micro-kernel in blocked inner `j` (beyond scalar+FMA autovec) | `emit_matmul2d_blocked_ijk` vec4 path | **Deferred** — bundle with **#463** B or **PH-7e-e** when C4 red |

### Slice 7e-e — Element-wise SIMD (`ArrayBinOpF64`)

| # | Gate | Harness / test | Status |
|---|------|----------------|--------|
| D1 | Element-wise `+ - * /` on `array[N, float]` uses gather/scatter SIMD | `docs/release-notes/2026-05-21-7ee-array-binop-simd.md` | **Done** |
| D2 | `@vectorized` scope enables SIMD inside `for` body | `vectorized_for_scope_ok.li`, `ArraySimdScope` | **Done** (7d-c partial) |

### Explicit deferrals (not blocking 7e matmul slice closure)

| Item | Rationale | Superseding |
|------|-----------|-------------|
| `horner_pure_li` FMA / 88× vs C++ | Horner is **FMA policy** + DCE, not matmul codegen | **#11**, **#9**, **#463** F, **PH-2f** |
| Lean `mat2_at2_eval` ≡ MIR `ArrayMatMul2DF64` | Semantic closed; codegen preservation lemma open | **#32**, **G-trust**, `mat2_at2_mir_codegen_lean_gap.sh` |
| Full float **P-linalg** Props for matmul | Loop witness open; int corpus closed | **#32**, **2f**, `discharge_linalg_int_lean.sh` |
| General M×N×K `@` shape / broadcast rules | Type surface (**2i**), not codegen | **#20** |
| OpenMP outer parallel on matmul tiles | **G-par** disjoint proofs open | **#15**, **7d-c** |

## Master-plan flip rule

**Phase 7e** tracker `- [ ]` may flip to `- [x]` when **all** of:

1. Slices **7e-a/d** and **7e-b** rows **B1–B4**, **C1–C3**, **D1–D2** remain **Done** (regression suite green).
2. **Either** tier-1 **B5 + C4** are green on latest dashboard ingest **or** master-plan records an approved advisory waiver (human-only; never catalog threshold tweak).
3. Deferred rows above are linked in `provability-gaps.md` and this plan — not silently dropped.

Until B5/C4 green, Phase 7e stays **partial** with honest “open: `matmul_blocked` perf” wording (not “SIMD matmul deferred” without naming `ArrayMatMulBlocked2DF64`).

## Tests / benches (canonical names)

| Kind | Path |
|------|------|
| Compile / shape | `./li-tests/run_all.sh math_linalg` |
| MIR witness gaps | `li-tests/tooling/matmul_loop_codegen_witness_gap.sh`, `mat2_at2_mir_codegen_lean_gap.sh`, `sum_dot_product_equiv_gap.sh` |
| Tier-1 perf reporter | `scripts/check-tier1-li-vs-cpp.sh` (benches: `simd_dot`, `matmul_naive`, `matmul_blocked`, `horner_pure_li`) |
| Harness | `benchmarks/harness/bench.py --tier 1` |
| P-linalg int corpus | `li-tests/tooling/discharge_linalg_int_lean.sh` |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-math** | Partial (honest) | 1d SIMD dot + 2D/blocked GEMM **correctness** closed; tier-1 **matmul_blocked** perf open |
| **G-lean** | Partial | `mat2_at2_eval` semantic closed; MIR preservation deferred (**#32**) |
| **G-meta** | Missing | No codegen preservation lemma for matmul |

## Rollout

1. This PR — plan + tracker + `provability-gaps.md` sync (**#27**).
2. Maintainer adds **`plan-approved`** on #27.
3. Implementation — **#463** sub-phases B/C for B5/C4; **#11** / **#9** for Horner (out of matmul scope).
4. On B5+C4 green — flip Phase 7e checkbox + tighten G-math closed-slice bullets in same PR as bench ingest.

## Human-only

- [ ] Label **`plan-approved`** on #27 before codegen agents implement B5/C4.
- [ ] Approve rare perf waiver via master-plan edit (not `threshold_ratio_cpp` tweak).
