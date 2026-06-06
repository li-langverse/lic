# MD external oracle competitive benchmark

Compare **Li `sim_scientific_oracle_checksum_md()`** (4-particle LJ chain, 8 velocity-Verlet steps) against license-aware MD references (LAMMPS primary; GROMACS planned).

## Run

```bash
# From lic repo root
bash scripts/bench-ph-sci-md-oracle-competitive.sh
# CI gate (bench + JSON + registry path checks)
bash scripts/ph-sci-md-oracle-competitive-gates.sh
```

Output: `benchmarks/results/ph-sci-md-oracle-competitive.json`

## Methodology

| Field | Value |
|-------|-------|
| Geometry | 4-atom chain on x-axis, spacing 1.12 (lj units) |
| Potential | LJ cutoff rc=2.5, ε=σ=1 |
| Integrator | Velocity-Verlet, dt=0.004, 8 steps |
| Metric | Relative energy drift \|E₈−E₀\| / max(\|E\|) — same as `sim_scientific_oracle_checksum_md()` |
| Li kernel | `packages/li-sim-scientific/src/lib.li` — brute O(N²) MIC forces |
| LAMMPS | `pair_style lj/cut 2.5`, `fix nve` — **GPL external oracle** |
| GROMACS | **Planned** — `grompp`/`mdrun` micro-workload stub row (LGPL, user-run) |

## License notes

- **LAMMPS** — GPL-2.0-only; **not** bundled in CI. Gate runs driver when `lmp`/`lammps` is on `PATH`, otherwise records skip note and validates Li/python mirror checksum.
- **GROMACS** — LGPL; external_manual row until `gromacs_lj_chain_checksum.py` driver lands.
- **Tier-2 C oracle** — `benchmarks/tier2_physics/md_lennard_jones` (separate repo) remains cross-lang validity reference; this competitive suite is Layer B honesty for **external_binary** column (algo_registry **104** `md_oracle_external`).

## Expected parity gaps

Until neighbor lists and full 3D MIC parity ship, Li vs LAMMPS drift may differ slightly on the micro chain (2D vs 3D box, float order). `drift_tolerance` (0.001) in `ph-sci-md-oracle.toml` gates relative drift when both sides execute.

## Gate reference

| Path | Role |
|------|------|
| `scripts/ph-sci-md-oracle-competitive-gates.sh` | CI gate — JSON + registry + Li checksum |
| `benchmarks/competitive/ph-sci-md-oracle.toml` | Registry / tier-2 manifest |
| `benchmarks/competitive/lammps_lj_chain_checksum.py` | LAMMPS driver (skip-graceful) |
| `packages/li-sim-scientific/li-tests/smoke/md_external_oracle_gate.li` | li-tests harness cites oracle gate path |

## Manual LAMMPS workflow

```bash
# Ubuntu/Debian example (not automated in repo)
sudo apt install lammps
bash scripts/ph-sci-md-oracle-competitive-gates.sh
```

Import pattern: merge `competitors[id=lammps].energy_drift_checksum` into `ph-sci-md-oracle-competitive.json` after local run.

## PH ids

- **PH-5b** — proved numerics / energy drift honesty
- **G-math** — simulation correctness without unverified shortcuts
