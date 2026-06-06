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

### Broadcast (v1 reject gate)

| Case | Verdict |
|------|---------|
| `array[N,T]` element-wise with same `N` | OK |
| `array[1,T]` with `array[N,T]` (1d length-1 broadcast) | OK |
| `array[M,T]` with `array[K,T]`, `M≠K`, neither is 1 | **compile_fail** |
| `array[M,array[N,T]]` with `array[M,array[1,T]]` or `array[1,array[N,T]]` | **compile_fail** — NumPy rank broadcast rejected |
| Full NumPy rank alignment | **deferred** ([#526](https://github.com/li-langverse/lic/issues/526)) |

---

Users write `C += A @ B`, `y[i] = alpha * x[i] + y[i]`, `dot(x, y)` — not `simd(...)` or `__li_simd_*` in handbook or Tier 1 benchmarks.

Execution control remains decorators (`@parallel`, `@vectorized`, `@cpu`) — also compile-time only.

Tier 1 cross-lang regression: Li within 1.2× C++ on same machine.
