# PH-world-studio-program — master tracker

**Status:** Planning  
**Vision:** [world-studio-vision.md](world-studio-vision.md)

Cross-cutting program IDs. Implementation order respects dependencies in the vision doc.

| Program | Phases | Depends on |
|---------|--------|------------|
| **PH-GD** | GD-0…7 | `li-scene`, `li-ui` |
| **PH-UX** | UX-0…5 | PH-GD-1 |
| **PH-SIM** | SIM-0…6 | `li-physics-runtime` |
| **PH-ROBO** | ROBO-0…5 | PH-SIM-1 |
| **PH-AM** | AM-0…9 | PH-SCI-2, PH-UX-3 |
| **PH-SCI** | SCI-0…7 | tier-2 physics |
| **PH-DRUG** | DRUG-0…7 | PH-SCI-2, PH-GD-1, PH-AGENT |
| **PH-QM** | QM-0…7 | PH-HW, PH-COMPLY |
| **PH-VOXEL** | VOXEL-0…5 | PH-GD-5 |
| **PH-PUB** | PUB-0…5 | PH-UX, `sim.viz` |
| **PH-ML** | ML-0…5 | PH-HW-1 |
| **PH-AGENT** | AGENT-0…6 | `lic check --format=json` |
| **PH-PORT** | PORT-0…2 | LLVM triples |
| **PH-HW** | HW-0…4 | `lig` (WP1 governance; WP2+ `packages/lig`) |
| **PH-COMPLY** | COMPLY-0…4 | governance |

**Next execution milestones:** RFC stubs (landed) → `li-studio` scaffold (PH-GD-1) → **PH-SIM SIM-1** (landed) → **SIM-2** replay metadata (landed) → **SIM-3** `EnvPoolStub` (landed) → full `SimWorld` replay + async RL pools + scene sync.

**PH-AM AM-0 (landed):** `sim_additive_tick_stub`, slicer `slice→preview→export` with `require_sim_pass` gate; composable `import_sim_additive_slicer_workflow.li`; `studio_sim_step_hook` for profile **5**.

**PH-DRUG DRUG-0 (landed):** `sim_drug_design_tick_stub`, five-stage LITL workflow + `chem_dft_run_smoke` on DFT stage; composable `import_sim_drug_design_litl_workflow.li`; `studio_drug_litl_stage_from_tick`; `studio_sim_step_hook` for profile **7**.

**PH-SIM SIM-1 (landed):** `sim_reset` / `sim_step` on `SimSessionStub` (deterministic `tick`, no physics); `studio_sim_step_hook` after SIM-0 profile bridge. Evidence: `packages/li-sim/li-tests/smoke/sim_step_stub.li`, `docs/release-notes/2026-05-25-sim-step-sim1-stub.md`.

**PH-ROBO ROBO-0 / automotive tick (landed):** `sim_robotics_tick_stub` + `sim_automotive_tick_stub` wired through `studio_sim_step_hook`; composables `import_sim_robotics_workspace.li`, `import_sim_automotive_workspace.li`. Evidence: `packages/li-sim-robotics/li-tests/smoke/tick_stub.li`, `packages/li-sim-automotive/li-tests/smoke/tick_stub.li`, `docs/release-notes/2026-05-26-robo-auto-tick-stubs.md`.

**PH-SIM SIM-2 (landed):** `SimReplay` + session `replay_*` fields; `sim_session_replay_record` on each `sim_step`. Evidence: `packages/li-sim/li-tests/smoke/sim_replay_stub.li`, `docs/release-notes/2026-05-26-sim-replay-rl-game-scientific.md`.

**PH-ML SIM-3 partial (landed):** `packages/li-ml-rl` (`import ml.rl`) — `EnvPoolStub` → `sim_step` × `pool_size`; `studio_sim_step_hook` for `sim_rl`. Evidence: `packages/li-ml-rl/li-tests/smoke/env_pool_stub.li`.

**PH-GD-2 partial (landed):** `studio_game_world_checkpoint_stub` (`li-world` snapshot validity after game tick). Evidence: `packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li`.
