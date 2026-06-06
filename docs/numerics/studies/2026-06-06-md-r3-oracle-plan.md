# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Agent:** `code_implementer`  
**Mode:** study-only (oracle plan + gate wiring; no perf claims)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)

---

## Problem

`sim-md-research` runner had **1/3 todos pending**: `md-r3-oracle-plan`. Li tier-2 `md_lennard_jones` has a cross-lang C oracle, but Layer B competitive honesty lacked an **external_binary** column for LAMMPS/GROMACS (algo_registry **104** `md_oracle_external`). `verticals.toml` still listed `oracle = "cpp"` with stub notes.

---

## Deliverable (shipped)

| Artifact | Path |
|----------|------|
| Oracle plan doc | `benchmarks/competitive/README-md-oracle.md` |
| Registry / tier-2 manifest | `benchmarks/competitive/ph-sci-md-oracle.toml` |
| Gate script | `scripts/ph-sci-md-oracle-competitive-gates.sh` |
| Bench orchestrator | `scripts/bench-ph-sci-md-oracle-competitive.sh` |
| LAMMPS driver (skip-graceful) | `benchmarks/competitive/lammps_lj_chain_checksum.py` |
| Li workload mirror | `benchmarks/competitive/md_oracle_competitive_common.py` |
| li-tests harness cite | `packages/li-sim-scientific/li-tests/smoke/md_external_oracle_gate.li` |
| Vertical honesty | `benchmarks/competitive/verticals.toml` — `md_lennard_jones` → `external_binary` / `pilot` |

**Workload contract:** 4-atom LJ chain, spacing 1.12, rc=2.5, dt=0.004, 8 velocity-Verlet steps — matches `sim_scientific_oracle_checksum_md()`.

**Gate repro:**

```bash
bash scripts/ph-sci-md-oracle-competitive-gates.sh
# exit 0; writes benchmarks/results/ph-sci-md-oracle-competitive.json
```

---

## Learned from (SOTA)

1. **LAMMPS** — `pair_style lj/cut`, `fix nve`, GPL — primary external oracle when user-installed.  
   - https://docs.lammps.org/pair_lj.html  
   - **Takeaway:** CI cannot bundle; driver skips gracefully with audit note.

2. **GROMACS** — mdrun micro-workloads for NVE drift; LGPL.  
   - https://manual.gromacs.org/current/reference-manual/algorithms/integrators.html  
   - **Takeaway:** stub `external_manual` row until `gromacs_lj_chain_checksum.py` lands.

3. **Chem DFT precedent** — `ph-sci-chem-dft.toml` + PySCF driver pattern informed registry/gate layout.

---

## Size scaling (plan table — not measured this iteration)

| N | Workload | Oracle column | Li action |
|---|----------|---------------|-----------|
| 4 | LJ chain micro | LAMMPS lj/cut pilot | **Shipped** — drift checksum gate |
| 128 | NVE stability | LAMMPS + tier-2 csv | After neighbor list (105) |
| 2048 | Cell list perf | LAMMPS/GROMACS timing | PH-7e after F parity |

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | pass | new gate | Li drift checksum 6.97e-05 ∈ (0, 1e-3) |
| Performance | N/A | — | study-only; no ratio claims |
| Memory | N/A | — | — |
| Security | pass | — | no new trusted C; optional GPL subprocess |
| Stability | pass | — | drift metric locked to NVE micro |
| Size scaling | table attached | — | plan only |

## Tradeoffs

- **Locked:** validity (+ GPL license honesty — no bundled LAMMPS)
- **Improved:** external oracle column plan + gate + verticals.toml + li-tests cite
- **Regressed:** none
