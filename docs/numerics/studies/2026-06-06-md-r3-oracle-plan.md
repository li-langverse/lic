# MD external oracle column plan (`md-r3-oracle-plan`)

**Goal:** `md_sim_algorithms` · **Issue:** [lic#523](https://github.com/li-langverse/lic/issues/523)  
**Agent:** `code_implementer` · **Mode:** study-only (validity locked; no perf claims)  
**North star:** PH-5b (proved numerics), G-math (simulation correctness honesty)  
**Preflight:** `data/goal-directed-agents/snapshot.json` — `sim-md-research.plan_pending = ["md-r3-oracle-plan"]`

---

## Problem

Algo registry id **104** (`md_oracle_external`) and `verticals.toml` row `md_lennard_jones` list LAMMPS/GROMACS as incumbent but only ship **Li native** oracle today (`sim_scientific_oracle_checksum_md()`). Without a pinned external-oracle plan, tier-2 CSV and competitive claims risk overstating GROMACS/LAMMPS parity.

Completed research todos: `md-r0-sota-survey`, `md-r1-stability-matrix`, `md-r2-neighbor-list-gap`. This slice closes the last pending `sim-md-research` plan item.

---

## Learned from (SOTA)

1. **LAMMPS reproducibility** — versioned releases + input decks; NVE micro workloads for integrator validation.  
   - https://docs.lammps.org/Run_basics.html  
   - **Takeaway:** pin `stable_22Jun2024` (2024.06.27) before any validity column.

2. **GROMACS manual — neighbor search + drift** — list buffer and energy conservation documented per release.  
   - https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html  
   - **Takeaway:** GROMACS oracle deferred to B2; stub honesty until `.mdp` matches `md_core.c` IC.

3. **Li httpd nginx-oracle pattern** — external binary as long-term truth; stub manifest until pins align.  
   - `docs/testing/webserver-security.md`  
   - **Takeaway:** B0 stub records native reference; no LAMMPS/GROMACS required in CI.

4. **WP-PLAT-05 / wave-b-md-oracle** — competitive-engines plan drafted on `cursor/compiler-studio-plan-loop` (PR #176, closed unmerged).  
   - **Takeaway:** land plan + registry in `lic` main path; gate via `li-tests`.

---

## Oracle → Li mapping (algo 104 + vertical)

| Surface | Incumbent | Li today | B0 deliverable | B1+ target |
|---------|-----------|----------|----------------|------------|
| Registry id 104 | LAMMPS/GROMACS micro | `verticals.toml` stub note | `md_oracle.toml` rows | `lang=lammps` CSV validity |
| Tier-2 harness | `md_core.c --verify` | cpp/rust/julia shared | stub manifest cites path | external drift ±ε |
| `li-sim-scientific` | — | `sim_scientific_oracle_checksum_md()` | `scientific_oracle_bench.li` | parity vs LAMMPS deck |
| Competitive registry | — | watch rows missing | `lammps_lj_micro`, `gromacs_lj_micro` | `active` after B1/B2 |

**Li honesty:** B0 does **not** claim LAMMPS/GROMACS energy drift match — only documents pins, drivers, and stub gate.

---

## Size scaling (oracle plan — validity targets)

| Phase | Workload | N | steps | Gate |
|-------|----------|---|-------|------|
| B0 (now) | Li 4-particle chain oracle | 4 | 8 | `md_external_oracle_stub.sh` |
| B1 | LAMMPS LJ micro | 256 | 10_000 | `md_main.c` drift ±1e-3 advisory |
| B2 | GROMACS LJ micro | 256 | 10_000 | same contract |
| B3 | Full tier-2 `md_lennard_jones` | 256 | 10_000 | `latest.csv` validity columns |

---

## Implementation path in lic (B0 shipped)

1. **Plan doc:** `docs/benchmarks/competitive-engines-plan.md` — Layer B oracles, roadmap B0→B3.
2. **Registry:** `benchmarks/competitive/md_oracle.toml` — pinned LAMMPS/GROMACS, `status = stub`.
3. **Gate script:** `scripts/md-external-oracle-stub.py` → `benchmarks/results/md_lennard_jones/oracle_stub.json`.
4. **li-tests:** `li-tests/tooling/md_external_oracle_stub.sh` + `manifest.toml` entry.
5. **HPC registry:** `lammps_lj_micro` / `gromacs_lj_micro` watch rows in `registry.toml`.
6. **Backlog:** `md-r3-oracle-plan` → `completed` in `sim-md-research-backlog.md`.

**Do not:** weaken tier-2 verify thresholds; ship perf claims vs LAMMPS from stub.

---

## Quality / improvement (study)

Survey-only: no before/after perf claims. Improvement = pinned oracle registry + CI gate path for agents implementing B1/B2.

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | **pass (plan)** | new | Li oracle band documented; external stub manifest |
| Performance | **document only** | — | No LAMMPS/GROMACS wall-time rows |
| Memory | N/A | — | Defer to B1 |
| Security | pass | — | No new FFI; external_binary labeled |
| Stability | pass | — | Stub does not alter md_core |
| Size scaling | table attached | — | B1+ targets listed |

---

## Tradeoffs

- **Locked:** validity + honesty (`external_binary`, `workload_class = v0_micro`).
- **Improved:** Closes `sim-md-research` 3/3→4/4; unblocks `gap-plan-pending-sim-md-research-md-r3-oracle-plan`.
- **Regressed:** none (plan-only).
- **Not approved:** `lang=lammps` perf marketing before deck parity.

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md` |
| Plan | `docs/benchmarks/competitive-engines-plan.md` |
| Registry | `benchmarks/competitive/md_oracle.toml` |
| Gate | `python3 scripts/md-external-oracle-stub.py` |
| li-tests | `./li-tests/tooling/md_external_oracle_stub.sh` |
| Prior survey | `docs/numerics/studies/2026-05-27-md-r0-sota-survey.md` |
| Package oracle | `packages/li-sim-scientific/src/lib.li` — `sim_scientific_oracle_checksum_md()` |
| Gates | `SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md ./scripts/sim-algo-research-gates.sh` |
