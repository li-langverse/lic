# PH-2i: close stale #462 — broadcast_len1 compile slice reconcile (G-math)

> **Issue:** [#618](https://github.com/li-langverse/lic/issues/618) · **Supersedes:** [#462](https://github.com/li-langverse/lic/issues/462)  
> **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest gap register), **Easy** (clear tracker vs shipped tests)  
> **North star fit:** Scientific computing / linalg surface — **PH-2i**, **PH-2i-b**, **G-math**  
> **Learned from:** [2026-05-22-2i-broadcast-len1.md](../../release-notes/2026-05-22-2i-broadcast-len1.md), [2026-05-25-2i-broadcast-plan-tracker.md](../../release-notes/2026-05-25-2i-broadcast-plan-tracker.md), [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md), `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`

## Goal

Reconcile master-plan **Phase 2i** tracker and **G-math** register with shipped **length-1 broadcast compile tests**, close stale **#462** (no-test claim is false), and leave **PH-2i partial** until Lean witness (**#574**) and full NumPy-rank defer (**#526**) are tracked separately.

## Non-goals

- Adding new broadcast MIR/codegen (landed on `main` via PR #165 / #226).
- Closing **G-lean** or wiring `Discharge.lean` broadcast semantics (**#574** owns that).
- Defining full NumPy-rank reject policy (**#526** / `2026-05-30-numpy-broadcast-defer-ph2i.md`).
- Changing tier-1 benchmark thresholds or weakening `threshold_ratio_cpp`.
- Promoting `broadcast_len1_*` from `compile_ok` to `verify_ok` without Lean witness.

## Duplicate check

| Item | Status |
|------|--------|
| **#462** | Stale — same title as queue duplicate; evidence now contradicts body |
| **#574** | Open — Lean witness; **not** closed by this plan |
| **#526** | Open — NumPy-rank defer; separate plan |
| **PR #226** | Merged — compile tests + tracker slice |
| **PR #532** (closed) | NumPy defer plan for #526 — orthogonal |

## Dependencies

- **PH-2i-b** compile slice — `broadcast_len1_add_float4.li`, `broadcast_len1_mul_int4.li`, `broadcast_len1_pow_int4.li` (`manifest.toml` `compile_ok`).
- **PH-2i-b** reject slice — `broadcast_invalid_len2_vs_len4.li` (`compile_fail`).
- **#574** — blocks **G-math** promotion to closed Lean slice.
- **#526** — blocks master plan **2i** checkbox completion (full rank deferred).
- Human: **`plan-approved`** before docs PR merge.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Close #462** — comment + close as superseded by #618 evidence; link compile tests | Issue closed with audit table |
| B | **provability-gaps.md** — **G-math** closed slice cites `broadcast_len1_*` compile tests + `broadcast_len1_codegen_lean_gap.sh`; **open** slice notes Lean witness (#574) + NumPy rank (#526); bump **Last updated** | Row matches manifest + tooling script |
| C | **Master plan 2i row** — clarify length-1 broadcast **compile slice done**; keep `- [ ] Phase 2i` (Lean + NumPy rank open); cross-link #574, #526 | `plan-completion-audit` phase `2i` stays partial honest |
| D | **Release note** (optional) — `docs/release-notes/2026-06-03-ph2i-462-reconcile.md` if tracker edit is user-visible | Follow `li-release-notes.mdc` |
| E | **Handoff** — comment on #574 (proof_gap) and #526 (defer policy) with links | No duplicate implementation |

## Tests / benches

| ID | Path | Role |
|----|------|------|
| REQ-2i-b-len1-add | `li-tests/math_linalg/broadcast_len1_add_float4.li` | `compile_ok` — float element-wise add |
| REQ-2i-b-len1-mul | `li-tests/math_linalg/broadcast_len1_mul_int4.li` | `compile_ok` — int element-wise mul |
| REQ-2i-b-len1-pow | `li-tests/math_linalg/broadcast_len1_pow_int4.li` | `compile_ok` — `**` length-1 |
| REQ-2i-b-reject | `li-tests/math_linalg/broadcast_invalid_len2_vs_len4.li` | `compile_fail` — illegal shape |
| REQ-2i-lean-gap | `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` | CI documents open Lean gap |

**Gate:** `./li-tests/run_all.sh math_linalg` green; no manifest outcome changes in this plan PR.

## Provability / G-* updates

| Gap | Before | After (this plan) |
|-----|--------|-------------------|
| **G-math** | Partial; length-1 compile tests not cited in summary table | Partial; **closed compile slice** lists `broadcast_len1_*` + reject specimen; **open** lists Lean (#574) + NumPy rank (#526) |
| **G-lean** | Partial | Unchanged — no `Discharge.lean` broadcast Prop |
| **G-math-syn** | Partial | Unchanged |

## PH tracker mapping

| PH ID | This plan | Remaining owner |
|-------|-----------|-----------------|
| **PH-2i** | Reconcile partial row | #574, #526 |
| **PH-2i-b** | Close compile-test gap (#462) | #574 (witness), #526 (full rank) |

## Rollout

1. Merge this plan PR → add **`plan-approved`** on #618 (human).
2. Docs PR (sub B–C): `provability-gaps.md` + master plan 2i row + optional release note.
3. Close **#462** (sub A) with superseded comment linking tests.
4. Remove **`plan-needed`** from #618; keep **`master-plan-gap`** until #574 + #526 slices land.
5. Proof implementer picks up **#574**; defer policy implementer picks up **#526**.

## Human-only

- Maintainer **`plan-approved`** before tracker/gap register edits.
- Confirm #462 close reason: superseded (compile slice done), not "PH-2i complete".
- Do not merge `trusted.lean` / `Discharge.lean` broadcast semantics without #574 approval.
