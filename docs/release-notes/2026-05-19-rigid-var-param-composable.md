# Rigid composable smoke: integrate via field-access arg

## Summary

Composable `import_physics_runtime.li` imports `physics.rigid`, runs one semi-implicit gravity step using `holder.body` (field-access call arg avoids borrowck move on a local `RigidBody`).

## Agent continuation

1. Read `packages/li-physics-rigid/src/lib.li` and `li-tests/composable/import_physics_runtime.li`.
2. Run `cmake --build build` then `./li-tests/run_all.sh composable` (or CI `check` job).
3. Next: `b: var RigidBody` on `rigid_integrate_semi_implicit` when object `var` params are verified in CI; then composable test may pass `body` directly.
4. Blocked on: publishing `li-physics-*` org mirrors (lic #50) for out-of-monorepo consumers.

## Changed

- `li-tests/composable/import_physics_runtime.li` — version check + integrate via `BodyHolder.body` field-access arg
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
