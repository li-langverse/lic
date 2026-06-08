# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)  
**Agent:** `code_implementer` · **Mode:** study-only (validity locked; no external binary required)  
**North star:** PH-5b, G-math (simulation correctness honesty)  
**Preflight:** `sim-md-research` runner — completed `md-r0`, `md-r1`, `md-r2`; pending `md-r3`

---

## Problem

Li tier-2 MD uses an internal Li oracle (`sim_scientific_oracle_checksum_md()` — 4-particle LJ chain, 8 VV steps). The competitive registry tracks **language** columns (cpp/rust/julia/li) but not **domain engines** (LAMMPS/GROMACS). Algo registry id **104** (`md_oracle_external`) and `verticals.toml` `md_lennard_jones` lacked an honest external-oracle plan with CI gate reference.

**Ask (issue #523):** Ship oracle plan doc + gate script reference; harness must cite oracle path in `li-tests` or tier-2 manifest.

---

## Delivered artifacts

| Artifact | Purpose |
|----------|---------|
| [competitive-engines-plan.md](../../benchmarks/competitive-engines-plan.md) | Layer B external oracle roadmap B0→B3 |
| `benchmarks/competitive/md_oracle.toml` | Pinned LAMMPS/GROMACS rows, driver paths |
| `benchmarks/harness/md_external_oracle.py` | Stub driver → `oracle_stub.json` manifest |
| `scripts/check-md-oracle-plan.sh` | CI gate (registry + manifest) |
| `li-tests/tooling/md_external_oracle_stub.sh` | li-tests suite citation |
| `run_algo_registry_tier2.li` | Existing tier-2 dispatch vs Li oracle (unchanged) |

---

## SOTA → Li mapping (algo 104)

| Field | LAMMPS | GROMACS | Li today |
|-------|--------|---------|----------|
| Neighbor | `neighbor bin` | grid search | O(N²) brute (105 stub) |
| Integrator | `run verlet` | leap-frog / VV | VV in Li oracle |
| Cutoff LJ | `pair_style lj/cut` | `cutoff-scheme Verlet` | rc = 2.5 |
| Oracle role | **future validity column** | **future validity column** | `sim_scientific_oracle_checksum_md()` |
| CI | optional B1+ | optional B2+ | **stub gate B0** |

---

## Gate evidence

```bash
./scripts/check-md-oracle-plan.sh
./li-tests/tooling/md_external_oracle_stub.sh
SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh
```

Manifest must include `oracle_registry` path → `benchmarks/competitive/md_oracle.toml` and `oracle_ids` containing `lammps_lj_micro`, `gromacs_lj_micro`.

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | pass | n/a | Stub records Li reference drift; no false external parity |
| Performance | N/A | n/a | Study-only; no perf claims |
| Memory | N/A | n/a | Python stub only |
| Security | pass | n/a | No new FFI; optional subprocess reserved for B1+ |
| Stability | pass | n/a | Energy drift metric documented |
| Size scaling | table N/A | n/a | Micro workload fixed N=4 |

## Tradeoffs

- **Locked:** validity (+ stability for MD integrators); no LAMMPS/GROMACS required in default CI.
- **Improved:** Honest Layer B plan, registry pins, li-tests gate citation for algo 104 / WP-PLAT-05.
- **Regressed:** none — additive documentation and stub gate only.

---

## Handoff

- **B1 implement:** LAMMPS input deck + `LI_MD_ORACLE_LAMMPS=1` driver branch in `md_external_oracle.py`.
- **B2 implement:** GROMACS `.mdp`/`.gro` + competitive JSON row.
- **Neighbor list:** remains `sim-p1-md-neighbor-cell` (md-r2); orthogonal to external oracle column.
