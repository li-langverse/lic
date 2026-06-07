# Doc-a: G-math summary table alignment (PH-2i, PH-7e)

> **Issue:** [#49](https://github.com/li-langverse/lic/issues/49) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first — honesty register must match partial compiler evidence before any perf claims  
> **North star fit:** scientific_computing, hpc — **PH-2i**, **PH-7e**, **G-math**, **Doc-a**  
> **Learned from:** [master plan §2i/7e](2026-05-14-li-master-plan.md), [math-linalg surface](2026-05-16-li-math-linalg-surface.md), [provability-gaps.md](../../verification/provability-gaps.md), [PH-7e tier-1 honesty plan](2026-05-30-ph7e-tier1-red-benchmark-honesty.md)

## Goal

Eliminate **Doc-a** drift in `docs/verification/provability-gaps.md`: the **Summary (read this first)** row for **Math / linalg surface** must agree with the **G-math** gap-register row and the master-plan **Partial** tracker rows for **Phase 2i** and **Phase 7e**. Plan-verifier pass 2026-05-18 blocked Doc-a while the executive summary overclaimed **Not started**.

## Problem (evidence)

| Source | Expected | Drift (issue filing) |
|--------|----------|----------------------|
| Summary table L25 | **Partial** — pointer to **G-math** + PH-2i/7e | Was **Not started** |
| G-math register L44 / gap table L90 | **Partial** — closed slices (1d `@`, P-linalg, tier-1 advisory) | Already **Partial** |
| Master plan tracker ~L447–458 | **Partial** for 2i / 7e | Already **Partial** |

**Pre-flight (main @ 2026-06-07):** summary status is already **Partial**; remaining work is **anchor link**, **wording parity** with G-math closed-slice bullets, and **Last updated** bump in the same docs PR.

## Non-goals

- Compiler or MIR changes (no PH-2i/7e codegen in this issue).
- Marking **G-math** **Done** — partial evidence only.
- Weakening tier-1 `threshold_ratio_cpp` in **benchmarks** (see [#463](https://github.com/li-langverse/lic/issues/463)).
- Editing `trusted.lean` or proof-db TOML rows.
- Self-merging governance or master-plan tracker edits beyond Doc-a scope.

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-2i** | Math surface types — shape tests, P-linalg closed VCs |
| **PH-7e** | Math → SIMD MIR — pure-Li tier-1 lowering (advisory perf bar) |
| **G-math** | Canonical gap row — source of truth for summary wording |
| **Doc-a** | Gap register honesty — summary must not under- or over-claim vs register |
| **#463** | Separate track for red tier-1 ratios; do not copy “≤1.2×” into summary unless bench-green |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Audit** — diff summary L25 vs G-math still-open + gap-register rows | No status mismatch (Partial = Partial) |
| B | **Summary edit** — status **Partial**; one-line pointer: `[G-math](#g-math)` + master plan [2i/7e partial rows](../superpowers/plans/2026-05-14-li-master-plan.md) | Cell cites gap ID explicitly |
| C | **Date** — bump `**Last updated:**` on `provability-gaps.md` | Matches PR merge date |
| D | **Verifier** — re-run plan-verifier Doc-a checklist; `./scripts/check-doc-provability-claims.sh` | Green in CI |
| E | **Cross-links** — confirm [plan-cross-links](../../ecosystem/plan-cross-links.md) open PH tracker still lists 2i/7e as partial | No new drift |

## Tests / verification (docs-only)

| Check | Command / artifact |
|-------|-------------------|
| Linalg compile corpus | `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh math_linalg` |
| P-linalg Lean discharge | `./li-tests/tooling/discharge_linalg_int_lean.sh` |
| Closed contract specimens | `li-tests/contracts_verify/linalg_*_closed.li` |
| Tier-1 advisory (reference only) | `./scripts/check-tier1-li-vs-cpp.sh` — cite gaps, do not green-wash red rows |
| Doc claim guard | `./scripts/check-doc-provability-claims.sh` |

Evidence paths (unchanged by this plan): `compiler/mir/lower.cpp` (`ArrayDotF64`), `compiler/codegen/emit.cpp`, `li-tests/math_linalg/array_dot_matmul.li`.

## Provability mapping

| Gap / phase | Move | Notes |
|-------------|------|-------|
| **G-math** | Stay **Partial** | Summary mirrors register; closed slices listed in still-open table only |
| **PH-2i** | Stay **Partial** | Shape + P-linalg VCs — not full broadcast / float Props |
| **PH-7e** | Stay **Partial** | Loop matmul + FMA horner advisory; strict tier-1 rows open ([#463](https://github.com/li-langverse/lic/issues/463)) |
| **Doc-a** | **Partial → aligned** | Summary no longer blocks plan-verifier |

## Rollout

1. Merge this **plan** PR; human adds label **`plan-approved`** on #49.
2. Follow-on **implementation PR** (docs only): edit `provability-gaps.md` per sub-phases A–E; PR description must mention **G-math** (Doc PR rule).
3. Close #49 when Doc-a verifier marks aligned; keep #463 open for perf closure.

## Human-only

- [ ] Label **`plan-approved`** on #49 before docs implementer runs.
- [ ] Remove **`plan-needed`** after plan merge.
- [ ] Acknowledge any advisory tier-1 waiver via master plan, not summary table alone.
