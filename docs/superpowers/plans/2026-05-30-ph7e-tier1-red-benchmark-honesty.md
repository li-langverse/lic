# PH-7e tier-1 red benchmark closure (G-math honesty)

> **Issues:** [#463](https://github.com/li-langverse/lic/issues/463) · [#424](https://github.com/li-langverse/lic/issues/424) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-math claims), **Fast** (tier-1 ≤1.2× C++ advisory)  
> **Learned from:** [master plan §7e](2026-05-14-li-master-plan.md), [math-linalg surface](2026-05-16-li-math-linalg-surface.md), [provability-gaps.md](../../verification/provability-gaps.md), [matmul-blocked study](../../numerics/studies/2026-05-30-matmul-blocked-7e.md), [proof_gap cycle 18 Horner FMA](https://github.com/li-langverse/benchmarks/blob/main/data/digest/proof_gap_researcher-2026-05-30-horner-fma-literal-drift.md)

**north_star_fit:** scientific computing / HPC — **PH-7e**, **PH-5b**, **G-math** (proof-before-perf; no threshold weakening)

**Duplicate tracker:** #424 and #463 share the same six-row audit; close #424 when sub-phase F lands on `main`.

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

## PH / REQ / G-* map

| ID | Role in this plan |
|----|-------------------|
| **PH-7e** | Math → SIMD/parallel lowering; tier-1 Li sources math-only |
| **PH-5b** | Benchmarks & simulations harness; cross-lang oracle parity |
| **PH-2f** | Float codegen / `fp_numerically_stable` (Horner FMA policy) |
| **G-math** | Retract overstated tier-1 closed-slice claims until dashboard green |
| **G-meta** | Gate `FmaFloatF64` / `HornerFmaUnroll` on numerics-stable policy |
| **REQ-tier1-advisory** | `threshold_ratio_cpp` = 1.2 advisory; strict via `LI_TIER1_PERF_STRICT=1` |

## PH-7e Done criteria (per row class)

PH-7e tracker stays **partial** until every dashboard-red tier-1 id is either green (≤1.2× C++ on ingest) or listed in a documented deferral with PH-track owner. Do **not** mark Phase 7e `[x]` in the master plan until the red set ⊆ deferrals.

| Row class | Examples | Done criteria | Owner |
|-----------|----------|---------------|-------|
| **Pure-Li math loop** | `matmul_naive`, `matmul_blocked`, `horner_pure_li`, `simd_dot` | Li driver uses math-only sources (`li_pure=True`); `ratio_vs_cpp` ≤1.2 on **benchmarks** dashboard ingest; `./scripts/check-tier1-li-vs-cpp.sh` green in advisory mode (or master-plan waiver) | `bench_improver` |
| **Pure-Li numerics (Krylov)** | `num_gmres` | Pure-Li Krylov inner loops or honest `extern` deferral documented in G-math; ≤1.2× when pure-Li column is claimed | `numerics_researcher` |
| **ML micro-kernels** | `ml_conv2d_forward`, `ml_mlp_forward`, `ml_mlp_train_step` | Real conv/ML lowering on pure-Li path **or** catalog `status=planned` + linked lic issue — no smoke stub claiming green | `numerics_researcher` |
| **Shared-C / extern oracle** | `reduce_sum` (reference column) | Out of PH-7e scope when `li_pure=False`; Li column must not inherit C++ timing | harness policy |

**Evidence sources (precedence):**

1. **benchmarks** dashboard ingest (`ecosystem-audit.json` → `benchmarks.red`) — normative for org tracker.
2. Local `benchmarks/results/latest.csv` + `check-tier1-li-vs-cpp.sh` — advisory; may lead ingest after bench PR merges.
3. Documented deferral — master-plan amendment + G-math row update (human-approved waiver only).

## Sub-phases

### A — Red-row inventory (audit 2026-05-29T23:51Z)

| Bench id | Ratio vs C++ | PH ids | Harness / codegen knob | Owner agent |
|----------|--------------|--------|------------------------|-------------|
| `matmul_blocked` | 1.549× | PH-5b, PH-7e | `ArrayMatMulBlocked2DF64` BK=64 IKJ tiles; [study](../../numerics/studies/2026-05-30-matmul-blocked-7e.md) | `bench_improver` |
| `matmul_naive` | 1.333× | PH-5b, PH-7e | `ArrayMatMul2DF64` loop `@` lowering; OpenMP outer | `bench_improver` |
| `ml_conv2d_forward` | 1.333× | PH-5b | pure-Li conv graph lowering / extern honesty | `numerics_researcher` |
| `ml_mlp_forward` | 1.333× | PH-5b | MLP forward kernel + SIMD inner | `numerics_researcher` |
| `ml_mlp_train_step` | 1.333× | PH-5b | backward + optimizer micro-kernels | `numerics_researcher` |
| `num_gmres` | 1.4× | PH-5b | Krylov dot-heavy inner loops (PH-5b numerics) | `numerics_researcher` |

**Honesty note:** `horner_pure_li` was cited in G-math closed slice but is **not** in the six-row red set; keep G-meta FMA policy gate before re-claiming green. Local benches may disagree with stale ingest — dashboard wins for tracker until refresh.

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Inventory** — table above on #463/#424 | Maintainer ack |
| B | **matmul_blocked** (1.55×) — blocked IKJ + SIMD scope; study [matmul-blocked-7e](../../numerics/studies/2026-05-30-matmul-blocked-7e.md) | `ratio_vs_cpp` ≤1.2 on advisory run |
| C | **matmul_naive** (1.33×) — align with `ArrayMatMul2DF64` + `fp_numerically_stable` policy | Green on dashboard ingest |
| D | **ML trio** (`ml_conv2d_forward`, `ml_mlp_*`) — pure-Li lowering or honest `status=planned` in catalog until kernels land | Green or catalog `planned` + lic issue |
| E | **num_gmres** (1.4×) — Krylov micro-kernel / dot-heavy inner loops (PH-5b numerics) | Green or documented blocker in G-math |
| F | **G-math doc sync** — `provability-gaps.md` + master plan §7e match dashboard; retract false tier-1 closed-slice claims | No “≤1.2×” claim for red ids |
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
| **G-math** | Partial → honest Partial | Retract “closed slice (tier-1)” for ids still red on dashboard |
| **G-meta** | Partial | Gate `FmaFloatF64` / `HornerFmaUnroll` on `fp_numerically_stable` (cycle 18) before tier-1 Horner green |
| **G-hw** | Partial | FMA ≠ mul+add eval documented; no new axioms |

## Rollout

1. **lic** doc PR (sub-phase F) — reconcile master plan + G-math ([#424](https://github.com/li-langverse/lic/issues/424)).
2. **lic** implementation PR(s) per sub-phase B–E (after **`plan-approved`** on #463).
3. Run full tier-1 bench + ingest on **benchmarks** (`./scripts/run-full-benchmark-suite.sh` or nightly).
4. **benchmarks** PR: dashboard only — no threshold weakening.
5. Close #463 / #424 when six rows green or waived with master-plan amendment.

## Human-only

- [x] Label **`plan-approved`** on #463 (2026-06-07).
- [ ] Approve any **advisory waiver** (rare) via master-plan edit, not silent catalog tweak.
- [ ] Merge **proof_gap** FMA policy PR before re-claiming `horner_pure_li` in G-math closed slice.
