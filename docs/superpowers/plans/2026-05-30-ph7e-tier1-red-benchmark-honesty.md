# PH-7e tier-1 red benchmark closure (G-math honesty)

> **Issue:** [#463](https://github.com/li-langverse/lic/issues/463) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-math claims), **Fast** (tier-1 ≤1.2× C++ advisory)  
> **Learned from:** [master plan §7e](2026-05-14-li-master-plan.md), [math-linalg surface](2026-05-16-li-math-linalg-surface.md), [provability-gaps.md](../../verification/provability-gaps.md), [proof_gap cycle 18 Horner FMA](https://github.com/li-langverse/benchmarks/blob/main/data/digest/proof_gap_researcher-2026-05-30-horner-fma-literal-drift.md)

## Goal

Close the gap between **master-plan / G-math “closed slice” wording** and **dashboard-measured tier-1 ratios** for six red rows. Deliver compiler/harness improvements in **lic** (never weaken `threshold_ratio_cpp` in **benchmarks**), refresh ingest evidence, and update provability docs only when benches are green or explicitly waived with PH-track rationale.

## Non-goals

- Lowering `threshold_ratio_cpp` or catalog thresholds to green incomplete kernels (**benchmarks** honesty violation).
- Copying harness into **benchmarks** (ingest-only per ecosystem-first).
- Claiming **G-math** Done from documentation edits without measured ratios.
- Editing `trusted.lean` (human-approved issues only).

## Dependencies

- **PH-7e**, **PH-5b** — SIMD/parallel lowering, loop matmul, FMA Horner paths.
- **PH-2f** — float codegen / `fp_numerically_stable` policy (Horner FMA drift — see cycle 18 digest).
- **benchmarks** [#179](https://github.com/li-langverse/benchmarks/issues/179) — catalog path honesty (parallel track).
- Orchestration: `bench_improver`, `numerics_researcher`, `proof_gap_researcher` (G-meta FMA gates).

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Inventory** — red row → harness path → codegen knob (IKJ, FMA, OpenMP, ML graph) | Table in issue #463 |
| B | **matmul_blocked** (1.55×) — blocked IKJ + SIMD scope; study [matmul-blocked-7e](../../numerics/studies/2026-05-30-matmul-blocked-7e.md) | `ratio_vs_cpp` ≤1.2 on advisory run |
| C | **matmul_naive** (1.33×) — align with `ArrayMatMul2DF64` + `fp_numerically_stable` policy | Green on dashboard ingest |
| D | **ML trio** (`ml_conv2d_forward`, `ml_mlp_*`) — pure-Li lowering or honest `status=planned` in catalog until kernels land | Green or catalog `planned` + lic issue |
| E | **num_gmres** (1.4×) — Krylov micro-kernel / dot-heavy inner loops (PH-5b numerics) | Green or documented blocker in G-math |
| F | **G-math doc sync** — `provability-gaps.md` closed-slice bullets match `check-tier1-li-vs-cpp.sh` + dashboard | No “≤1.2×” claim for red ids |
| G | **Sub-plan gate** — checkbox in `2026-05-16-li-math-linalg-surface.md` only after F | Maintainer ack |

## Tests / benches

| Bench id | Tier | Harness |
|----------|------|---------|
| `matmul_blocked`, `matmul_naive` | 1 | `benchmarks/harness/bench.py --tier 1` |
| `ml_conv2d_forward`, `ml_mlp_forward`, `ml_mlp_train_step` | 1 | same |
| `num_gmres` | 1 | same |
| `horner_pure_li` | 1 | proof_gap cycle 18 — FMA policy before claiming green |

- `./scripts/check-tier1-li-vs-cpp.sh` (advisory default; strict with `LI_TIER1_PERF_STRICT=1`).
- **li-tests:** `math_linalg/*`, `horner_fma_literal_lean_drift.sh` after G-meta gates land.

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-math** | Partial → honest Partial | Retract “closed slice” for ids still red on dashboard |
| **G-meta** | Partial | Gate `FmaFloatF64` / `HornerFmaUnroll` on `fp_numerically_stable` (cycle 18) before tier-1 Horner green |
| **G-hw** | Partial | FMA ≠ mul+add eval documented; no new axioms |

## Rollout

1. **lic** implementation PR(s) per sub-phase B–E (after **`plan-approved`** on #463).
2. Run full tier-1 bench + ingest on **benchmarks** (`./scripts/run-full-benchmark-suite.sh` or nightly).
3. **benchmarks** PR: dashboard only — no threshold weakening.
4. Close #463 when six rows green or waived with master-plan amendment.

## Human-only

- [ ] Label **`plan-approved`** on #463 before codegen agents run.
- [ ] Approve any **advisory waiver** (rare) via master-plan edit, not silent catalog tweak.
- [ ] Merge **proof_gap** FMA policy PR before re-claiming `horner_pure_li` in G-math closed slice.
