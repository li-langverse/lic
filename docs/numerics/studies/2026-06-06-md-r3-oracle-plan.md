# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)  
**Agent:** `code_implementer` · **Mode:** study-only (validity locked; external oracle stub)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Preflight:** sim-md-research runner `md-r3-oracle-plan` pending

---

## Problem

The sim-md-research loop completed SOTA survey (`md-r0`) and neighbor-list gap analysis (`md-r2`), but **no shipped plan** for LAMMPS/GROMACS as external validity columns on `md_lennard_jones`. Registry algo **104** (`md_oracle_external`) and `verticals.toml` listed stub honesty only.

---

## Learned from (SOTA)

1. **LAMMPS** — `pair/lj/cut` + NVE is the incumbent micro-workload for reduced-unit LJ benchmarks.  
   - https://docs.lammps.org/Integrators.html  
   - **Takeaway:** pin `stable_22Jun2024` (2024.06.27) for reproducible validity rows.

2. **GROMACS** — grid neighbor search + velocity-Verlet; energy drift is the standard validity metric for integrator acceptance.  
   - https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html  
   - **Takeaway:** pin `v2024.2`; defer perf comparison until IC/deck parity with `md_core.c`.

3. **Li internal oracle** — `sim_scientific_oracle_checksum_md()` (4-particle LJ chain, 8 VV steps) is the **today** reference; external columns are **validity witnesses**, not perf targets.

4. **Chem-dft competitive pattern** — `ph-sci-chem-dft.toml` + gate script + li-tests manifest citation is the template for domain oracle columns without requiring domain binaries in CI.

---

## Deliverable (B0)

| Artifact | Path |
|----------|------|
| Plan doc | `docs/benchmarks/competitive-engines-plan.md` |
| Oracle registry | `benchmarks/competitive/md_oracle.toml` |
| Gate script | `scripts/check-md-oracle.sh` |
| Stub bench | `scripts/bench-md-external-oracle-stub.sh` |
| li-tests gate | `li-tests/tooling/md_external_oracle_stub.sh` |
| Smoke witness | `packages/li-sim-scientific/li-tests/smoke/md_external_oracle_plan.li` |
| Input skeletons | `benchmarks/competitive/external/lammps_mdlj.lammps`, `gromacs_mdlj.mdp` |

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | pass | new | Li internal oracle unchanged; stub manifest records registry path |
| Performance | N/A | — | External perf deferred to B1/B2 |
| Memory | N/A | — | — |
| Security | skip | — | No new FFI; stub only |
| Stability | pass | — | Same Li oracle checksum bounds |
| Size scaling | deferred | — | B1 uses N=256 FCC micro |

## Tradeoffs

- **Locked:** validity (+ stability for MD integrators); no "faster than GROMACS" claims from stub.
- **Improved:** Layer B oracle registry + gate + li-tests citation closes md-r3-oracle-plan plan debt.
- **Regressed:** none.

---

## Commands

```bash
./scripts/check-md-oracle.sh
./scripts/bench-md-external-oracle-stub.sh
./li-tests/tooling/md_external_oracle_stub.sh
```

When benchmarks submodule is present:

```bash
./scripts/bench-verify-results.sh 2
```

---

## Deferred (B1–B3)

- LAMMPS deck aligned with `md_core.c` FCC+MB IC → `lang=lammps` validity row.
- GROMACS `gmx mdrun` micro → `lang=gromacs` validity row.
- `verticals.toml` oracle field upgrade from `cpp` to `external_binary` when real rows land.
