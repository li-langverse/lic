# Competitive engines plan (domain MD oracles)

**Status:** Active (rev. 1 — 2026-06-06)  
**Audience:** Benchmark maintainers, sim-md-research agents  
**Related:** [competitive-landscape.md](competitive-landscape.md) · `benchmarks/competitive/md_oracle.toml` · [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md)  
**Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523) · **PH:** PH-5b, G-math

Layer A in the HPC registry tracks **language runtimes** (cpp, rust, julia, li). This plan adds **Layer B domain engines** — LAMMPS and GROMACS — as **external oracle** columns for tier-2 `md_lennard_jones`, without claiming production parity.

---

## 1. Goal

| Today | Target (Wave B) |
|-------|-----------------|
| cpp/rust/julia share `md_core.c`; Li has pure driver | Same + **`lammps`** and **`gromacs`** CSV `lang` rows for **validity** (energy drift), optional **perf** later |
| No pinned domain tool version | Pinned releases in `md_oracle.toml` |
| Marketing risk on GROMACS parity | `workload_class = v0_micro`, `oracle = external_binary`, honesty in PERF.md |

**Not in scope (this slice):** full GROMACS/LAMMPS input decks matching FCC IC + velocity MB exactly; MPI strong scaling; biomolecular force fields.

---

## 2. Workload contract (`md_lennard_jones`)

Canonical parameters (external benchmarks repo `tier2_physics/md_lennard_jones/`):

| Field | Value | Notes |
|-------|-------|-------|
| N | 256 | FCC lattice fill |
| steps | 10_000 | Perf kernel |
| dt | 0.004 | Reduced LJ units |
| rc | 2.5 | Cutoff |
| box | 10.0 | Cubic MIC |
| seed | 7 | PCG init |
| potential | LJ 12-6 | No shift (matches `md_core.c`) |
| integrator | Velocity Verlet | NVE |

**Li micro oracle (in-repo today):** `sim_scientific_oracle_checksum_md()` — 4-particle LJ chain, 8 velocity-Verlet steps (`packages/li-sim-scientific/src/lib.li`). Used by `scientific_oracle_bench.li` and `run_algo_registry_tier2.li`.

**External oracle metric (planned):** same drift definition on final total energy after mapping LAMMPS/GROMACS output to reduced units; tolerance TBD when real drivers land (start advisory ±1e-3 vs native reference).

---

## 3. CSV columns (future `latest.csv`)

| `lang` | `kernel_honesty` | Row type | Driver |
|--------|------------------|----------|--------|
| `cpp` | `reference_native` | perf + validity | `md_main.c` |
| `rust` / `julia` | `shared_c_kernel` | perf | same binary as cpp |
| `li` | `pure_li` (perf) / mixed | perf + validity | `li/main.li` |
| **`lammps`** | **`external_binary`** | **validity first** | `md_external_oracle.py` → LAMMPS input |
| **`gromacs`** | **`external_binary`** | **validity first** | stub → `.mdp` + `gmx mdrun` |

Perf wall-time comparison to LAMMPS/GROMACS is **out of scope** until workloads are provably equivalent (same IC, same LJ parameters, same neighbor list policy).

---

## 4. Registry files

| File | Role |
|------|------|
| `benchmarks/competitive/registry.toml` | HPC ecosystems; `lammps_lj_micro` / `gromacs_lj_micro` on **watch** |
| `benchmarks/competitive/md_oracle.toml` | Oracle pins, drivers, `workload_class`, status (`stub` → `active`) |
| `benchmarks/harness/md_external_oracle.py` | Stub driver + manifest writer |

Validate:

```bash
./scripts/ph-sci-md-oracle-competitive-gates.sh
./li-tests/tooling/md_external_oracle_stub.sh
./scripts/check-hpc-competitive.sh
```

---

## 5. Stub driver (v0)

`benchmarks/harness/md_external_oracle.py`:

1. Mirror Li oracle checksum (`sim_scientific_oracle_checksum_md` contract).
2. Record stub manifest under `benchmarks/results/md_lennard_jones/oracle_stub.json`.
3. If `LI_MD_ORACLE_LAMMPS=1` and `lammps` on PATH → exit 2 with "not implemented" (reserved for B1).
4. Default (CI): exit 0 — **stub ok**, no domain binary required.

This matches the chem-dft pattern: external tool is the long-term truth source; harness ships a stub until pins and decks are aligned.

---

## 6. Implementation roadmap

| Phase | Deliverable | Exit evidence |
|-------|-------------|---------------|
| **B0 (this PR)** | Plan doc + `md_oracle.toml` + stub driver + li-test | `md_external_oracle_stub.sh` green |
| **B1** | LAMMPS micro deck matching FCC+MB (same drift ±ε) | `lang=lammps` validity row in `latest.csv` |
| **B2** | GROMACS `mdrun` micro (pinned 2024.x) | `lang=gromacs` validity row |
| **B3** | `verticals.toml` row `md_lennard_jones` → `pilot` | algorithms plan Layer B complete |

---

## 7. Agent rules

- Do **not** publish "faster than GROMACS" from stub or mismatched workloads.
- Run `./scripts/bench-verify-results.sh 2` when touching `md_core.c` or oracle mapping (external benchmarks repo).
- Update `last_reviewed` in `md_oracle.toml` on quarterly SOTA review.
- File **G-*** master-plan items if oracle requires trusted FFI or new proof obligations.

---

## 8. Commands

```bash
# Stub manifest (no LAMMPS/GROMACS required)
python3 benchmarks/harness/md_external_oracle.py

# CI gate
bash scripts/ph-sci-md-oracle-competitive-gates.sh

# li-tests wiring
./li-tests/tooling/md_external_oracle_stub.sh
```
