# Full NumPy-rank broadcast — reject gate + defer criteria (PH-2i-b / G-math)

> **Issue:** [#526](https://github.com/li-langverse/lic/issues/526) · **Repo:** li-langverse/lic  
> **Vision:** **Easy** (explicit math, clear errors), **Provable** (compile-time shape reject)  
> **Learned from:** [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md), `li-tests/math_linalg/broadcast_len1_*.li`, [NumPy broadcasting rules](https://numpy.org/doc/stable/user/basics.broadcasting.html) (reject policy reference only)

## Goal

Reconcile master-plan **Phase 2i** tracker with shipped **length-1 broadcast** tests, and define an explicit **reject + defer** policy for **full NumPy-rank broadcast** so agents do not implement silent NumPy semantics or leave tracker rows ambiguous.

## Non-goals

- Implementing general `(M,N) × (M,1)` or rank-N NumPy broadcast in v1.
- Runtime broadcast with dynamic shapes (Phase 3 tensor work).
- Weakening shape errors to warnings.
- Benchmark threshold changes to compensate for missing broadcast.

## Dependencies

- **PH-2i-b** — prelude `dot`, `norm`, `axpy`, same-length `**`, scalar×array shipped.
- **lic#386** — tracker reconciliation (length-1); fold into this plan’s sub F.
- **lic#462** — length-1 test coverage; verify closed before claiming 2i-b slice.
- Human: **`plan-approved`** before typechecker / handbook edits.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Policy doc** — handbook + sub-plan: supported = same-length, scalar×array, length-1 (`array[1]`→`array[N]`); rejected = general rank broadcast | Table in `linear-algebra.md` |
| B | **compile_fail corpus** — at least 2 illegal broadcast shapes (e.g. `(4,) vs (2,2)`, `(M,N) vs (M,1)` if not supported) | `li-tests/math_linalg/broadcast_reject_*.li` in manifest |
| C | **Typechecker messages** — stable error codes for broadcast mismatch (agent-diagnosable JSON) | `lic check --format=json` sample in handover doc |
| D | **Tracker reconcile** — master plan 2i row: length-1 **done**; full NumPy rank **deferred** with link to #526 | `plan-completion-audit` 2i partial honest |
| E | **provability-gaps.md** — **G-math** closed slice lists length-1; full rank listed under open | Same PR as D |
| F | Close **lic#386** / **lic#462** when B + manifest evidence confirmed | Cross-link in issue comments |

## Tests / benches

- `li-tests/math_linalg/broadcast_len1_add_float4.li`, `broadcast_len1_mul_int4.li` — must stay green.
- New `broadcast_reject_*.li` — `compile_fail` with expected diagnostic id.
- `./li-tests/run_all.sh math_linalg` — gate for merge.
- Tier-1 linalg benches — unchanged (no broadcast in hot paths).

## Provability

- **G-math** — Partial; closed slice extended (length-1 + explicit reject corpus); full rank remains open.
- **G-math-syn** — unchanged (broadcast is shape typing, not operator syntax).
- No **G-lean** movement from reject tests alone.

## Rollout

1. Merge plan PR → **`plan-approved`** on #526.
2. Docs + compile_fail PR (sub A–C).
3. Tracker + gap register PR (sub D–E).
4. Close related issues #386, #462 when evidence matches.
5. Remove `plan-needed` on #526.

## Human-only

- Maintainer **`plan-approved`** before typechecker work.
- Confirm deferral: full NumPy broadcast targets Phase 3 tensor / future PH row (not silent v1 feature).
