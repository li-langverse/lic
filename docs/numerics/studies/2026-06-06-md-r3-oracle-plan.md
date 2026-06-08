# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Agent:** `code_implementer`  
**Mode:** study-only (validity locked; stub honesty)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)

---

## Problem

The sim-md-research runner had **1/3 todos pending**: `md-r3-oracle-plan`. Li tier-2 `md_lennard_jones` has cpp/rust/julia validity via `md_core.c`, but no **Layer B** LAMMPS/GROMACS oracle column plan with CI gate wiring.

---

## Delivered (B0)

| Artifact | Path |
|----------|------|
| Plan doc | `docs/benchmarks/competitive-engines-plan.md` |
| Oracle registry | `benchmarks/competitive/md_oracle.toml` |
| Stub driver | `benchmarks/harness/md_external_oracle.py` |
| Gate script | `scripts/ph-sci-md-oracle-competitive-gates.sh` |
| li-tests cite | `li-tests/tooling/md_external_oracle_stub.sh` + `li-tests/manifest.toml` |
| Study | `docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md` |

**verticals.toml** `md_lennard_jones`: `oracle = external_binary`, `workload_class = v0_micro`.

---

## Learned from (SOTA)

1. **LAMMPS** — `pair/lj/cut` + NVE in reduced units; neighbor lists deferred to B1.  
   - https://docs.lammps.org/Integrators.html  
2. **GROMACS** — grid neighbor search + NVE; deck alignment deferred to B2.  
   - https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html  
3. **Li chem-dft pattern** — `ph-sci-chem-dft.toml` + gate script + README is the template for external oracle honesty.

---

## Grade matrix

| Axis | Result | Notes |
|------|--------|-------|
| Validity | **pass (stub)** | Li micro oracle checksum mirrored in Python |
| Performance | N/A | No perf claims |
| Memory | N/A | — |
| Security | pass | No new FFI |
| Stability | pass | Drift metric documented |
| Size scaling | deferred | B1 uses N=256 FCC |

---

## Tradeoffs

- **Locked:** validity + honesty (`external_binary` stub, no LAMMPS/GROMACS in CI).
- **Improved:** Registry, gate, li-tests manifest cite oracle path; backlog + snapshot updated.
- **Regressed:** none.
- **Not approved:** claiming GROMACS/LAMMPS parity from stub manifest.

---

## Evidence

```bash
bash scripts/ph-sci-md-oracle-competitive-gates.sh   # exit 0
./li-tests/tooling/md_external_oracle_stub.sh        # exit 0
./scripts/check-hpc-competitive.sh                   # exit 0
```

| Type | Path |
|------|------|
| Manifest | `benchmarks/results/md_lennard_jones/oracle_stub.json` |
| Prior survey | `docs/numerics/studies/2026-05-27-md-r0-sota-survey.md` |
| li-tests | `packages/li-sim-scientific/li-tests/smoke/scientific_oracle_bench.li` |
