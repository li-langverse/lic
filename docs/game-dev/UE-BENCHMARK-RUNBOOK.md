# UE5 benchmark runbook (Li `world_engine` comparison)

Run this on **your machine** with a real Unreal Engine install. Cloud agents cannot run UE (no Epic binary/token).

## 1. Prerequisites

| Requirement | Notes |
|-------------|--------|
| **UE 5.3+** | Linux or Windows editor; Mac editor-only |
| **Epic ↔ GitHub** | Linked for `EpicGames/UnrealEngine` clone |
| **`UE_ROOT`** | Points at engine root (`Engine/Binaries/.../UnrealEditor-Cmd`) |
| **`lic` repo** | This monorepo at `main` with World Studio merge |

### Install UE (Linux example)

```bash
# After linking Epic account to GitHub:
git clone -b 5.4.4-release https://github.com/EpicGames/UnrealEngine.git ~/UE_5.4
cd ~/UE_5.4 && ./Setup.sh && ./GenerateProjectFiles.sh && make
export UE_ROOT=~/UE_5.4
```

Or Epic Launcher → Install UE 5.4 Linux → set `UE_ROOT` to the launcher path.

## 2. One-command capture (sample project)

```bash
cd /path/to/lic
export UE_ROOT=/path/to/UE_5.4

./scripts/run-ue-samples.sh
```

**Outputs:**

| File | Purpose |
|------|---------|
| `benchmarks/competitive/ue-baselines.csv` | Manual UE timings (CSV) |
| `benchmarks/competitive/ue-baselines-merged.json` | Li vs UE vs proxy budgets |
| `samples/ue5-li-baseline/.../Saved/LiBenchmark.csv` | Raw UE write (if GameMode ran) |
| `benchmarks/results/ue_sample.log` | Fallback parse from `stat unit` |

Default project: `samples/ue5-li-baseline/LiWorldBenchmark/LiWorldBenchmark.uproject`  
Optional Mass reference: clone [UE5MassTest](https://github.com/Sleicreider/UE5MassTest) as sibling `../UE5MassTest` — script auto-picks it if present.

## 3. Map UE workloads → Li harness

| Li `benchmark` id | UE sample / measurement | Li timed kernel |
|-------------------|----------------------|-----------------|
| `game_world_soa_10k` | `LiBenchmarkCapture` CPU loop 10k×600 | `tier2_world/game_world_soa_10k` |
| `game_replication_encode` | Net test map / serialize stat | `tier2_world/game_replication_encode` |
| `sim_physics_frame` | Chaos rigid, `stat Physics` | `tier2_world/sim_physics_frame` |
| `render_frame_present` | GPU/RenderThread present | `tier2_world/render_frame_present` |

### Manual CSV (if automation only captures one row)

Edit `benchmarks/competitive/ue-baselines.csv`:

```csv
benchmark,subsystem,wall_time_ms,source,ue_version,notes
game_world_soa_10k,ECS tick,2.10,UE Insights,5.4,Your project
game_replication_encode,Net encode,0.45,stat net,5.4,
sim_physics_frame,Chaos frame,3.20,stat Physics,5.4,
render_frame_present,RHI present,6.50,stat GPU,5.4,
```

Then:

```bash
python3 benchmarks/harness/import_ue_baseline.py --csv benchmarks/competitive/ue-baselines.csv
```

## 4. Publish Li timings + org dashboard

```bash
# Li side (your machine or CI)
./scripts/run-world-benches.sh
./scripts/publish-benchmarks-ingest.sh
```

If you maintain the org **`benchmarks`** repo:

```bash
export BENCHMARKS_ROOT=/path/to/benchmarks
./scripts/publish-benchmarks-ingest.sh   # copies incoming + runs ingest
cd "$BENCHMARKS_ROOT" && python3 scripts/ingest/build_summary.py
```

## 5. Editor / Insights workflow (optional, higher fidelity)

1. Open `LiWorldBenchmark.uproject` in UE Editor.
2. Play In Editor (PIE) with `ALiBenchmarkGameMode` as default game mode.
3. **Window → Developer Tools → Session Frontend → Profiler** (or `stat unit`, `stat Physics`, `stat GPU`).
4. Export frame ms → add rows to `ue-baselines.csv`.
5. Re-run `import_ue_baseline.py`.

## 6. CI (self-hosted runner)

Workflow: `.github/workflows/ue-baseline.yml`  
Label runner with `unreal-engine` and set secret/env `UE_ROOT`.

## 7. Honest claims checklist

| OK | Not OK |
|----|--------|
| “Li median X ms on `game_world_soa_10k` with validity PASS” | “Faster than Unreal” without `ue-baselines.csv` |
| “Under UE proxy budget on micro-kernel” | Proxy budget = measured UE in CI |
| “UE measured Y ms on sample project (local CSV)” | Publishing proxy JSON as UE results |

## 8. Troubleshooting

| Problem | Fix |
|---------|-----|
| `Unreal Editor not found` | Set `UE_ROOT`; verify `Engine/Binaries/.../UnrealEditor-Cmd` is executable |
| Empty `ue-baselines.csv` | Run PIE once; check `Saved/LiBenchmark.csv`; or fill CSV manually |
| Build fails on sample | Install UE matching `.uproject` engine association |
| No GitHub UE clone access | Use Epic Launcher install only |

See also: [samples/ue5-li-baseline/README.md](../../samples/ue5-li-baseline/README.md), [competitive-gap-vs-unreal.md](competitive-gap-vs-unreal.md).
