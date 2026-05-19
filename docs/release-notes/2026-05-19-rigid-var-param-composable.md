# Composable smoke: `import physics.runtime` step loop

## Summary

Composable `import_physics_runtime.li` imports `physics.runtime`, calls `physics_world_game_default` and one `physics_step` (no local `RigidBody` type — workspace package types are not yet used in composable fixtures).

## Agent continuation

1. Read `packages/li-physics-runtime/src/lib.li` and `li-tests/composable/import_physics_runtime.li`.
2. Run `cmake --build build` then `./li-tests/run_all.sh composable` (or CI `check` job).
3. Next: composable fixture using imported `RigidBody` once type re-exports are verified; consider `b: var RigidBody` on `rigid_integrate_semi_implicit`.
4. Blocked on: publishing `li-physics-*` org mirrors (lic #50) for out-of-monorepo consumers.

## Changed

- `li-tests/composable/import_physics_runtime.li` — `import physics.runtime` + `physics_step` smoke
- `li-tests/manifest.toml` — note updated for runtime import
- `docs/physics/SIMULATION_UI_READINESS.md` — composable status line

## Not changed

- Compiler borrowck (`check_call_moves` unchanged); import resolver; `std/` physics facades.
- Package mirror repos (`li-std-*`, `li-httpd`) — re-sync only if mirror PRs are open.
- PH-* master plan phase ordering.

## Breaking

N/A — parameter typing is stricter for in-place mutation (callers passing struct identifiers were already invalid for use-after-call).

## Security

N/A — no trust boundary change.

## Performance

N/A — same integrator math; avoids accidental struct copies when borrow rules tighten.

## Downstream

- Monorepo packages only until lic #50 publishes physics mirrors.
- Agents syncing mirrors: run `./scripts/sync-package-mirror-def-syntax-pr.sh` for affected repos after merge.
