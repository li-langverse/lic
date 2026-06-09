# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Agent:** `code_implementer`  
**Mode:** study-only (validity locked; external oracle is honesty scaffolding)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Registry:** algo **104** `md_oracle_external` · catalog `benchmarks/tier2_physics/md_oracle_external`

---

## Problem

Li’s MD vertical has a **native Li oracle** (`sim_scientific_oracle_checksum_md()` — 8-step 4-particle LJ chain) wired through tier-2 smokes, but **no external LAMMPS/GROMACS column** for competitive honesty. Registry row **104** and `verticals.toml` `md_lennard_jones` note Layer B `lammps`/`gromacs` CSV stubs without a driver contract.

Master plan **WP-PLAT-05** requires: tier-2 csv column + `md_oracle.toml` driver + gate script citing oracle paths in `li-tests` or tier-2 manifest.

---

## Learned from (SOTA)

1. **LAMMPS micro-benchmark** — `pair_style lj/cut` + `run 0` energy/force dump for fixed micro geometry.  
   - https://docs.lammps.org/run.html  
   - **Takeaway:** v0 workload = frozen 4-particle MIC box matching `md_core.h` params; no thermostat.

2. **GROMACS energy evaluation** — `gmx mdrun -rerun` or minimal `mdrun` with `nsteps=0` for force/energy at fixed coords.  
   - https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html  
   - **Takeaway:** neighbor list must be built even for single-point eval; pin GROMACS version in driver manifest.

3. **Li internal oracle (today)** — `packages/li-sim-scientific/src/lib.li` `md_oracle_chain_*` + `sim_scientific_oracle_checksum_md()`.  
   - **Takeaway:** external column compares **energy drift / force checksum** against Li native oracle, not against unproved fast paths.

4. **PySCF competitive pattern** — `benchmarks/competitive/ph-sci-chem-dft.toml` + `ph-sci-chem-dft-competitive-gates.sh` (optional external, mandatory manifest).  
   - **Takeaway:** stub `external_binary` drivers OK in CI; gate validates registry + li-tests paths.

---

## Oracle architecture (B0 → B3)

| Phase | Deliverable | Gate | Status |
|-------|-------------|------|--------|
| **B0** | Plan doc + `md_oracle.toml` + `check-md-oracle-plan.sh` | li-tests manifest cites oracle smokes | **This study** |
| **B1** | `md_external_oracle.py` stub manifest (no LAMMPS required) | JSON schema `li_sim_summary_v1` | Planned |
| **B2** | LAMMPS `in.lammps` micro + pinned version | `energy_drift_rel` vs Li oracle tolerance | Planned |
| **B3** | GROMACS `.mdp` + `topol.tpr` micro | csv `lang=lammps|gromacs` in `latest.csv` | Planned |

**Workload contract (v0_micro):** N=4, ρ=0.75, rc=2.5 (LJ units), velocity-Verlet dt=0.004, 8 steps — mirrors `sim_scientific_oracle_checksum_md()` chain geometry.

---

## Harness oracle path map (gate-required)

| Artifact | Path | Role |
|----------|------|------|
| Li MD oracle fn | `packages/li-sim-scientific/src/lib.li` → `sim_scientific_oracle_checksum_md()` | Native checksum reference |
| Tier-2 smoke | `packages/li-sim-scientific/li-tests/smoke/scientific_oracle_bench.li` | MD+heat oracle vs `run_*_smoke` |
| Registry tier-2 | `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li` | algo 105 checksum vs oracle |
| GPU oracle | `packages/li-sim-scientific/li-tests/smoke/scientific_gpu_md_oracle.li` | PH-SCI-GPU-02 @gpu path |
| Package manifest | `packages/li-sim-scientific/li-tests/manifest.toml` | tier-2 oracle smoke registration |
| Monorepo manifest | `li-tests/manifest.toml` | science_gpu + smoke oracle rows |
| Tier-2 catalog stub | `benchmarks/tier2_physics/md_oracle_external/` | shared `md_core.c` until external driver lands |
| Driver registry | `benchmarks/competitive/md_oracle.toml` | LAMMPS/GROMACS driver pins + gate_script |
| Gate | `scripts/check-md-oracle-plan.sh` | Validates paths + study doc |

---

## Size scaling (oracle acceptance table)

| N | External engine | Metric | Li oracle | Acceptance (B2+) |
|---|-----------------|--------|-----------|------------------|
| 4 | LAMMPS lj/cut | \|ΔE/E0\| after 8 VV steps | `sim_scientific_oracle_checksum_md()` | ≤ 1e-4 rel drift |
| 4 | GROMACS grompp+mdrun | force checksum L2 | same | ≤ 1e-6 vs Li native |
| 32 | LAMMPS | wall time (honesty only) | tier-2 `md_lennard_jones` | document only |
| 128 | Li | NVE stability | `md-r1-stability-matrix` | validity locked first |

---

## Implementation path

1. **B0 (shipped):** Study + `md_oracle.toml` + gate; backlog `md-r3-oracle-plan` → completed when gate green.
2. **B1:** Add `benchmarks/harness/md_external_oracle.py` stub emitting `li_sim_summary_v1` with `workload_class=stub`.
3. **B2:** `benchmarks/tier2_physics/md_lennard_jones/external/lammps/` input deck; optional CI skip when `LAMMPS_BIN` unset.
4. **B3:** GROMACS twin; `registry.toml` watch rows `lammps_lj_micro` / `gromacs_lj_micro` → `bench_tier2` with `kernel_honesty=external_binary`.
5. **Do not:** claim LAMMPS/GROMACS parity before B2; weaken `threshold_ratio_cpp`; skip li-tests manifest rows.

**Repro (gate):**

```bash
./scripts/check-md-oracle-plan.sh
SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh
```

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | **pass (plan)** | new | Native Li oracle smokes already green; external column planned only |
| Performance | document only | — | No external timing until B2 |
| Memory | N/A | — | Defer to `sim-bench-memory.sh` |
| Security | pass | — | `external_binary` gated; no new FFI in B0 |
| Stability | partial | — | NVE matrix in `md-r1`; external drift in B2 |
| Size scaling | table attached | — | ≥3 rows (N=4/32/128) |

---

## Tradeoffs

- **Locked:** validity via Li native oracle; no `implemented_smoke` for algo 104 until B2 manifest exists.
- **Improved:** Explicit B0→B3 roadmap; gate script + manifest citations for agent/CI discoverability.
- **Regressed:** none (study-only).
- **Not approved:** marking `md_oracle_external` implemented without LAMMPS/GROMACS driver evidence.

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md` |
| Prior survey | `docs/numerics/studies/2026-05-27-md-r0-sota-survey.md` (row 104) |
| Driver registry | `benchmarks/competitive/md_oracle.toml` |
| Gate | `./scripts/check-md-oracle-plan.sh` |
| li-tests | `li-tests/manifest.toml` — `scientific_oracle_bench.li`, `run_algo_registry_tier2.li`, `scientific_gpu_md_oracle.li` |
| Package manifest | `packages/li-sim-scientific/li-tests/manifest.toml` |
| Vertical honesty | `benchmarks/competitive/verticals.toml` — `md_lennard_jones` |
