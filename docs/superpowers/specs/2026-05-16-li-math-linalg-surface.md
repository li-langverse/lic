# Mathematical linear-algebra surface (spec stub)

**Status:** Partial (Phase 2i + 7e) — 1d `@`/`dot`, `sum(array)`, 2d `@` (**2i-c**); `simd_dot`/`matmul_naive` pure-Li benches; explicit SIMD MIR (**7e-a**) deferred  
**Plan:** `docs/superpowers/plans/2026-05-16-li-math-linalg-surface.md`  
**Gaps:** [Provability gaps](../../verification/provability-gaps.md) **G-math**

## No runtime math dispatch

Mathematical notation is **static**:

- `A @ B` — matrix multiply is **shape-checked at compile time**; wrong dimensions → **`lic build` fails**  
- `a * b` — element-wise ops only when **shapes match** (same length); decided in the typechecker, not at run time  
- `dot`, `sum` — lowering to SIMD/reduction MIR at compile time  

Users never call `simd(...)` or lane intrinsics in normal code. There is no “slow path” that discovers shapes at runtime.

**Goal:** linear-algebra mistakes are **compile-time errors**, same class as type errors — not `ValueError` at run time.

---

Users write `C += A @ B`, `y[i] = alpha * x[i] + y[i]`, `dot(x, y)` — not `simd(...)` or `__li_simd_*` in handbook or Tier 1 benchmarks.

## No implicit broadcast (binding)

Li does **not** adopt NumPy-style broadcasting (silently repeating a shorter operand to match a longer one). That notation is easy to misread and is not the same as valid same-dimension linear algebra.

Prefer instead:

- **Matching shapes** for element-wise `+ - * /` and `@` (compile-time errors otherwise).
- **Explicit loops** (`for` / `parallel for` + `@vectorized`) for AXPY-style updates — readable for non-experts and provable.
- **Named functions** where a pattern is standard (`dot`, `sum`, future `axpy`, `norm`, `scale`) instead of clever shape rules.

Execution control remains decorators (`@parallel`, `@vectorized`, `@cpu`) — also compile-time only.

Tier 1 cross-lang regression: Li within 1.2× C++ on same machine.
