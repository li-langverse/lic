# PH-2i-b: length-1 broadcast math_linalg compile slice (G-math)

> **Issue:** [#462](https://github.com/li-langverse/lic/issues/462) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-math register), **Easy** (math/linalg surface matches shipped tests)  
> **Learned from:** [2026-05-22-2i-broadcast-len1 release notes](../../release-notes/2026-05-22-2i-broadcast-len1.md), [math-linalg surface plan](2026-05-16-li-math-linalg-surface.md), [master plan §2i](2026-05-14-li-master-plan.md), [provability-gaps.md](../../verification/provability-gaps.md)  
> **Related:** [#618](https://github.com/li-langverse/lic/issues/618) tracker reconcile · [PR #866](https://github.com/li-langverse/lic/pull/866) sibling plan

## Goal

Close **#462** honestly: the original gap (“no `li-tests/math_linalg/` broadcast tests”) is **already fixed on `main`**. This plan registers compile evidence, documents deferred NumPy-rank broadcast, and hands off tracker / G-math doc sync to a docs-only implementation PR after **`plan-approved`**.

## Status refresh (2026-06-07)

| #462 acceptance criterion | State on `main` | Evidence |
|---------------------------|-----------------|----------|
| `li-tests/math_linalg/` `compile_ok` for length-1 broadcast element-wise ops | **Done** | `broadcast_len1_add_float4.li`, `broadcast_len1_mul_int4.li`, `broadcast_len1_pow_int4.li` (`manifest.toml` ~1021–1032) |
| Reject full NumPy-rank broadcast (document deferred) | **Partial** — `broadcast_invalid_len2_vs_len4.li` rejects non-len1 mismatch; general rank rules tracked on **#526** / **PR #909** | `compile_fail` + `expected_substr = "length-1 broadcast"` |
| Update tracker row + `provability-gaps.md` **G-math** closed slice | **Open** — docs-only sub-phase **C** | Master plan line 447 still lists length-1 broadcast as open |

**Compiler slice (2026-05-22):** typecheck + MIR (`array_broadcast_*_len1`) + LLVM emit landed per [release notes](../../release-notes/2026-05-22-2i-broadcast-len1.md). **Lean witness** remains open on `main` (`broadcast_len1_codegen_lean_gap.sh`); **#574** closed with **PR #900** pending merge.

## Non-goals

- Re-implementing length-1 broadcast codegen (already on `main`).
- General NumPy-style rank broadcast (**#526** — defer gate + `compile_fail` seeds).
- Lean `Discharge.lean` broadcast semantics (**#574** / **PR #900** — proof_gap lane).
- Promoting manifest entries from `compile_ok` → `verify_ok` before Lean witness merges.
- Weakening tier-1 benchmark thresholds or editing `trusted.lean`.

## Dependencies

| ID | Role |
|----|------|
| **PH-2i**, **PH-2i-b** | Math/linalg surface — length-1 broadcast compile slice |
| **G-math** | Gap register row to update in sub-phase **C** |
| **#618** / **PR #866** | Sibling tracker-reconcile plan (sub-phases B–D overlap; coordinate to avoid duplicate doc PRs) |
| **#526** / **PR #909** | NumPy-rank reject gate (blocks full **2i** checkbox) |
| **#574** / **PR #900** | Lean witness (blocks `verify_ok` promotion) |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Evidence audit** — confirm #462 acceptance slice on `main` | `rg broadcast_len1 li-tests/math_linalg/` ≥3 files; `./li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` PASS |
| **B** | **NumPy-rank defer doc** — cross-link **#526** / **PR #909** in master plan + G-math; no rank-broadcast implementation here | Plan + issue comments cite defer; no `compile_ok` for rank broadcast |
| **C** | **G-math + master plan sync** — cite `broadcast_len1_*` as **closed compile slice**; keep **PH-2i** partial until Lean + NumPy-rank merge | `provability-gaps.md` + `2026-05-14-li-master-plan.md:447` updated; **Last updated** bumped |
| **D** | **Close #462** — comment + close as superseded-by-evidence | Issue closed with link to this plan + #618 for tracker hygiene |

## Tests / benches

| Path | Outcome | Role |
|------|---------|------|
| `li-tests/math_linalg/broadcast_len1_add_float4.li` | `compile_ok` | float `+` broadcast `array[1]` → `array[4]` |
| `li-tests/math_linalg/broadcast_len1_mul_int4.li` | `compile_ok` | int `*` broadcast |
| `li-tests/math_linalg/broadcast_len1_pow_int4.li` | `compile_ok` | int `**` broadcast |
| `li-tests/math_linalg/broadcast_invalid_len2_vs_len4.li` | `compile_fail` | non-len1 length mismatch rejected |
| `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` | CI PASS | MIR/codegen OK; Lean boundary documented |

**Run:** `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh math_linalg` and `./li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`.

No tier-1 bench ids — length-1 broadcast is compile-surface only (scalar loops; SIMD tiles deferred to **7e**).

## Provability

| Gap | Move | Honest limit |
|-----|------|--------------|
| **G-math** | Register **closed compile slice** for length-1 element-wise broadcast | **Still open on `main`:** Lean broadcast semantics (PR #900), NumPy-rank reject gate (PR #909) |
| **G-lean** | No change until PR #900 merges | `broadcast_len1_codegen_lean_gap.sh` enforces absence of `Discharge.lean` broadcast |
| **G-math-syn** | No change | Surface syntax unchanged since 2026-05-22 |

## Rollout

1. Merge this plan PR (draft → ready for review).
2. Maintainer adds **`plan-approved`** on **#462**; remove **`plan-needed`**.
3. **Docs-only implementation PR** (sub-phases B–C): coordinate with **#618** / **PR #866** so only one tracker PR lands.
4. Close **#462** (sub-phase **D**) when C exit gate passes.
5. Track Lean (**PR #900**) and NumPy-rank (**PR #909**) merges separately before PH-2i checkbox → done.

## Human-only

- [ ] Label **`plan-approved`** on **#462** before docs implementation agents run.
- [ ] Acknowledge **#462** body is stale (“zero broadcast tests”); close after sub-phase **C**.
- [ ] Merge **PR #900** and **PR #909** before promoting PH-2i to done.

## north_star_fit

**Domain:** scientific computing / linalg surface · **PH:** 2i, 2i-b · **Pillar:** Provability first — compile evidence registered honestly; Lean witness and rank broadcast deferred, not hidden.
