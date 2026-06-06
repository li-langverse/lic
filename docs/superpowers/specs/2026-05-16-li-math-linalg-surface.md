# Mathematical linear-algebra surface (spec stub)

**Status:** Partial (Phase 2i + 7e) — 1d `@`/`dot`, `sum(array)`, 2d `@` (**2i-c**); `simd_dot`/`matmul_naive` pure-Li benches; explicit SIMD MIR (**7e-a**) deferred  
**Plan:** `docs/superpowers/plans/2026-05-16-li-math-linalg-surface.md`  
**Gaps:** [Provability gaps](../../verification/provability-gaps.md) **G-math**

## No runtime math dispatch

Mathematical notation is **static**:

- `A @ B` — matrix multiply is **shape-checked at compile time**; wrong dimensions → **`lic build` fails**  
- `a * b` — element-wise/broadcast rules decided in the typechecker, not at run time  
- `dot`, `sum` — lowering to SIMD/reduction MIR at compile time  

Users never call `simd(...)` or lane intrinsics in normal code. There is no “slow path” that discovers shapes at runtime.

**Goal:** linear-algebra mistakes are **compile-time errors**, same class as type errors — not `ValueError` at run time.

## Element-wise broadcast (2i policy)

| Rule | Status |
|------|--------|
| Matching `array[N]` lengths for `+ - * / **` | **done** |
| `float` × `array[N, float]` | **done** |
| `array[1, T]` → `array[N, T]` only (1d length-1) | **done** — not NumPy general broadcast |
| NumPy rank/length promotion (e.g. `array[2]` × `array[4]`, rank-2 `(M,N)` vs `(M,1)` or `(1,N)`) | **rejected** — `lic build` fails |
| Full NumPy rank broadcast (nd align, trailing axes) | **deferred** — [#526](https://github.com/li-langverse/lic/issues/526) |

Handbook: [linear-algebra.md](../../language/linear-algebra.md). Corpus: `li-tests/math_linalg/broadcast_len1_*.li` (allowed), `broadcast_invalid_*.li` (rejected).

**Defer criteria for full rank broadcast:** requires `tensor[(M,N), T]` surface (**Phase 3**), Lean shape proofs per axis, and SIMD tile lowering — tracked in [#526](https://github.com/li-langverse/lic/issues/526); do not implement silent promotion before then.

---

Users write `C += A @ B`, `y[i] = alpha * x[i] + y[i]`, `dot(x, y)` — not `simd(...)` or `__li_simd_*` in handbook or Tier 1 benchmarks.

Execution control remains decorators (`@parallel`, `@vectorized`, `@cpu`) — also compile-time only.

Tier 1 cross-lang regression: Li within 1.2× C++ on same machine.
