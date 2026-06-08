# Physics domain API plan (lic#14)

Planning slice only — **no product code** in this PR.

## Summary

Adds implementation plan for [lic#14](https://github.com/li-langverse/lic/issues/14): expand `li-physics-*` scaffold `src/lib.li` into tier-2-aligned domain APIs (units, fields, integrator hooks) with a pure-Li kernel path per [GAME_DEV.md](../physics/GAME_DEV.md).

## north_star_fit

- **Domain:** tier-2 physics modules for scientific computing + game engine imports
- **PH:** 5b, 2i, 7e · **G-physics**, **G-math**
- **Pillars:** proof-first contracts → composable `import physics.*` → perf after PH-7e

## Artifacts

| Path | Role |
|------|------|
| `docs/superpowers/plans/2026-06-08-li-physics-domain-api-plan.md` | Wave A–G implementation plan |
| `docs/ecosystem/plan-cross-links.md` | Index entry |

## Scope boundary

- **In scope:** domain API depth across 12 packages
- **Out of scope:** org mirrors (lic#50), PETSc/Kokkos production stacks, threshold weakening

## Next steps (after `plan-approved`)

1. Wave A–B: `physics.core` units/fields + runtime integrator spine
2. Wave C–E: subdomain packages aligned to tier-2 benches
3. Wave F–G: pure-Li reference + proof-database / composable matrix
