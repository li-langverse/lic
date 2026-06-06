# Competitive engines plan (domain MD oracles)

**Status:** Active (rev. 2 — 2026-06-06)  
**Audience:** Benchmark maintainers, sim-md-research agents  
**Related:** [competitive-landscape.md](competitive-landscape.md) · `benchmarks/competitive/registry.toml` · `benchmarks/competitive/md_oracle.toml` · [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md) · [2026-06-04-md-r3-oracle-plan.md](../superpowers/plans/2026-06-04-md-r3-oracle-plan.md)

Layer A in the HPC registry tracks **language runtimes** (cpp, rust, julia, li). This plan adds **Layer B domain engines** — LAMMPS and GROMACS — as **external oracle** columns for tier-2 `md_lennard_jones` / catalog id `md_oracle_external` (algo 104), without claiming production parity.

---

## 1. Goal

| Today | Target (Wave B / md-r3) |
|-------|-------------------------|
| cpp/rust/julia share `md_core.c`; Li uses `sim_scientific_oracle_checksum_md()` | Same + **`lammps`** and **`gromacs`** CSV `lang` rows for **validity** (energy drift) |
| `verticals.toml` `md_lennard_jones` notes admit Layer B stubs | `md_oracle.toml` pins + gate script in lic |
| No harness manifest for external oracle | `li-tests` cites `md_external_oracle_bench.li` + gate script |

**Not in scope (this slice):** LAMMPS/GROMACS on default CI; full input-deck parity; MPI scaling.

---

## 2. Workload contract

Canonical parameters live in the **benchmarks** repo: `tier2_physics/md_lennard_jones/params.toml` and `common/md_core.h`.

| Field | Value | Notes |
|-------|-------|-------|
| N | 256 | FCC lattice fill |
| steps | 10_000 | Perf kernel |
| dt | 0.004 | Reduced LJ units |
| rc | 2.5 | Cutoff |
| box | 10.0 | Cubic MIC |
| seed | 7 | PCG init |
| potential | LJ 12-6 | Matches `md_core.c` |
| integrator | Velocity Verlet | NVE |

**Validity (T0):** `sim_scientific_oracle_checksum_md()` ↔ shared C oracle (always green in lic).  
**External (T2):** LAMMPS/GROMACS micro — optional profile `md-external-oracle`; stub until B1/B2.

---

## 3. Registry files (lic)

| File | Role |
|------|------|
| `benchmarks/competitive/md_oracle.toml` | Oracle pins, drivers, `workload_class`, status |
| `benchmarks/competitive/registry.toml` | `lammps_lj_micro` / `gromacs_lj_micro` on **watch** |
| `benchmarks/competitive/README-md-oracle.md` | Tier-2 catalog path contract |
| `scripts/md-oracle-competitive-gates.sh` | CI gate (registry + manifest + stub) |

Benchmarks repo (sibling checkout) owns `tier2_physics/md_oracle_external/` and `harness/md_external_oracle.py`.

---

## 4. Gate script reference

```bash
# Lic-side gate (no LAMMPS/GROMACS required)
./scripts/md-oracle-competitive-gates.sh

# Research loop completion (study-only)
SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh

# Harness manifest cites oracle path
grep -E 'md_external_oracle|md_oracle_external' \
  packages/li-sim-scientific/li-tests/manifest.toml li-tests/manifest.toml
```

---

## 5. Roadmap

| Phase | Deliverable | Exit evidence |
|-------|-------------|---------------|
| **B0 (md-r3)** | Plan + `md_oracle.toml` + lic gate + li-test smoke | Gates green; backlog todo completed |
| **B1** | LAMMPS micro deck (benchmarks repo) | `lang=lammps` validity row |
| **B2** | GROMACS `gmx mdrun` micro | `lang=gromacs` validity row |
| **B3** | Catalog ingest benchmarks#179 | `md_oracle_external` non-stub |

---

## 6. Agent rules

- Do **not** weaken `threshold_ratio_cpp` or claim GROMACS/LAMMPS parity from stub rows.
- Update `last_reviewed` in `md_oracle.toml` on quarterly SOTA review.
- Validity locked before PH-7e SIMD on MD force loops.
