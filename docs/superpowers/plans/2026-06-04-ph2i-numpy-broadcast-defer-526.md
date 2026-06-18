# Full NumPy-rank broadcast — reject gate + defer criteria (PH-2i-b / G-math)

> **Issue:** [#526](https://github.com/li-langverse/lic/issues/526) · **Repo:** li-langverse/lic  
> **Supersedes:** [2026-05-30-numpy-broadcast-defer-ph2i.md](./2026-05-30-numpy-broadcast-defer-ph2i.md) (same scope; refreshed evidence June 2026)  
> **North star fit:** Scientific computing / linalg — **PH-2i-b**, **G-math** — proof-before-perf (compile-time shape reject; no silent NumPy semantics)

## Vision alignment

| Pillar | How this plan serves it |
|--------|-------------------------|
| **Provable** | Illegal broadcast shapes fail at `lic build`; `compile_fail` corpus is the contract agents must not weaken. |
| **Easy** | Handbook table states what works today vs what is explicitly deferred — no runtime `ValueError` surprises. |
| **Fast** | No implementation work in this plan; tier-1 hot paths stay broadcast-free. |

**Learned from:**

- [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md) — explicit math only; broadcast in typechecker
- [2026-05-22-compiler-studio-plan-loop.md](./2026-05-22-compiler-studio-plan-loop.md) — “reject NumPy broadcast” wave-A policy
- `li-tests/math_linalg/broadcast_len1_*.li` — shipped length-1 slice (manifest `1020–1031`)
- [NumPy broadcasting rules](https://numpy.org/doc/stable/user/basics.broadcasting.html) — **reference for defer criteria only** (not v1 semantics)

## Goal

Reconcile master-plan **Phase 2i** with shipped **length-1 broadcast**, and lock an explicit **reject + defer** policy for **full NumPy-rank broadcast** so tracker rows, gap register, and agents stay honest.

## Non-goals

- Implementing general `(M,N) × (M,1)`, 2d row/column promotion, or rank-N NumPy broadcast in v1.
- Runtime broadcast with dynamic shapes (Phase 3 `tensor[...]`).
- Weakening `compile_fail` or benchmark `threshold_ratio_cpp` to “go green.”
- Lean witness for length-1 MIR (**BUG-C-03** / **lic#574**) — separate track; not blocked on this policy PR.

## Current evidence (main, 2026-06-04)

| Artifact | Status |
|----------|--------|
| `broadcast_len1_add_float4.li`, `broadcast_len1_mul_int4.li`, `broadcast_len1_pow_int4.li` | **compile_ok** (`manifest.toml` 1020–1031) |
| `broadcast_invalid_len2_vs_len4.li` | **compile_fail** (len-2 vs len-4; diagnostic mentions length-1 broadcast) |
| Master plan `:447` | Still lists length-1 as inline open text — **needs reconcile** |
| Sub-plan exit gate `:174` | **2i-broadcast** checked — full NumPy rank still open |
| `broadcast_numpy_reject_*.li` | **Missing** on main — required by acceptance |
| Typechecker “NumPy-style rank broadcast is not supported” | **Missing** on main — sub-phase C |

## Broadcast policy (normative)

### Supported in v1 (PH-2i closed slice)

| Form | Example | Notes |
|------|---------|-------|
| Same-length 1d | `array[4] * array[4]` | Baseline element-wise |
| Scalar × array | `1.5 * a` where `a: array[N, float]` | No promotion |
| Length-1 → longer 1d | `array[1, int] * array[4, int]` | Only promotion allowed; MIR `array_broadcast_*_len1` |

### Rejected at compile time (must stay fail)

| Form | Example | Rationale |
|------|---------|-----------|
| Mismatched 1d lengths (neither is 1) | `array[2] * array[4]` | Not length-1 broadcast — NumPy would promote or error ambiguously |
| NumPy rank / 2d promotion | `(M,N) * (M,1)`, `(4,) * (2,2)` | Explicit math only — user must write loops or future `tensor` ops |
| `axpy` length mismatch | `axpy(α, x, y)` with `len(x) ≠ len(y)` | No broadcast on prelude reductions |

### Deferred (document only — do not implement silently)

| Capability | Defer to | Tracker link |
|------------|----------|--------------|
| Full NumPy rank broadcast (1d trailing, 2d rows/cols, padding dims) | Phase 3 `tensor[(M,N), T]` + new PH row after tensor types | **#526** |
| SIMD gather for broadcast rhs in `@vectorized` loops | **7e-a** | Master plan 7e partial |
| Lean VC for length-1 lowering | **G-lean** / BUG-C-03 | **lic#574** |

## Dependencies

| ID | Relationship |
|----|----------------|
| **PH-2i-b** | Parent slice — prelude `dot`/`norm`/`axpy`, reductions shipped |
| **lic#386** | Tracker reconcile — close when sub D merged |
| **lic#462** | Stale “no test” — close when manifest 1020–1031 cited |
| **lic#618** | Related reconcile PR — coordinate comment cross-links |
| Human | Label **`plan-approved`** before typechecker / `compile_fail` implementation PR |

## Sub-phases (implementation after plan-approved)

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | Policy tables in `docs/language/linear-algebra.md` + `docs/superpowers/specs/2026-05-16-li-math-linalg-surface.md` | Handbook PR review |
| **B** | `compile_fail` corpus — ≥2 illegal shapes: `broadcast_numpy_reject_len2_mul.li`, `broadcast_numpy_reject_pow_len2.li` (or equivalent); manifest entries | `./li-tests/run_all.sh math_linalg` green |
| **C** | Stable typechecker diagnostic mentioning NumPy-style rank broadcast; optional `lic check --format=json` sample in agent handover | Agent-diagnosable id documented |
| **D** | Master plan `:447` — length-1 **done**; full NumPy rank **deferred → #526** | `plan-completion-audit` 2i honest |
| **E** | `docs/verification/provability-gaps.md` **G-math** row — closed slice includes length-1 + reject corpus; open lists full rank | Same PR as D |
| **F** | Close **lic#386**, **lic#462** with evidence links | Issue comments only |

## Tests / benches

**Keep green:**

- `li-tests/math_linalg/broadcast_len1_*.li`
- `broadcast_invalid_len2_vs_len4.li`, `elementwise_len_mismatch.li`

**Add (post-approval):**

- `broadcast_numpy_reject_*.li` — `compile_fail` with stable `expected_substr` or diagnostic id

**Unchanged:**

- Tier-1 `simd_dot`, `matmul_*` — no broadcast in hot paths

## Provability

| Gap | Movement |
|-----|----------|
| **G-math** | Partial → closed slice extended (length-1 + explicit reject tests); full rank remains **open** |
| **G-math-syn** | Unchanged |
| **G-lean** | No movement from reject tests alone (**lic#574** for len-1 witness) |

## REQ mapping

| REQ | Acceptance |
|-----|------------|
| Reject policy documented | Sub A — handbook + spec tables |
| `compile_fail` ≥2 ranks | Sub B |
| Tracker reconcile | Sub D |
| **G-math** register | Sub E |

## Rollout

1. Merge **this plan PR** (docs only).
2. Maintainer adds **`plan-approved`** on **#526**; remove **`plan-needed`**.
3. Implementation PR: subs A–C (docs + tests + diagnostic).
4. Tracker PR: subs D–E (master plan + provability-gaps).
5. Close **#386**, **#462**; keep **#526** open until full-rank PH row exists or explicitly wont-fix.

## Human-only

- Maintainer **`plan-approved`** before any typechecker edit.
- Confirm full NumPy broadcast remains **deferred** to Phase 3 / future PH — not a silent v1 feature.
- No `trusted.lean` changes from this track.

## Orchestrator

**plan_verifier** → **code_implementer** (no runner loop). One implementation PR per sub-phase group (A–C, then D–E) preferred.
