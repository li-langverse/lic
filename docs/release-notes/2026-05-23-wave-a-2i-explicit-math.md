# Wave A 2i — explicit math only (no NumPy broadcast)

## Summary

Wave A closes the **2i** policy slice: `dot`, `sum`, 1d/2d `@`, element-wise `+ - * / **` on matching shapes, scalar×array, and the sole allowed promotion — `array[1, T]` broadcast to `array[N, T]`. **NumPy-style rank broadcast** (e.g. length 2 vs 4, 2d row/column promotion) is rejected at compile time.

## Agent continuation

1. **Read:** `docs/language/linear-algebra.md` (broadcast policy + tensor/quaternion path), `compiler/types/typecheck.cpp`.
2. **Run:** `./scripts/compiler-studio-plan-gates.sh`; `./scripts/verify-math-physics-goldens.sh`; `./scripts/bench-verify-results.sh 1`.
3. **Next:** `wave-a-7d-vectorized`; full `tensor[(M,N), f64]` types (Phase 3).

## Changed

| Path | Evidence |
|------|----------|
| `docs/language/linear-algebra.md` | Explicit ops table; no NumPy broadcast; tensor/quaternion roadmap |
| `docs/superpowers/specs/2026-05-16-li-math-linalg-surface.md` | Broadcast rules in spec |
| `li-tests/math_linalg/broadcast_numpy_reject_*.li` | compile_fail for len-2 vs len-4 |
| `compiler/types/typecheck.cpp` | Diagnostic names NumPy-style rejection |
| `docs/superpowers/plans/2026-05-22-compiler-studio-plan-loop.md` | `wave-a-2i-explicit-math` completed |

## Not changed

- Length-1 element-wise broadcast (documented exception).
- `li-math` quaternion API surface (already in `packages/li-math`).

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A — stricter docs + new compile_fail specimens only |
| **Security** | N/A |
| **Performance** | N/A |
| **Downstream** | Studio/sim profiles use explicit `array[N]` + `li-math` quats until `tensor` lands |
