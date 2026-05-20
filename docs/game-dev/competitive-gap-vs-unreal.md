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

Run (focused world + gaming kernels):

```bash
./scripts/run-world-benches.sh
# or:
python3 benchmarks/harness/bench.py --tier 2 --quick --runs 3 \
  --only game_world_soa_10k,game_replication_encode,sim_physics_frame,cloth_swing,rigid_body_stack
```

Latest captured timings: [`benchmarks/competitive/world-engine-latest.json`](../../benchmarks/competitive/world-engine-latest.json) (regenerate with the script above).

| Bench | Scale | cpp (median) | li (median) | Validity @ quick |
|-------|-------|----------------|-------------|------------------|
| `game_world_soa_10k` | full 10k×600 | 0.8 ms | 0.6 ms | PASS (checksum 6144000) |
| `game_replication_encode` | full 1k×500 | 1.1 ms | 0.7 ms | PASS |
| `sim_physics_frame` | full 12×2000 | 0.8 ms | 0.6 ms | PASS |
| `cloth_swing` | full 16×8k | 4.7 ms | 4.7 ms | PASS |
| `rigid_body_stack` | full 50×2k | 0.6 ms | 0.4 ms | PASS |

## `gaming_full` vs `v0_gaming`

- **`v0_gaming`** — scaled loop, simplified forces (dashboard honesty).
- **`gaming_full`** — use `bench.py --full` on `cloth_swing`, `rigid_body_stack` (quick/full scales in C).

Do **not** claim engine parity until `world_engine` + `gaming_full` rows are green in ingest with documented SOTA refs ([sota-reference-registry.md](../benchmarks/sota-reference-registry.md)).
