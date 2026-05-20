# UE5 baseline samples (Li world_engine comparison)

Run **real Unreal Engine 5** timings for the same workloads as `benchmarks/tier2_world/` and feed `import_ue_baseline.py`.

## Requirements

- UE **5.3+** on Linux or Windows (Mac: editor only)
- `UE_ROOT` → engine install (contains `Engine/Binaries/.../UnrealEditor-Cmd`)
- Optional reference project: [Sleicreider/UE5MassTest](https://github.com/Sleicreider/UE5MassTest) for Mass crowd parity

## Quick run

```bash
export UE_ROOT=/path/to/UE_5.4
./scripts/run-ue-samples.sh
./scripts/publish-benchmarks-ingest.sh   # merges ue-baselines into dashboard
```

Outputs:

- `benchmarks/competitive/ue-baselines.csv` — manual UE timings
- `benchmarks/competitive/ue-baselines-merged.json` — Li vs UE vs proxy

## Scenarios (map to Li harness)

| UE sample | Li benchmark | What to measure |
|-----------|--------------|-----------------|
| `LiMass10k` map | `game_world_soa_10k` | Mass / ISM tick, `stat unit` Game thread |
| `LiReplication` | `game_replication_encode` | Net serialize test map |
| `LiPhysicsFrame` | `sim_physics_frame` | Chaos rigid substep, `stat Physics` |

## Install UE on Linux (developer machine)

1. Link GitHub to Epic Games account.
2. Clone engine (private): `git clone -b 5.4.4-release https://github.com/EpicGames/UnrealEngine.git`
3. `./Setup.sh && ./GenerateProjectFiles.sh && make`

Or install via Epic Launcher → Linux UE 5.4 → set `UE_ROOT`.

## CI (self-hosted)

Workflow `.github/workflows/ue-baseline.yml` runs on label `unreal-engine`. Add a runner with UE installed and secret `UE_ROOT`.

**This cloud agent cannot run UE** (no engine binary, no Epic token, no Docker). Merge PRs and run samples on a UE-capable machine.
