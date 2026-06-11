# Physics domain API — Wave A + C (lic#7 / #14)

**Date:** 2026-06-11  
**Repo:** lic  
**Issue:** [#7](https://gitlab.lilangverse.xyz/li-langverse/lic/-/issues/7) / [#14](https://github.com/li-langverse/lic/issues/14)

## Summary

First implementation slice of [2026-06-08-li-physics-domain-api-plan.md](../superpowers/plans/2026-06-08-li-physics-domain-api-plan.md):

- **Wave A:** `physics.core` SI unit tags, physical constants, `ScalarField2D` / `VectorField2D` skeletons
- **Wave B (partial):** `numerics_integrator_tag` + `physics_integrator_order_for_tier` spine
- **Wave C (hep):** `DecayChannel`, `McEvent`, isotropic sampling, toy MC smoke

## Packages

| Package | Changes |
|---------|---------|
| `li-physics-core` | `SiUnit`, `PhysicalConstant`, field types, `c_light`, `k_boltzmann` |
| `li-physics-hep` | Toy MC surface ≥120 lines; removed `ensures result == 0.0` placeholders |
| `li-physics-runtime` | Integrator order lookup in `physics_step` |
| `li-math-numerics` | `numerics_integrator_tag` |

## Tests

- `packages/li-physics-core/li-tests/smoke/units_fields_smoke.li`
- `packages/li-physics-hep/li-tests/smoke/hep_toy_mc_smoke.li`
- `li-tests/composable/import_physics_core.li`
- `li-tests/composable/import_physics_hep.li`

## Verification

```bash
./scripts/build.sh
lic check packages/li-physics-core/src/lib.li
lic check packages/li-physics-hep/src/lib.li
lic build packages/li-physics-core/li-tests/smoke/units_fields_smoke.li -o /tmp/core-smoke
lic build packages/li-physics-hep/li-tests/smoke/hep_toy_mc_smoke.li -o /tmp/hep-smoke
```

## Deferred

Waves C (chem, weather, aero, relativity), D–G per plan; PETSc/Kokkos stacks (lic#117).
