# Studio vertical: `game`

**Focus:** Default shell, selection ring, timeline playhead; **PH-SIM** `studio_game_step_hook` (`physics.runtime` substep); **PH-GD-2 partial** `studio_game_world_checkpoint_stub` (snapshot validity, no save I/O); **SIM-2** replay tick ring on `sim_step`.

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| Profile chip + compose roundtrip | Full li-player ship loop |
| Tick-rate gate on `studio_game_step_hook` (hz check) | `physics.runtime` `physics_step` in hot path |
| World snapshot validity gate | `world_serialize` in hot path |
| Session replay metadata (`replay_last_tick`) | Full SimWorld entity replay |

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/game.html`
