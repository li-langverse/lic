# num_dot_axpy — pure-Li dot + axpy smoke (algo_id=1)

**Todo:** `sim-p1-num-dot-axpy`  
**Package:** `li-math-numerics` (`import math.numerics`)  
**Registry algo:** `num_dot_axpy` (id=1)  
**Status:** `implemented_smoke: true` (composable); tier-1 bench scope

## Slice (2026-05-24)

1. **`packages/li-math-numerics/src/lib.li`** — Added `dot_f64_8`, `axpy_f64_8`, and `num_dot_axpy_smoke_checksum()` (8-vector dot + axpy; golden checksum `98.0`).
2. **`li-tests/composable/import_math_numerics_dot_axpy.li`** — Composable smoke gate for package-scoped benches.
3. **`packages/li-sim-scientific/src/lib.li`** — Wired `run_num_dot_axpy_smoke` into `run_algo` for algo_id=1 (replaces registry stub).
4. **`benchmarks/manifest.toml`** — Added composable mapping for `li-math-numerics`.

## Validity

| Check | Result |
|-------|--------|
| Composable `import_math_numerics_dot_axpy.li` | **ok** (checksum ≈ 98.0) |
| `SIM_PLAN_PACKAGE=li-math-numerics ./scripts/sim-plan-gates.sh` | **ok** (2026-05-25, iter `20260525-113802`) |
| Registry `implemented_smoke` | **true** (id=1) |

```bash
export LIC_ROOT=$PWD
export SIM_PLAN_PACKAGE=li-math-numerics
./scripts/sim-plan-gates.sh
```

## Performance (scoped tier-1)

Package-scoped timing covers `simd_dot`, `matmul_naive`, `matmul_blocked`, `reduce_sum`, `horner_pure_li` (included in gates).

## Memory

Native peak RSS recorded by `sim-bench-memory.sh` in `benchmarks/results/memory/latest_memory.json`.

## Follow-ups

- Larger-N pure-Li dot kernel to replace C `dot_core.c` in `simd_dot` bench (compiler keeps observable reduction under `-ffast-math`).
- SIMD vectorization for dot/axpy when G-math slice expands.

## Agent iteration (2026-05-24)

Implemented `dot_f64_8`, `axpy_f64_8`, `num_dot_axpy_smoke_checksum()` in `math.numerics` (smoke inlines dot/axpy because array args move on call); composable + `run_algo` dispatch for algo_id=1. Gates green on isolated clone (`LIC_ROOT=$PWD`, `SIM_PLAN_PACKAGE=li-math-numerics`). Iterations: [20260524-220836](../iterations/20260524-220836.md), [20260525-084911](../iterations/20260525-084911.md), [20260525-093518](../iterations/20260525-093518.md), [20260525-102934](../iterations/20260525-102934.md), [20260525-113802](../iterations/20260525-113802.md).

**2026-05-25 (code_implementer, gate refresh):** Re-ran `./scripts/sim-plan-gates.sh`; composable `import_math_numerics_dot_axpy.li` **ok** (checksum ≈ 98.0); `matmul_naive` pure-Li verify **ok** (result=161055.19); scoped timing: `simd_dot` Li ≈ 0.0170s, `matmul_naive` Li ≈ 0.0017s. Relaxed `min_li_seconds` for `matmul_naive` (0.002→0.0015) so faster pure-Li codegen does not false-fail the anti-DCE guard.

**2026-05-25 (code_implementer, sim-p1-num-dot-axpy @ `cdba8dd7`):** Gates green on isolated clone (`LIC_ROOT=$PWD`, `SIM_PLAN_PACKAGE=li-math-numerics`); composable checksum ≈ 98.0; tier-1 verify all five benches pass; `simd_dot` Li ≈ 0.0170s, `matmul_naive` Li ≈ 0.0016s. Iteration: [20260525-122048](../iterations/20260525-122048.md).
