# Competitive engines plan (domain MD oracles)

**Status:** Active (rev. 1 — 2026-06-07)  
**Audience:** Benchmark maintainers, Wave B physics agents  
**Related:** [competitive-landscape.md](competitive-landscape.md) · `benchmarks/competitive/registry.toml` · `benchmarks/competitive/md_oracle.toml` · [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md)

Layer A in the HPC registry tracks **language runtimes** (cpp, rust, julia, li). This plan adds **Layer B domain engines** — LAMMPS and GROMACS — as **external oracle** columns for tier-2 `md_lennard_jones`, without claiming production parity.

---

## 1. Goal

| Today | Target (Wave B) |
|-------|-----------------|
| cpp/rust/julia share `md_core` C oracle | Li native `sim_scientific_oracle_checksum_md()` is tier-2 reference |
| No LAMMPS/GROMACS csv column | `lammps` / `gromacs` columns in competitive JSON + `md_oracle.toml` registry |
| `workload_class = stub` honesty | Stub columns record reference drift; B1 activates real binaries |

---

## 2. Workload contract

Aligned with `packages/li-sim-scientific/src/lib.li` (`sim_scientific_oracle_checksum_md`):

| Parameter | Value |
|-----------|-------|
| Particles | 4 (1D chain) |
| Initial spacing | 1.12 |
| Integrator | Velocity-Verlet |
| Steps | 8 |
| Timestep | 0.004 |
| LJ cutoff | rc = 2.5 (rc² = 6.25) |
| Metric | Normalized energy drift \|E₁ − E₀\| / max(\|E₀\|, \|E₁\|, 1e-12) |

---

## 3. Registry artifacts

| File | Role |
|------|------|
| `benchmarks/competitive/md_oracle.toml` | Pinned LAMMPS/GROMACS versions, csv_lang, status |
| `benchmarks/competitive/md_competitive_common.py` | Python mirror of Li oracle (CI without benchmarks repo) |
| `scripts/bench-ph-sci-md-competitive.sh` | Produces `benchmarks/results/ph-sci-md-competitive.json` |
| `scripts/ph-sci-md-competitive-gates.sh` | CI gate — Li drift valid, external columns stub-honest |

---

## 4. Roadmap phases

| Phase | Status | Deliverable |
|-------|--------|-------------|
| **B0** | **landed (WP-PLAT-05)** | `md_oracle.toml` + stub drivers + competitive JSON |
| **B1** | open | LAMMPS `pair/lj/cut` micro input matching workload contract |
| **B2** | open | GROMACS equivalent micro + validity row in `latest.csv` |
| **B3** | open | 1.2× wall-time policy gate vs Li native |

---

## 5. Environment flags

```bash
# Optional local B1 attempts (CI leaves unset):
export LI_MD_ORACLE_LAMMPS=1   # requires `lmp` on PATH
export LI_MD_ORACLE_GROMACS=1  # requires `gmx` or `gmx_mpi` on PATH
```

Pins must match `benchmarks/competitive/md_oracle.toml`.

---

## 6. Verification

```bash
bash scripts/ph-sci-md-competitive-gates.sh
./scripts/check-hpc-competitive.sh
```
