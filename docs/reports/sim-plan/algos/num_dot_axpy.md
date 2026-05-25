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
| `SIM_PLAN_PACKAGE=li-math-numerics ./scripts/sim-plan-gates.sh` | **ok** (2026-05-25, iter `20260525-071749`) |
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

Implemented `dot_f64_8`, `axpy_f64_8`, `num_dot_axpy_smoke_checksum()` in `math.numerics` (smoke inlines dot/axpy because array args move on call); composable + `run_algo` dispatch for algo_id=1. Gates green on isolated clone (`LIC_ROOT=$PWD`, `SIM_PLAN_PACKAGE=li-math-numerics`). Iterations: [20260524-220836](../iterations/20260524-220836.md), [20260524-230028](../iterations/20260524-230028.md) (gate refresh @ `d658ca6`), [20260524-231504](../iterations/20260524-231504.md) (gate refresh @ `adec1df`), [20260525-000243](../iterations/20260525-000243.md) (gate refresh @ `bc69264`), [20260525-000836](../iterations/20260525-000836.md) (gate refresh @ `f04ca7c`), [20260525-000938](../iterations/20260525-000938.md) (gate refresh), [20260525-001801](../iterations/20260525-001801.md) (gate refresh @ `2baeee5`), [20260525-004429](../iterations/20260525-004429.md) (code implementer gate refresh @ `c6d5aa4`), [20260525-011243](../iterations/20260525-011243.md) (code implementer gate refresh @ `0043b42`), [20260525-012521](../iterations/20260525-012521.md) (code implementer gate refresh @ `866462e`), [20260525-053131](../iterations/20260525-053131.md) (code implementer gate refresh @ `6f4e871`), [20260525-054137](../iterations/20260525-054137.md) (code implementer gate refresh @ `55b79d1`), [20260525-063258](../iterations/20260525-063258.md) (code implementer `sim-p1-num-dot-axpy` gate refresh @ `61ce873`), [20260525-064324](../iterations/20260525-064324.md) (code implementer `sim-p1-num-dot-axpy` gate refresh @ `3578a57`), [20260525-071749](../iterations/20260525-071749.md) (code implementer `sim-p1-num-dot-axpy` gate refresh @ `92d51f1`).
