# Studio timeline playhead ↔ sim tick (WP-UX-02, WP-GD-08)

Timeline playback advances the native playhead from `SimSessionStub.tick` after `studio_sim_step_hook`, replacing the UX-02 mock +0.01 per-frame increment.

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_timeline_playback.li
./scripts/world-studio-plan-gates.sh
```

## Changed

| Area | What |
|------|------|
| `li-studio` | `studio_timeline_tick_sim_step`, `studio_timeline_sync_playhead_from_session`, `studio_timeline_scrub_to_tick`, `studio_timeline_reset_for_session` |
| `runtime/li_rt.c` | `li_rt_studio_timeline_sync_sim_tick`, `li_rt_studio_timeline_reset_playback`; default playhead 0.0 |
| Smoke | `studio_timeline_playback.li` — game profile step + replay tick + scrub |

## Remaining

- Present-loop / Space key should call `studio_timeline_tick_sim_step` each frame (WP-UX-09).
- Full deterministic replay scrub from `sim_replay` ring (WP-SIM-04).
