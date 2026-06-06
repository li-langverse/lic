# 2i-b: NumPy rank broadcast reject gate + 2-rank compile_fail seeds

## Summary

Document and enforce the **PH-2i-b** reject policy for full NumPy rank broadcast: length-1 1d broadcast remains supported; 2d `(M,N)` vs `(M,1)` / `(1,N)` and general rank rules are **compile_fail** with explicit diagnostics. Full rank implementation deferred to [#526](https://github.com/li-langverse/lic/issues/526).

## Agent continuation

1. **Read:** `docs/superpowers/plans/2026-05-16-li-math-linalg-surface.md` (Broadcast policy), `docs/verification/provability-gaps.md` (**G-math**).
2. **Run:** `./li-tests/run_all.sh math_linalg`.
3. **Next:** implement full NumPy rank broadcast when Phase 3 `tensor` lands; Lean witness for length-1 broadcast (BUG-C-03).

## Changed

| Path | Evidence |
|------|----------|
| `compiler/types/typecheck.cpp` | Reject 2d matrix element-wise with `NumPy-style rank broadcast` diagnostic |
| `li-tests/math_linalg/broadcast_invalid_2d_m3n_vs_m1.li` | `(M,N)` vs `(M,1)` compile_fail |
| `li-tests/math_linalg/broadcast_invalid_2d_m3n_vs_1n.li` | `(M,N)` vs `(1,N)` compile_fail |
| `li-tests/manifest.toml` | manifest entries for 2-rank reject seeds |
| `docs/superpowers/plans/2026-05-16-li-math-linalg-surface.md` | Broadcast policy table + exit gate |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | Phase **2i** tracker reconciliation |
| `docs/language/linear-algebra.md` | Handbook reject policy |
| `docs/superpowers/specs/2026-05-16-li-math-linalg-surface.md` | Spec broadcast table |
| `docs/verification/provability-gaps.md` | **G-math** closed slice |

## Not changed

- Length-1 1d broadcast MIR/codegen (already on `main`).
- Full NumPy rank broadcast implementation (deferred #526).

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A — stricter reject for previously ill-typed 2d element-wise |
| **Security** | N/A |
| **Performance** | N/A |
| **Downstream** | Closes org-issue-zero bucket for #526 policy slice |
