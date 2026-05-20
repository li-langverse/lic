# Competitive engines plan (updated)

**Goal:** Precisely state where Li is vs **HPC references** (C++, NumPy) and vs **engine/framework incumbents** (Unity, Gazebo, OpenFOAM, …), with **validity** (checksums make sense) before speed claims.

## Measurement layers

| Layer | Tool | Pass criteria |
|-------|------|----------------|
| **Correctness compile** | `bench.py --tier 0`, `verify.py` | li-tests + tier-0 `.li` build |
| **Validity (oracles)** | `validity.py` / `bench.py --tier 13` | cpp `--verify`; li bitwise (shared) or tolerance (pure_li); numpy vs cpp tolerance |
| **Performance** | `bench.py --tier 12 --runs 5` | median + stdev in `latest.csv`; dashboard ratio vs cpp |
| **Stability** | `stability.py` | MD energy drift advisory |
| **Engine integration** | `world-studio.toml` composables | import_* gates (not FPS vs Unreal) |

## Standard competitive run (lic)

```bash
# Full suite: strict verify + timing + validity
python3 benchmarks/harness/bench.py --tier 12 --runs 5 --out benchmarks/results/latest.csv

# Validity only (after code/kernel change)
python3 benchmarks/harness/bench.py --tier 13
```

Org ingest + status report (benchmarks repo):

```bash
python3 scripts/ingest/build_summary.py "$LIC_ROOT" "$LIS_ROOT"
python3 scripts/generate_competitive_status.py "$LIC_ROOT"
```

## HPC competitors (in `latest.csv` today)

| `csv_lang` | Role |
|------------|------|
| `cpp` | Reference oracle |
| `rust` / `julia` | Same C binary labels |
| `numpy` | **Required** NumPy port (`numpy_kernels.py`) |
| `li` | Product runtime |

## Engine competitors (registry: `benchmarks/competitive/engines.toml`)

| Incumbent | What we measure **today** | What we do **not** claim |
|-----------|---------------------------|---------------------------|
| Unity / Unreal / Godot | Composable studio/world gates | Micro-harness FPS |
| Gazebo / CARLA | Composable + PDE/nbody proxies | Full robot/scenario parity |
| OpenFOAM / GROMACS | Tier-2 PDE/MD rows + validity | Field-SOTA without external run |
| Bullet / PhysX | v0 rigid/cloth/ragdoll checksums | Production contact stacks |
| Photon / Benchling | Composable smoke | Timed competitive columns |

## Algorithm / workload honesty

- **`workload_class = full`** — use for perf + validity claims vs cpp/numpy.
- **`workload_class = v0_gaming`** — validity = same formulas at harness scale; **not** engine-class physics.
- **`pure_li_stub`** (md `main.li`) — do not compare Li wall time to C MD.

See `benchmarks/tier2_physics/BENCH_WORKLOADS.md`.

## Roadmap (engine-class)

1. **v1 gaming kernels** — SPH density, rigid contact, 2D Euler primitive variables.
2. **External oracle column** — e.g. LAMMPS for `md_lennard_jones` (pinned version).
3. **MMO / bio timed benches** — `mmorpg.toml`, `bioengineering.toml` drivers → `latest.csv`.
4. **End-to-end studies** — studio tick / shard p99 (separate from tier-12 micro).
