# PH-2i / G-math: length-1 broadcast — Lean witness for MIR codegen (#574)

> **Issue:** [#574](https://github.com/li-langverse/lic/issues/574)  
> **Repo:** li-langverse/lic  
> **Vision:** **Provable** first — `lic build` must eventually discharge broadcast semantics, not only compile them  
> **North star fit:** Scientific computing / linalg — **PH-2i**, **G-math**, **G-lean**  
> **Learned from:** [2026-05-22-2i-broadcast-len1.md](../../release-notes/2026-05-22-2i-broadcast-len1.md), [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md), `Discharge.lean` (`dot4_int_spec`, `mat2_at2_float_spec`), `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh`

## Goal

Close the **G-math / G-lean** gap for **length-1 broadcast** (`array[1]` × `array[N]` element-wise): define Lean **Prop + eval** semantics in `Discharge.lean`, wire a **VC witness** (or an explicit `verify_open_ok` sub-plan gate), update **`provability-gaps.md`**, and flip the tooling script from “gap documented” to “witness present” — without changing MIR lowering behavior already on `main`.

## Non-goals

- New MIR/codegen for broadcast (landed: `array_broadcast_rhs_len1` / `array_broadcast_lhs_len1` in `lower.cpp`, `emit.cpp`).
- Full **NumPy-rank** broadcast rules or reject policy (**#526**).
- Master-plan tracker reconcile / closing **#462** (**#618**, PR [#764](https://github.com/li-langverse/lic/pull/764)).
- Tier-1 benchmark threshold changes or SIMD gather for broadcast loops.
- `trusted.lean` edits without explicit human approval on this issue.

## Duplicate check

| Item | Status |
|------|--------|
| **#574** | **This plan** — Lean witness for len-1 broadcast |
| **#618** / PR **#764** | Orthogonal — tracker + #462 reconcile; cites #574 as open Lean slice |
| **#526** | Orthogonal — NumPy-rank defer policy |
| **#462** | Superseded by #618 evidence — not reopened here |
| `2026-06-03-ph2i-close-stale-462-broadcast-reconcile.md` | Docs-only reconcile — no `Discharge.lean` |

## Dependencies

| Dep | Role |
|-----|------|
| Compile slice | `broadcast_len1_add_float4.li`, `broadcast_len1_mul_int4.li`, `broadcast_len1_pow_int4.li` — `manifest.toml` `compile_ok` |
| Gap script | `broadcast_len1_codegen_lean_gap.sh` — today asserts **no** Lean/witness; must be updated in implementation PR |
| Closed templates | `dot4_int_spec` + `dot4_loop_eval`; `mat2_at2_float_spec` + `mat2_at2_eval` — pattern for fixed-size eval + `rfl`/`by` proof |
| **#618** plan merge | Recommended before implementation so **G-math** summary table already lists compile slice + open Lean (#574) |
| Human | **`plan-approved`** on #574 before product-code PR |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **`Discharge.lean`** — per-op fixed-N specs: `broadcast_len1_add_float4_spec`, `broadcast_len1_mul_int4_spec`, `broadcast_len1_pow_int4_spec` (+ shared `broadcast_len1_rhs_eval` helpers for `+`, `*`, `**`) | `lake build` / `discharge_linalg_int_lean.sh` (or new `discharge_broadcast_len1_lean.sh`) passes with zero open AutoVC goals for specimens |
| **B** | **`vc_witness.cpp`** — `witness_broadcast_len1_*_impl` recognizing closed ensures on `main` in the three `broadcast_len1_*.li` probes (mirror `witness_dot4_int_loop_impl`) | `lic build` on probes reaches `prove_lean_ok` / `verify_ok` per manifest |
| **C** | **`li-tests/manifest.toml`** — promote `broadcast_len1_*` from `compile_ok` → `prove_lean_ok` (or `verify_open_ok` only if sub-plan gate documented) | `./li-tests/run_all.sh math_linalg` green |
| **D** | **`broadcast_len1_codegen_lean_gap.sh`** — invert checks: require Lean defs + witness; keep MIR/asm smoke | CI script `PASS` on `main` after implementation |
| **E** | **`provability-gaps.md`** — **G-math** row: move length-1 broadcast from **open** to **closed slice** (Lean); **G-lean** partial→closed for this slice; bump **Last updated** | Row matches manifest + `Discharge.lean` |
| **F** | **Master plan 2i row** (line ~447) — note **length-1 broadcast Lean slice done**; keep Phase 2i `- [ ]` until NumPy rank (#526) | Honest partial in `plan-completion-audit` |

## Tests / benches

| ID | Path | Role |
|----|------|------|
| REQ-2i-b-len1-add | `li-tests/math_linalg/broadcast_len1_add_float4.li` | Target `prove_lean_ok` — float `a + b` with `b: array[1]` |
| REQ-2i-b-len1-mul | `li-tests/math_linalg/broadcast_len1_mul_int4.li` | Target `prove_lean_ok` — int `a * b` |
| REQ-2i-b-len1-pow | `li-tests/math_linalg/broadcast_len1_pow_int4.li` | Target `prove_lean_ok` — int `a ** b` |
| REQ-2i-lean-gap | `li-tests/tooling/broadcast_len1_codegen_lean_gap.sh` | Gate script — documents closed witness post-impl |
| REQ-2i-b-reject | `li-tests/math_linalg/broadcast_invalid_len2_vs_len4.li` | Unchanged `compile_fail` — illegal shape |
| Bench | — | **None** — proof slice only; no tier-1 ratio work |

**Contrast (closed slice pattern):** `li-tests/contracts_verify/linalg_mat2_at2_float_closed.li` ↔ `mat2_at2_float_spec`; loop dot ↔ `dot4_int_spec`.

## Provability / G-* updates

| Gap | Before | After (implementation PR) |
|-----|--------|-------------------------|
| **G-math** | Partial — len-1 broadcast **compile only**; gap script blocks Lean | Partial — **closed Lean slice** for len-1 `+ * **`; NumPy rank still open (#526) |
| **G-lean** | Partial — no `broadcast_len1` in `Discharge.lean` | **Closed slice** for len-1 broadcast Props |
| **G-vc** | Partial — no `witness_broadcast_len1` | Witness wired for three specimens |

## PH tracker mapping

| PH ID | This plan | Remaining owner |
|-------|-----------|-----------------|
| **PH-2i** | Close **len-1 Lean witness** slice | **#526** (full rank), tier-1 perf rows (**7e**) |
| **PH-2i-b** | Witness for compile tests already landed | — |

## Implementation sketch (for implementer — not in plan PR)

1. Add `broadcast_len1_rhs_eval{N}` for `Float`/`Int` in `Discharge.lean` (index `i` uses `rhs[0]`).
2. State `broadcast_len1_add_float4_spec (a b result : Prop)` as pointwise equality with eval.
3. Prove with `rfl` or small `by` block (fixed `N=4`).
4. Add `witness_broadcast_len1_add_float4_impl` in `vc_witness.cpp` matching ensures shape in probe `main`.
5. Run `lic build` on each probe; update manifest outcomes.
6. Update `broadcast_len1_codegen_lean_gap.sh` to **require** grep hits in `Discharge.lean` / `vc_witness.cpp`.

**Defer path (only if human rejects Lean in one PR):** keep `compile_ok`, set `verify_open_ok` with linked sub-plan gate in manifest; edit master plan to document intentional defer — **not** the default for #574 acceptance.

## Rollout

1. Merge **this plan PR** → human adds **`plan-approved`** on #574.
2. Implementation PR (subs A–F): `Discharge.lean`, `vc_witness.cpp`, manifest, gap script, `provability-gaps.md`, master plan row.
3. Remove **`plan-needed`** from #574; keep **`master-plan-gap`** until **#526** closes NumPy-rank defer.
4. Comment on **#618** / **#526** with cross-links (no duplicate work).

## Human-only

- Maintainer **`plan-approved`** before any `Discharge.lean` / `trusted.lean` merge.
- Confirm no weakening of `broadcast_len1_codegen_lean_gap.sh` to skip witness checks.
- Review implementation PR for proof soundness (fixed `N` only — no implicit full-rank claim).
