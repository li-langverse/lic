# Rigid integrate: `var` struct param + composable smoke

## Summary

`rigid_integrate_semi_implicit` mutates its body in place via `b: var RigidBody`; composable `import_physics_runtime.li` runs one semi-implicit gravity step after import.

## Agent continuation

1. Read `packages/li-physics-rigid/src/lib.li` and `li-tests/composable/import_physics_runtime.li`.
2. Run `cmake --build build` then `./li-tests/run_all.sh composable` (or CI `check` job).
3. Next: add composable smoke for `import physics.runtime` / `physics_step` if `PhysicsWorld` callers need `var world` params.
4. Blocked on: publishing `li-physics-*` org mirrors (lic #50) for out-of-monorepo consumers.

## Changed

- `packages/li-physics-rigid/src/lib.li`, `packages/li-physics-runtime/src/lib.li` — `b: var RigidBody` on `rigid_integrate_semi_implicit`
- `li-tests/composable/import_physics_runtime.li` — version check + one integrate step (`pz` must fall under gravity)
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
