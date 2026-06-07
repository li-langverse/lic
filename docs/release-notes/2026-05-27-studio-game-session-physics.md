# Studio game step: session-persisted physics (PH-GAME-01)

**Date:** 2026-05-27  
**Branch:** `feat/studio-real-implementation`  
**Packages:** `li-physics-runtime`, `li-sim`, `li-studio`

## Summary

`studio_game_step_hook` now advances gravity-integrated rigid-body state stored on `SimSessionStub` (`game_px`…`game_vz`, `game_physics_steps`) via `game_physics_step_hook` in `li-physics-runtime`, replacing an ephemeral per-call `PhysicsWorld`.

## Verify

```bash
lic check packages/li-physics-runtime/src/lib.li
lic check packages/li-sim/src/lib.li
lic check packages/li-studio/src/lib.li
lic check packages/li-studio/li-tests/smoke/studio_game_step_hook.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```

## Evidence

| Area | Change | Smoke |
|------|--------|-------|
| `li-physics-runtime` | `GamePhysicsState`, `game_physics_step_hook` | — |
| `li-sim` | `SimSessionStub.game_*` fields, reset in `sim_reset` | defaults in `sim_session_stub_default` |
| `li-studio` | `studio_game_step_hook(sim_out, dt)` session load/store | `studio_game_step_hook.li`, `studio_sim_step_by_profile.li` |

## Remaining stubs

- `physics_sync_from_scene` / `physics_sync_to_scene` — no-op
- `studio_game_entity_count_stub` — fixed entity count `1` for checkpoint scaffold
- Full rigid stack + multi-entity scene sync (`WP-GAME-02`)
