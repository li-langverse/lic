# Release notes: 2026-05-25 — li-sim-automotive-drive-stub

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (branch `feat/li-sim-automotive-drive-stub`)  
**PH / REQ:** PH-SIM (automotive drive smoke)  
**Author:** agent

---

## Summary (one sentence)

Adds `automotive_drive_tick_stub` with map/sensor placeholder structs, `automotive_drive_smoke.li`, and wires `studio_sim_step_hook` for `sim_automotive`.

## Agent continuation (required)

1. Read: `packages/li-sim-automotive/src/lib.li`, `packages/li-studio/src/lib.li` (`studio_sim_step_hook`).
2. Run: `lic check packages/li-sim-automotive/li-tests/smoke/automotive_drive_smoke.li`; `lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li`.
3. Then: CARLA/AirSim adapters — not this PR.
4. Blocked on: none.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `li-sim-automotive` | map/sensor placeholders + `automotive_drive_tick_stub` | `automotive_drive_smoke.li` |
| `li-studio` | `studio_sim_step_hook` on `sim_automotive` | `studio_sim_step_by_profile.li` |

## Not changed (scope fence)

- CARLA, AirSim, HD maps — **not** implemented.
- LLVM / httpd / tier5 — **not** touched.

## Breaking changes

None.

## Security

N/A.

## Performance

N/A.

## Downstream

Studio `sim_automotive` timeline should call `studio_sim_step_hook`.
