# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Agent:** `code_implementer` · **Mode:** study-only (validity locked; no perf claims)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523) · **Registry:** algo **104** `md_oracle_external`

---

## Problem

Li tier-2 `md_lennard_jones` compares cpp/rust/julia via shared `md_core.c`. **Layer B** domain engines (LAMMPS, GROMACS) are the long-term **external oracle** for validity — energy drift on equivalent micro workloads — without claiming production parity or weakening `threshold_ratio_cpp`.

On **lic main** (2026-06-06):

- **Internal Li oracle** — `sim_scientific_oracle_checksum_md()` (4-particle LJ chain, 8 VV steps) gates `run_algo_registry` MD rows 101–117 including **104**.
- **External column** — `md_oracle_external` catalog id **104**; `verticals.toml` lists LAMMPS/GROMACS incumbent; no pinned driver or CSV `lang` row yet.
- **Prior wave-b** — `cursor/compiler-studio-plan-loop` PR #176 (closed unmerged) drafted B0 stub; this study lands B0 on main under `sim-md-research`.

---

## Learned from (SOTA)

1. **LAMMPS** — `pair_style lj/cut`, `run` NVE, `thermo` energy output for drift checks.  
   - https://docs.lammps.org/Run_commands.html  
   - **Takeaway:** micro deck must match `md_core.h` IC (FCC, seed=7, rc=2.5, dt=0.004) before validity claims.

2. **GROMACS** — `gmx mdrun` with LJ-only `.mdp`; neighbor search + cutoff policy affects drift.  
   - https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html  
   - **Takeaway:** list buffer / skin deferred until B1 LAMMPS parity is green.

3. **OpenMM** — documented NVE drift tests for integrator acceptance.  
   - https://docs.openmm.org/latest/userguide/application.html  
   - **Takeaway:** external oracle is **validity-first**; perf columns stay cpp/rust/julia/li.

4. **Li httpd nginx-oracle pattern** — external tool is long-term truth; harness ships stub until pins align.  
   - `li-tests/httpd/m15_agent_oracle.li`  
   - **Takeaway:** B0 stub manifest + gate script; B1/B2 real drivers optional on PATH.

---

## Oracle architecture (B0 → B3)

| Layer | Source | Metric | Gate today |
|-------|--------|--------|------------|
| **A** | `md_core.c` / cpp | `energy_drift_rel` | `bench-verify-results.sh 2` (benchmarks repo) |
| **A′** | Li pure | `sim_scientific_oracle_checksum_md()` | `scientific_oracle_bench.li`, `md_oracle_external_tier2.li` |
| **B** | LAMMPS | same drift definition | `md_oracle.toml` → `status = stub` |
| **B** | GROMACS | same drift definition | `md_oracle.toml` → `status = stub` |

**Workload contract** (canonical, from benchmarks `md_lennard_jones/params.toml`):

| Field | Value |
|-------|-------|
| N | 256 |
| steps | 10_000 (perf) / 8 (Li micro oracle) |
| dt | 0.004 |
| rc | 2.5 |
| potential | LJ 12-6, no shift |
| integrator | velocity-Verlet NVE |

---

## Registry + gate script reference

| Artifact | Path |
|----------|------|
| Oracle registry | `benchmarks/competitive/md_oracle.toml` |
| Stub driver | `scripts/md-external-oracle-stub.py` |
| Bench wrapper | `scripts/bench-md-oracle-external.sh` |
| li-tests gate | `li-tests/tooling/md_external_oracle_stub.sh` |
| HPC registry | `benchmarks/competitive/registry.toml` (`lammps_lj_micro`, `gromacs_lj_micro` watch) |
| Tier-2 smoke | `packages/li-sim-scientific/li-tests/smoke/md_oracle_external_tier2.li` |
| Li oracle API | `packages/li-sim-scientific/src/lib.li` → `sim_scientific_oracle_checksum_md()` |
| External harness (B1+) | `benchmarks/tier2_physics/md_lennard_jones/external/` (benchmarks repo) |

**Validate (no LAMMPS/GROMACS required):**

```bash
./scripts/check-hpc-competitive.sh
./li-tests/tooling/md_external_oracle_stub.sh
SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh
```

---

## Size scaling (oracle workload targets)

| N | ρ (LJ) | dt | Dominant concern | B phase |
|---|--------|-----|------------------|---------|
| 4 | chain | 0.004 | Li micro oracle (today) | **B0** |
| 256 | 0.75 | 0.004 | Native + external drift | **B1/B2** |
| 2048 | 0.75 | 0.004 | Neighbor policy sensitivity | defer post-105 |

---

## Implementation roadmap

| Phase | Deliverable | Exit evidence |
|-------|-------------|---------------|
| **B0 (this PR)** | Plan study + `md_oracle.toml` + stub manifest + li-tests | `md_external_oracle_stub.sh` green |
| **B1** | LAMMPS micro deck = md_core IC | `lang=lammps` validity row |
| **B2** | GROMACS `mdrun` micro | `lang=gromacs` validity row |
| **B3** | `verticals.toml` Layer B complete | algorithms plan §4 |

**Do not:** publish “faster than GROMACS”; weaken verify thresholds; ship `sorry`/`unsafe` shortcuts.

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | **pass (plan)** | new | Li oracle + algo 104 smoke; external stub honesty |
| Performance | N/A | — | External perf out of scope until IC parity |
| Memory | N/A | — | Defer to `sim-bench-memory.sh` |
| Security | pass | — | No new FFI; stub only |
| Stability | partial | — | NVE drift matrix in `md-r1`; external advisory |
| Size scaling | table attached | — | 4 / 256 / 2048 targets |

---

## Tradeoffs

- **Locked:** validity + honesty (`external_binary` labels, stub status until B1).
- **Improved:** Closed plan-debt `md-r3-oracle-plan`; gate script + li-tests manifest cite oracle paths.
- **Regressed:** none (study + stub only).
- **Not approved:** CSV `lammps`/`gromacs` perf rows before workload equivalence proof.

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md` |
| Prior survey | `docs/numerics/studies/2026-05-27-md-r0-sota-survey.md` |
| Registry | `benchmarks/competitive/md_oracle.toml` |
| li-tests | `packages/li-sim-scientific/li-tests/smoke/md_oracle_external_tier2.li` |
| Gate | `./li-tests/tooling/md_external_oracle_stub.sh` (exit 0) |
