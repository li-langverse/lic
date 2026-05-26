# Release notes: 2026-05-26 — SIM-2 replay, SIM-3 RL pool, game/scientific verticals

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-SIM SIM-2, PH-ML SIM-3 (partial), PH-GD-2 (partial), verticals `game` / `sim_rl` / `sim_scientific`

---

## Summary (one sentence)

`SimSessionStub` records replay tick metadata on each `sim_step`; `ml.rl.EnvPoolStub` batches RL env steps into `studio_sim_step_hook` for `sim_rl`; game adds world snapshot validity gate; scientific tick stub dispatches MD / heat / rigid smokes by `output_detail`.

## Agent continuation

1. Read: `packages/li-sim/src/lib.li` (SIM-2), `packages/li-ml-rl/src/lib.li` (SIM-3), `packages/li-studio/src/lib.li` (`studio_sim_step_hook`).
2. Run: `lic check packages/li-sim/li-tests/smoke/sim_replay_stub.li`; `lic check packages/li-ml-rl/li-tests/smoke/env_pool_stub.li`; `lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li`.
3. Then: full `SimWorld` replay payloads; async `EnvPool`; `world_serialize` on game save.

## Changed

| Area | What | Evidence |
|------|------|----------|
| `li-sim` | `SimReplay`, session replay fields, `sim_session_replay_*` | `sim_replay_stub.li` |
| `li-ml-rl` | `EnvPoolStub`, `env_pool_stub_step` | `env_pool_stub.li` |
| `li-sim-scientific` | detail-tier `sim_scientific_tick_stub` | `scientific_tick_tiers.li` |
| `li-studio` | `sim_rl` / `game` hooks, deps `li-ml-rl`, `li-world` | `studio_sim_step_by_profile.li` |
| Vertical READMEs | Honest stub vs implemented tables | `examples/verticals/*/README.md` |

## Not changed (scope fence)

- Full entity/state replay buffers on `SimWorld` — **not** implemented.
- Async parallel RL workers — **not** implemented.
- `sim.viz`, tier-2 MD oracles in viewport — **not** implemented.
- li-player ship loop — **not** implemented.
