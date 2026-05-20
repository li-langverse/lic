# Competitive gap vs Unreal / Unity (honest)

**Not a drop-in replacement.** Li World Studio competes on **diffable worlds, `lic build`, agents, and measured subsystems** — not Nanite/Lumen parity.

| Capability | Unreal Engine 5 (typical) | Li today | Competitive path |
|------------|---------------------------|----------|------------------|
| Editor & assets | Production | `li-studio` shell + stubs | PH-GD milestones |
| Renderer | Nanite, Lumen, materials | `li-render` viewport stubs | Timed `render_*` + GPU present bench |
| ECS @ 10k+ entities | Yes | **Timed** `game_world_soa_10k` | `benchmarks/tier2_world/` |
| Net replication | Production | **Timed** `game_replication_encode` | Delta ratio vs full snapshot |
| Physics frame | Chaos | **`sim_step_physics`** + `sim_physics_frame` bench | `physics.runtime` + Li `sim` inline state |
| Cloth / ragdoll / fluids | Production | `v0_gaming` → **`gaming_full`** via `LI_BENCH_QUICK=0` | tier-2 physics + validity |
| Proof / agents | No | **`lic build`** + MCP | Core wedge |

## Harness rows (timed, not composable-only)

| id | workload_class | SOTA reference |
|----|----------------|----------------|
| `game_world_soa_10k` | `world_engine` | SoA ECS tick (DOTS/EnTT-class throughput) |
| `game_replication_encode` | `world_engine` | Replication delta bandwidth (Photon/UE net) |
| `sim_physics_frame` | `world_engine` | Fixed-timestep rigid + substeps (Bullet-class) |

Run:

```bash
python3 benchmarks/harness/bench.py --tier 2 --full --runs 3
python3 benchmarks/harness/validity.py --tier 2 --quick
```

## `gaming_full` vs `v0_gaming`

- **`v0_gaming`** — scaled loop, simplified forces (dashboard honesty).
- **`gaming_full`** — use `bench.py --full` on `cloth_swing`, `rigid_body_stack` (quick/full scales in C).

Do **not** claim engine parity until `world_engine` + `gaming_full` rows are green in ingest with documented SOTA refs ([sota-reference-registry.md](../benchmarks/sota-reference-registry.md)).
