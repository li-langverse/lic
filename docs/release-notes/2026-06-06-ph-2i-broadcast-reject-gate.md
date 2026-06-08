# PH-2i-b: NumPy rank broadcast reject gate + defer criteria

## Summary

Document and test the **2i broadcast policy**: length-1 1d promotion is allowed; NumPy-style rank broadcast (mismatched 1d lengths, rank-2 `(M,N)` vs `(M,1)` / `(1,N)`) is rejected at compile time. Full multidimensional rank rules remain **deferred** ([#526](https://github.com/li-langverse/lic/issues/526)).

## Agent continuation

1. **Read:** `docs/superpowers/specs/2026-05-16-li-math-linalg-surface.md` (broadcast table), `compiler/types/typecheck.cpp` (element-wise BinOp).
2. **Run:** `./li-tests/run_all.sh math_linalg` (or CI `math_linalg` suite).
3. **Next:** implement full NumPy rank broadcast only after `tensor[(M,N), T]` + Lean axis proofs — keep [#526](https://github.com/li-langverse/lic/issues/526) open until then.
4. **Blocked on:** Phase 3 tensor types, per-axis Lean specs, SIMD broadcast tiles.

## Changed

| Path | Evidence |
|------|----------|
| `compiler/types/typecheck.cpp` | rank-2 element-wise reject; 1d mismatch cites NumPy rank broadcast |
| `li-tests/math_linalg/broadcast_invalid_rank2_*.li` | compile_fail rank-2 seeds |
| `li-tests/manifest.toml` | manifest rows for new compile_fail specimens |
| `docs/language/linear-algebra.md` | broadcast rules table |
| `docs/superpowers/specs/2026-05-16-li-math-linalg-surface.md` | policy + defer criteria |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | length-1 done; full-rank deferred |
| `docs/verification/provability-gaps.md` | **G-math** closed slice (2i-broadcast) |

## Not changed

- Length-1 broadcast MIR/codegen (already on `main`).
- Lean `broadcast_len1` semantics (still **BUG-C-03** open).

## IDs

**PH-2i-b**, **G-math** — closes policy/doc slice of [#526](https://github.com/li-langverse/lic/issues/526); full rank implementation remains deferred.
