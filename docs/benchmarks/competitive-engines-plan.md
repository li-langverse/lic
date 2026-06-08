# Competitive engines plan (domain MD oracles)

**Status:** Active (rev. 2 — 2026-06-06)  
**Audience:** Benchmark maintainers, sim-md-research agents  
**Related:** [competitive-landscape.md](competitive-landscape.md) · `benchmarks/competitive/registry.toml` · `benchmarks/competitive/md_oracle.toml` · [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md)

Layer A in the HPC registry tracks **language runtimes** (cpp, rust, julia, li). This plan adds **Layer B domain engines** — LAMMPS and GROMACS — as **external oracle** columns for tier-2 `md_lennard_jones`, without claiming production parity.

---

## 1. Goal

| Today | Target (Wave B / md-r3) |
|-------|-------------------------|
| cpp/rust/julia share `md_core.c`; Li has pure driver | Same + **`lammps`** and **`gromacs`** CSV `lang` rows for **validity** (energy drift), optional **perf** later |
| No pinned domain tool version | Pinned releases in `md_oracle.toml` |
| Marketing risk on GROMACS parity | `workload_class = v0_micro`, `oracle = external_binary`, honesty in PERF.md |

**Not in scope (this slice):** full GROMACS/LAMMPS input decks matching FCC IC + velocity MB exactly; MPI strong scaling; biomolecular force fields.

---

## 2. Workload contract (`md_lennard_jones`)

Canonical parameters (when `benchmarks/tier2_physics/md_lennard_jones` is present in the benchmarks submodule):

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

**Li internal oracle (today):** `sim_scientific_oracle_checksum_md()` — 4-particle LJ chain, 8 velocity-Verlet steps in `packages/li-sim-scientific`.

**External oracle metric (planned):** same drift definition on final total energy after mapping LAMMPS/GROMACS output to reduced units; tolerance TBD when real drivers land (start advisory ±1e-3 vs native reference).

---

## 3. CSV columns (future `latest.csv`)

| `lang` | `kernel_honesty` | Row type | Driver |
|--------|------------------|----------|--------|
| `cpp` | `reference_native` | perf + validity | `md_main.c` |
| `rust` / `julia` | `shared_c_kernel` | perf | same binary as cpp |
| `li` | `pure_li` (perf) / mixed | perf + validity | `li/main.li` |
| **`lammps`** | **`external_binary`** | **validity first** | `scripts/bench-md-external-oracle-stub.sh` → LAMMPS input |
| **`gromacs`** | **`external_binary`** | **validity first** | stub → `.mdp` + `gmx mdrun` |

Perf wall-time comparison to LAMMPS/GROMACS is **out of scope** until workloads are provably equivalent (same IC, same LJ parameters, same neighbor list policy).

---

## 4. Registry files

| File | Role |
|------|------|
| `benchmarks/competitive/registry.toml` | HPC ecosystems; `lammps_lj_micro` / `gromacs_lj_micro` on **watch** |
| `benchmarks/competitive/md_oracle.toml` | Oracle pins, drivers, `workload_class`, status (`stub` → `active`) |
| `benchmarks/competitive/external/` | LAMMPS/GROMACS input skeletons, pin template |

Validate:

```bash
./scripts/check-md-oracle.sh
./li-tests/tooling/md_external_oracle_stub.sh
```

---

## 5. Stub driver (v0)

`scripts/bench-md-external-oracle-stub.sh`:

1. Validate `md_oracle.toml` schema via `check-md-oracle.sh`.
2. Record stub manifest under `benchmarks/results/md-external-oracle-stub.json` citing Li internal oracle checksum range.
3. If `LI_MD_ORACLE_LAMMPS=1` and `lammps` on PATH → exit 2 with "not implemented" (reserved for B1 driver).
4. Default (CI): exit 0 — **stub ok**, no domain binary required.

This matches the chem-dft competitive pattern: external tool is the long-term truth source; harness ships a stub until pins and decks are aligned.

---

## 6. Implementation roadmap

| Phase | Deliverable | Exit evidence |
|-------|-------------|---------------|
| **B0 (md-r3-oracle-plan)** | Plan doc + `md_oracle.toml` + stub driver + li-test | `md_external_oracle_stub.sh` green |
| **B1** | LAMMPS micro deck matching FCC+MB (same drift ±ε) | `lang=lammps` validity row in `latest.csv` |
| **B2** | GROMACS `mdrun` micro (pinned 2024.x) | `lang=gromacs` validity row |
| **B3** | `verticals.toml` row `sim_scientific` / MD | algorithms plan Layer B complete |

---

## 7. Agent rules

- Do **not** publish "faster than GROMACS" from stub or mismatched workloads.
- Run `./scripts/bench-verify-results.sh 2` when touching `md_core.c` or oracle mapping.
- Update `last_reviewed` in `md_oracle.toml` on quarterly SOTA review.
- File **G-*** master-plan items if oracle requires trusted FFI or new proof obligations.

---

## 8. Commands

```bash
# Stub manifest (no LAMMPS/GROMACS required)
./scripts/bench-md-external-oracle-stub.sh

# Registry + oracle gate
./scripts/check-md-oracle.sh

# li-tests harness citation
./li-tests/tooling/md_external_oracle_stub.sh
```
