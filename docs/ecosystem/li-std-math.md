# li-std-math — spatial math & linalg helpers

<!-- DOC-ecosystem-li-std-math -->

**Repository:** [`li-langverse/li-std-math`](https://github.com/li-langverse/li-std-math) · **Package id:** `PKG-li-std-math`

Spatial math for physics and rendering: `Vec2/3/4`, `Quat`, `Mat4`, `AABB`, array `dot`/`sum` helpers. Aligns with master plan **Phase 2i** (math / linalg surface).

## API highlights (when built)

- `vec3`, `vec3_dot`, `vec3_cross`, `vec3_normalize`, `vec3_lerp`
- `quat_mul`, `mat4_mul_point`
- `array_dot_f64` / `array_sum_f64` (compiler `@` / `sum`)

## Status

| Area | Status |
|------|--------|
| Package + CI | In place |
| Full NumPy-rank broadcast | **Rejected** — see [math / linalg plan](../superpowers/plans/2026-05-16-li-math-linalg-surface.md) |
| Proof / perf | **G-math** **Partial** — [provability gaps](../verification/provability-gaps.md); tier-1 benches on [dashboard](https://li-langverse.github.io/benchmarks/) |

## Build

```bash
lic build src/lib.li -o li-std-math
```

## Cross-links

| Doc | Role |
|-----|------|
| [Math-first HPC examples](../guide/math-hpc-examples.md) | User-facing patterns |
| [Linear algebra handbook](../language/linear-algebra.md) | Syntax policy |
| [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | Phase 2i tracker |
| [Provability gaps](../verification/provability-gaps.md) | **G-math** evidence |
