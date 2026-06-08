# Competitive engines plan (domain MD oracles)

**Status:** Active (rev. 1 — 2026-06-06)  
**Audience:** Benchmark maintainers, MD research/implement agents  
**Related:** [competitive-landscape.md](competitive-landscape.md) · `benchmarks/competitive/registry.toml` · `benchmarks/competitive/md_oracle.toml` · [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md) · [md-r3 study](../numerics/studies/2026-06-06-md-r3-oracle-plan.md)

Layer A in the HPC registry tracks **language runtimes** (cpp, rust, julia, li). This plan adds **Layer B domain engines** — LAMMPS and GROMACS — as **external oracle** columns for tier-2 `md_lennard_jones`, without claiming production parity.

---

## 1. Goal

| Today | Target (Wave B / md-r3) |
|-------|-------------------------|
| cpp/rust/julia share `md_core.c` reference | Same + **honest external column plan** |
| `verticals.toml` `md_lennard_jones` oracle = `cpp` | Li internal oracle documented; LAMMPS/GROMACS on **watch/stub** |
| No domain oracle manifest in CI | Stub manifest via `md_external_oracle.py` (no binary required) |
| Algo 104 `md_oracle_external` catalog stub | Registry row + gate script reference |

**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty). External binaries are **optional** in CI; stub mode records the contract and pinned versions.

---

## 2. Workload contract (aligned with Li oracle)

Micro workload shared by Li `sim_scientific_oracle_checksum_md()` and future LAMMPS/GROMACS drivers:

| Parameter | Value |
|-----------|-------|
| Particles | 4 (1D chain) |
| Initial spacing | 1.12 σ |
| LJ cutoff | rc = 2.5 σ |
| Integrator | Velocity-Verlet, dt = 0.004 |
| Steps | 8 |
| Gate metric | Relative energy drift \|E₁ − E₀\| / max(\|E₀\|, \|E₁\|, 1e-12) |
| Li reference | `packages/li-sim-scientific` — `sim_scientific_oracle_checksum_md()` |

Full tier-2 `md_lennard_jones` harness (when present in checkout) uses the same `md_core.c` kernel; the external oracle stub does **not** require LAMMPS/GROMACS on PATH.

---

## 3. Registry and driver paths

| Artifact | Path |
|----------|------|
| Oracle registry | `benchmarks/competitive/md_oracle.toml` |
| Stub driver (Python) | `benchmarks/harness/md_external_oracle.py` |
| Shell entry | `benchmarks/tier2_physics/md_lennard_jones/external/run_oracle_stub.sh` |
| Manifest output | `benchmarks/results/md_lennard_jones/oracle_stub.json` |
| Gate (scripts) | `scripts/check-md-oracle-plan.sh` |
| Gate (li-tests) | `li-tests/tooling/md_external_oracle_stub.sh` |
| Tier-2 smoke cite | `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li` |

Validate registry:

```bash
./scripts/check-hpc-competitive.sh
./scripts/check-md-oracle-plan.sh
./li-tests/tooling/md_external_oracle_stub.sh
```

---

## 4. CSV column roadmap (B0 → B3)

| Phase | Status | Deliverable |
|-------|--------|-------------|
| **B0** | **shipped** | Plan doc + `md_oracle.toml` + stub manifest gate |
| **B1** | pending | LAMMPS input deck matching micro workload; optional `LI_MD_ORACLE_LAMMPS=1` |
| **B2** | pending | GROMACS `.mdp` + `.gro`; energy drift column in competitive JSON |
| **B3** | pending | `latest.csv` columns `lammps`, `gromacs`; validity parity gate (not perf) |

**Honesty:** Until B3, registry rows stay `track = watch`, `kernel_honesty = external_binary`, `csv_lang = ""`.

---

## 5. Pins (local real-driver runs)

Copy `benchmarks/tier2_physics/md_lennard_jones/external/pins.env.example` → `pins.env` (gitignored). Pins must match `md_oracle.toml`:

- LAMMPS `2024.06.27` (`stable_22Jun2024`)
- GROMACS `2024.2` (`v2024.2`)

Set `LI_MD_ORACLE_LAMMPS=1` / `LI_MD_ORACLE_GROMACS=1` only on maintainer machines with binaries installed.

---

## 6. Anti-patterns

| Avoid | Instead |
|-------|---------|
| Claiming LAMMPS/GROMACS parity from stub manifest | Label `workload_class = v0_micro`, `status = stub` |
| Requiring domain binaries in default CI | Stub gate + optional env flags |
| Weakening Li internal oracle for external match | External column is additive honesty |
| JSONC-only oracle gate | Strict `oracle_stub.json` manifest |

---

## 7. Cross-links

- Issue: [lic#523](https://github.com/li-langverse/lic/issues/523) (`md-r3-oracle-plan`)
- Research backlog: `docs/ecosystem/sim-md-research-backlog.md`
- Output contract: `docs/ecosystem/sim-output-contract.md` (cites `md_external_oracle.py`)
- WP-PLAT-05: `data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md`
