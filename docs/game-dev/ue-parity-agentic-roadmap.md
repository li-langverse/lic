# UE parity + agentic studio roadmap

**Goal:** Beat Unreal on **ease of use** and **agent-native development**, while closing the gap on **measurable** subsystems (not claiming Nanite/Lumen parity on day one).

## Where we win (keep investing)

| Wedge | vs UE5 |
|-------|--------|
| **Diffable worlds** | `world.li` + assets in git; no opaque `.umap`-only workflow |
| **`lic build`** | Contracts on gameplay/sim rules; CI blocks broken patches |
| **Agents** | MCP + `li-studio-ai`: natural language → patch → build gate |
| **Unified engine** | Same runtime: game, RL, automotive, drug, AM (`sim` profiles) |
| **Arbitrary physics** | `physics.custom` + law modes without C++ plugin compile |

## Where UE still wins (honest)

Editor depth, GPU renderer, animation, audio, platform SDKs, marketplace, decades of content tools.

## Measurement strategy (UE “somehow”)

We do **not** run UE5 in `lic` CI today. Three layers:

1. **In-repo proxies** (`tier2_world/`, `gaming_full`) — timed C/Li kernels with validity.
2. **UE proxy budgets** — [`unreal-proxy-targets.json`](../../benchmarks/competitive/unreal-proxy-targets.json) (aspirational ms/tick from subsystem literature; dashboard ratio only).
3. **External baselines** (manual) — UE Insights / Tracy / stat `Physics` on a sample project → `data/external/ue-baselines.csv` (future).

```bash
# Publish timings + org ingest + UE proxy comparison
./scripts/publish-benchmarks-ingest.sh
```

Dashboard: `benchmarks` repo `data/latest/summary.json` → `unreal_proxy_comparison[]`.

## Phased parity

### P0 — Measuring (now)

- [x] `world_engine` timed: `game_world_soa_10k`, `game_replication_encode`, `sim_physics_frame`, `render_frame_present`
- [x] `gaming_full` at `--full`: `cloth_swing`, `rigid_body_stack`
- [x] Org `catalog.toml` + ingest merge (`world_engine_full.csv`)
- [x] UE proxy JSON + `engines.toml`
- [ ] Ingest CI job: `publish-benchmarks-ingest.sh` on release branch

### P1 — Li runtime catches C kernel

- [x] `sim_step_physics` in `physics.runtime` + composable `import_sim_step_physics_runtime.li`
- [x] `import_sim_physics_unified.li` — runtime + `sim.step_physics` stub (no `import sim` in physics-only composable)
- [ ] `sim_step_physics` in `li-sim` package `lib.li` (blocked: PhysicsWorld cross-package)
- [x] `li-render` present path + `render_frame_present` tier-2 bench
- [x] Replication interest filter (`game_replication_interest_*`) + composable gate
- [ ] Replication prediction stub (net tick p99)

### P2 — Studio UX (easier than UE for agents)

- [x] Command palette API (`studio_command_execute` — play / pause / lic build)
- [ ] Native `li-studio` shell (replace HTML demo): outliner, viewport, GPU present path
- [ ] **≤3 clicks** primary flows ([PH-UX](PH-world-studio-program.md))
- [ ] `studio.adaptive` panels by profile (game / sim / drug)
- [ ] Agent loop: prompt → edit `world.li` → `lic build` → preview

### P3 — Subsystem parity (multi-year)

- [ ] ECS @ 10k+ with streaming (GW-2+)
- [ ] Chaos-class rigid + cloth validity vs external oracle
- [ ] Net: shard tick p99, MMO composables → timed benches
- [ ] Optional: import `ue-baselines.csv` column in dashboard

## Agentic development (default path)

```text
User intent (Cursor / MCP)
  → search world.li + packages
  → patch Li (spawn, law_mode, replication stub)
  → lic build (composable + package gates)
  → bench.py --only <affected kernel>
  → publish-benchmarks-ingest.sh (regression vs UE proxy budget)
```

Rules: `.cursor/rules` + `AGENTS-world-studio.md` — never claim green dashboard without `validity.json` pass.

## Claims

| Allowed | Forbidden |
|---------|-----------|
| Li/cpp ratio on `world_engine` with validity | “Faster than Unreal” without external baseline |
| Under UE **proxy budget** on micro-kernel | Proxy budget = measured UE5 in CI (not yet) |
| Best agent-native world authoring | Composable count = engine parity |

See also: [competitive-gap-vs-unreal.md](competitive-gap-vs-unreal.md), [world-studio-vision.md](world-studio-vision.md).
