# sim

Unified simulation step API (PH-SIM): `sim_step`, runtime profiles, SIM-2 `sim_replay_*`. Export/print lives in **`li-sim-additive`** (`import sim.additive`). **Timed** physics frame: `benchmarks/tier2_world/sim_physics_frame` (C kernel). **Real physics step (composable):** copy `import_sim_step_physics_runtime.li` — `sim_step_physics` calls `physics_step_for_game_tick`. Package `lib.li` still uses `sim_step_physics_stub` until PhysicsWorld imports stabilize in `li-sim`.

Li package `sim`

## Build

```bash
lic build src/lib.li -o sim
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-sim` |
| Org repo | https://github.com/li-langverse/sim |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
