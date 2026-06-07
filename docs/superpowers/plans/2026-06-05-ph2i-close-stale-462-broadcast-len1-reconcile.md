# PH-2i: close stale #462 — broadcast_len1 compile slice reconcile (G-math)

> **Issue:** [#618](https://github.com/li-langverse/lic/issues/618) · **Supersedes:** [#462](https://github.com/li-langverse/lic/issues/462)  
> **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-math register), **Easy** (math/linalg surface docs match tests)  
> **Learned from:** [2026-05-22-2i-broadcast-len1 release notes](../../release-notes/2026-05-22-2i-broadcast-len1.md), [math-linalg surface plan](2026-05-16-li-math-linalg-surface.md), [master plan §2i](2026-05-14-li-master-plan.md), [provability-gaps.md](../../verification/provability-gaps.md)

## Goal

Reconcile tracker and gap-register drift after the **length-1 broadcast compile slice** landed (`broadcast_len1_add_float4.li`, `broadcast_len1_mul_int4.li`, `broadcast_len1_pow_int4.li`, `broadcast_invalid_len2_vs_len4.li`). Close stale **#462** (which claimed zero `math_linalg/` broadcast tests), update **G-math** to cite compile-only evidence, and keep **PH-2i** honestly **partial** until Lean witness and full NumPy-rank broadcast land on `main`.

## Status refresh (2026-06-07)

| Tracker | Issue state | `main` reality |
|---------|-------------|----------------|
| **#462** (stale “no tests”) | Open | Superseded — `broadcast_len1_*` on `main`; close in sub-phase **D** |
| **#574** (Lean witness) | Closed (`already_implemented`) | **PR [#900](https://github.com/li-langverse/lic/pull/900) still open** (`merge-approved`, CI green) — `Discharge.lean` has no `broadcast_len1` on `main`; gap script still enforces absence |
| **#526** (NumPy-rank defer) | Closed (`already_implemented`) | **PR [#909](https://github.com/li-langverse/lic/pull/909) still open** — reject gate + `compile_fail` seeds not on `main` yet |
| **#618** (this plan) | Open, `has-plan`, `plan-approved-requested` | Draft plan PR **#866**; docs implementation blocked until **`plan-approved`** |
| **G-math register** | `provability-gaps.md` Last updated **2026-05-30** | Summary + gap-register rows still omit `broadcast_len1_*` compile slice — sub-phase **B** |

## Non-goals

- Implementing general NumPy-style rank broadcast (tracked on **#526**).
- Adding Lean `Discharge.lean` broadcast semantics or VC witnesses (**#574** — human/proof_gap lane).
- Weakening tier-1 benchmark thresholds or claiming **G-math** Done from docs alone.
- Editing `trusted.lean` (human-approved issues only).
- Compiler/MIR/codegen changes (already on `main` per [2026-05-22 release notes](../../release-notes/2026-05-22-2i-broadcast-len1.md)).

## Dependencies

| ID | Role |
|----|------|
| **PH-2i**, **PH-2i-b** | Math/linalg surface — length-1 broadcast compile slice |
| **G-math** | Gap register row to update |
| **#574** / **PR #900** | Lean witness for broadcast_len1 MIR (issue closed; merge pending — blocks `verify_ok` promotion on `main`) |
| **#526** / **PR #909** | NumPy-rank reject gate + `compile_fail` seeds (issue closed; merge pending — blocks full **2i** checkbox) |
| **#472** | P-linalg loop ≡ ensures sub-plan (parallel **G-lean** track) |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Evidence audit** — confirm tests + manifest + gap script | `./li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` PASS; `rg broadcast_len1 li-tests/math_linalg/` ≥3 files |
| **B** | **G-math doc sync** — cite `broadcast_len1_*` as **closed compile slice**; note Lean gap explicitly | `provability-gaps.md` summary + gap-register rows updated; **Last updated** bumped |
| **C** | **Master plan honesty** — **2i** row stays partial; link compile slice + open Lean/NumPy items | `2026-05-14-li-master-plan.md` Phase 2i bullet cites tests + `#574` / `#526` |
| **D** | **Issue hygiene** — close **#462** as superseded | Comment on #462 → link #618 + plan; label `duplicate` or close with reason |
| **E** | **Downstream tracker honesty** — note #574/#526 closed vs open PRs | Comment on #618 linking #900/#909; do **not** claim Lean/NumPy-rank done until those PRs merge |

## Tests / benches

| Path | Outcome | Role |
|------|---------|------|
| `li-tests/math_linalg/broadcast_len1_add_float4.li` | `compile_ok` | float add broadcast |
| `li-tests/math_linalg/broadcast_len1_mul_int4.li` | `compile_ok` | int mul broadcast |
| `li-tests/math_linalg/broadcast_len1_pow_int4.li` | `compile_ok` | int `**` broadcast |
| `li-tests/math_linalg/broadcast_invalid_len2_vs_len4.li` | `compile_fail` | non-broadcast length mismatch |
| `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` | CI PASS | documents MIR-without-Lean boundary |

**Run:** `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh math_linalg` and `./li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`.

No tier-1 bench ids — length-1 broadcast is compile-surface only (scalar loops; SIMD tiles deferred).

## Provability

| Gap | Move | Honest limit |
|-----|------|--------------|
| **G-math** | Partial → **Partial** (richer closed-slice bullet) | Add **closed compile slice:** length-1 element-wise broadcast (`broadcast_len1_*`, `compile_ok` only). **Still open on `main`:** Lean broadcast semantics (PR #900), NumPy-rank reject gate (PR #909), tier-1 red rows (#463) |
| **G-lean** | No change until PR #900 merges | `broadcast_len1_codegen_lean_gap.sh` still enforces no `Discharge.lean` broadcast |
| **G-math-syn** | No change | Syntax surface unchanged |

Do **not** promote manifest entries to `verify_ok` until **PR #900** merges to `main`.

## Rollout

1. Merge this plan PR (draft → ready for review).
2. Maintainer adds **`plan-approved`** on **#618**.
3. **Implementation PR** (docs-only): sub-phases A–D in one PR; no product code unless audit finds drift.
4. Close **#618** when A–D exit gates pass; track Lean (#900) and NumPy-rank (#909) merges separately.
5. Optional release note stub: `docs/release-notes/2026-06-05-ph2i-462-reconcile.md` (tracker-only).

## Human-only

- [ ] Label **`plan-approved`** on **#618** before docs implementation agents run.
- [ ] Acknowledge close of **#462** (stale “no tests” claim).
- [ ] Merge **PR #900** (Lean witness, `merge-approved`) and **PR #909** (NumPy-rank gate) before promoting PH-2i checkbox to done.

## north_star_fit

**Domain:** scientific computing / linalg surface · **PH:** 2i, 2i-b · **Pillar:** Provability first — compile evidence registered honestly; Lean witness deferred, not hidden.
