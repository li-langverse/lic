# Studio vertical: `game`

**Focus:** Default shell, selection ring, timeline playhead; **PH-SIM** `studio_game_step_hook` (`physics.runtime` substep); **PH-GD-2-SCENE-1** scene batch sync + `WorldSnapshot.position_checksum`; **SIM-2** replay tick ring on `sim_step`.

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| Profile chip + compose roundtrip | Full li-player ship loop |
| `studio_game_step_hook` → sync→`physics_step`→sync (`scene_sync_count == 2`) | Full 4-entity scene graph editor |
| `physics_sync_from_scene` / `physics_sync_to_scene` on `SceneEntityBatch` (max 4) | GPU scene draw |
| `studio_game_world_snapshot_from_physics` + checkpoint fields | `world_serialize` in hot path |
| `world_v1` wire line with optional `position_checksum` (legacy 3-field parse) | Full SimWorld entity replay |

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_game_physics_step.li
lic check packages/li-scene/li-tests/smoke/scene_physics_sync.li
lic check packages/li-physics-runtime/li-tests/smoke/game_physics_step.li
lic check packages/li-world/li-tests/smoke/world_roundtrip.li
```

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/game.html`
