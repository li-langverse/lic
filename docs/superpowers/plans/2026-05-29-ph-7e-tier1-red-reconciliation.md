# PH-7e: Tier-1 red row reconciliation (plan honesty)

> **Issue:** [#424](https://github.com/li-langverse/lic/issues/424) · **Repo:** li-langverse/lic  
> **Vision:** provable (honest G-math register), blazingly-fast (≤1.2× C++ tier-1 policy) · **Learned from:** [provability-gaps.md](../../verification/provability-gaps.md) G-math, [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) PH-7e row, `scripts/check-tier1-li-vs-cpp.sh`, ecosystem audit `benchmarks.red` (2026-05-29)

## Goal

Define **PH-7e Done criteria per row class** and reconcile master plan + **G-math** register with the live dashboard red set — so agents and humans do not overclaim “tier-1 closed” while six rows remain >1.2× C++ (`matmul_blocked`, `matmul_naive`, ML kernels, `num_gmres`).

## Non-goals

- Weakening `threshold_ratio_cpp` or catalog thresholds to green-wash reds
- Implementing all kernel fixes in this plan ( **`bench_improver`** / **`numerics_researcher`** own implementation)
- Closing **G-math** to Done (requires full float Lean Props + green tier-1 set)

## Dependencies

- **PH-7e**, **PH-5b**
- **benchmarks** `ecosystem-audit.json` + ingest pipeline (`LIC_ROOT`)
- Active work: branch `chore/agent-bench_improver-matmul-naive-at-2026-05-29`
- Handoff: **proof_gap_researcher** / provability_holes goal — P-linalg float `@` Props

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **7e-hon-1** | Row taxonomy doc: pure-Li loop / blocked / extern / ML / iterative solver | Table in this plan + master plan cross-link |
| **7e-hon-2** | Per-row Done gate (codegen path, bench env, strict vs advisory) | Each red id maps to PH slice or documented deferral |
| **7e-hon-3** | Reconcile `provability-gaps.md` G-math “closed slice” wording vs dashboard | No claim `matmul_naive` ≤1.2× if audit red |
| **7e-hon-4** | Tracker flip rule | PH-7e `[x]` only when red ⊆ deferrals + strict gate green |

## Row taxonomy (v1)

| Catalog id | Class | Current ratio (2026-05-29) | Done gate |
|------------|-------|----------------------------|-----------|
| `matmul_naive` | pure-Li loop IKJ | 1.33× | Loop codegen + FMA; ≤1.2× on reference HW; `check-tier1-li-vs-cpp.sh` |
| `matmul_blocked` | pure-Li blocked | 1.55× | Block size + SIMD tile; same strict script |
| `ml_conv2d_forward` | ML forward | 1.33× | 7e lowering + `@` path; tier-1 advisory |
| `ml_mlp_forward` | ML forward | 1.33× | same |
| `ml_mlp_train_step` | ML train | 1.33× | same |
| `num_gmres` | iterative solver | 1.4× | 2i linalg + 7e dot/matvec; PH-5b numerics |

**Deferrals** (documented, not silent): rows may stay yellow/red with explicit master-plan bullet until PH slice lands — never hidden by threshold tweak.

## Tests / benches

- `scripts/check-tier1-li-vs-cpp.sh` (default advisory; `LI_TIER1_PERF_STRICT=1` for CI promotion)
- Tier-1 ids above via `benchmarks/harness/bench.py --tier 1`
- **benchmarks** nightly ingest → `ecosystem-audit.json` `benchmarks.red`
- li-tests: `math_linalg/`, existing P-linalg corpus (#151)

## Provability

| G-* | Movement |
|-----|----------|
| **G-math** | Partial — tighten prose only; remove stale “closed slice” claims for rows that audit marks red |
| **G-lean** | Partial unchanged (P-linalg float `@` open) |
| Honest limit | PH-7e tracker stays **partial** until dashboard red set matches documented deferrals |

## Rollout

1. PR: update G-math register + master plan PH-7e bullet (honesty pass)
2. Parallel: `bench_improver` PRs per row (no threshold weakening)
3. When a row flips green on nightly ingest, update row table + deferral list in same PR
4. **proof_gap_researcher** handoff: cite `north_star_fit` PH-7e + G-math for float matmul Props
