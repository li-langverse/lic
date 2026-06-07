# MD algorithms — SOTA survey and Li gap analysis (`md-r0-sota-survey`)

**Goal:** `md_sim_algorithms` · **Session:** `f1114f06-7079-45f3-9d88-ce5106130118` · **Run:** `numerics_researcher-1779911656866`  
**Agent:** `numerics_researcher` · **Mode:** study-only (validity locked; no perf claims)  
**North star:** PH-5b (proved numerics), PH-7e (math→SIMD), G-math / G-par for force loops  
**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-27T18:44Z · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Problem

Li’s MD vertical must reach **LAMMPS/GROMACS-class** neighbor lists, symplectic integrators, cutoffs, and (later) long-range electrostatics without trading **checksum parity** or **tier-0 stability** for `ratio_vs_cpp`. On **lic main** (2026-05-27):

- **`md_lennard_jones`** — full tier-2 harness; brute O(N²) MIC forces in `md_core.h`.
- **`md_neighbor_cell_list`** — **WP2 catalog harness** exists but `#include`s `md_lennard_jones` oracle (no cell traversal yet).
- Registry **101–120** — composable smokes; most tier-2 rows are catalog honesty / shared oracle stubs.
- **Dashboard:** all 16 `md_*` catalog ids are **unknown** (stale ingest @ 2026-05-26); org **red** is tier-1 `horner_pure_li` (0.67×) and `reduce_sum` (0.93×), not MD physics.

Deep implement contract for algo **105**: [2026-05-25-md-r2-neighbor-list-gap.md](./2026-05-25-md-r2-neighbor-list-gap.md).

---

## Learned from (SOTA)

1. **LAMMPS** — cell-linked neighbor lists (`neighbor bin`), pair cutoff + skin, velocity-Verlet integrators, SHAKE/RATTLE, Ewald/PPPM long-range.  
   - https://docs.lammps.org/neighbor.html · https://docs.lammps.org/Integrators.html  
   - **Takeaway:** O(N) forces need **linked cells + skin** (algo 105–106); rebuild criteria belong in `params.toml` before PH-7e work.

2. **GROMACS** — grid neighbor search, LINCS/SETTLE constraints, PME for Coulomb; list buffer sized from max displacement.  
   - https://manual.gromacs.org/current/reference-manual/algorithms/index.html  
   - https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html  
   - **Takeaway:** list update frequency vs energy drift is a **validity axis**; PME (114) deferred until cutoff+LJ path is green.

3. **OpenMM** — `NonbondedForce` cutoff + switching; documented drift tests for thermostats/integrators.  
   - https://docs.openmm.org/latest/userguide/application.html  
   - **Takeaway:** thermostat/barostat rows (108–110) stay stub until NVE matrix (`md-r1`) is filled.

4. **Frenkel & Smit / Swope et al. 1997** — cell-linked O(N) at fixed ρ; NVE drift gates for integrator acceptance.  
   - https://www.sciencedirect.com/book/9780123872324/understanding-molecular-simulation  
   - https://doi.org/10.1006/jcph.1997.5740  
   - **Takeaway:** Li `md_lennard_jones/PERF.md` stress targets align; AT-grade NVE remains advisory until scaling table is measured.

---

## SOTA → Li mapping (algo_registry 101–120)

| ID | Registry name | Incumbent pattern | Li package / bench | Harness on main | PH / proof |
|----|---------------|-------------------|--------------------|-----------------|------------|
| 101 | `md_lj_cutoff_mic` | LAMMPS `pair/lj/cut` + MIC | `li-physics-particles`, `li-sim-scientific` smoke | **Yes** — `md_lennard_jones` | PH-5b; LEM-PHYS-001 |
| 102 | `md_integrator_verlet` | GROMACS VV / LAMMPS verlet | Shared `md_core` velocity-Verlet | Via `md_lennard_jones` | PH-5b |
| 103 | `md_energy_drift` | AT NVE MSD | `stability.py`, `[conservation]` in `params.toml` | Partial | Validity locked |
| 104 | `md_oracle_external` | LAMMPS/GROMACS micro | `verticals.toml` stub | Stub | Honesty only |
| 105 | `md_neighbor_cell_list` | LAMMPS `neighbor bin` | `tier2_physics/md_neighbor_cell_list` | **WP2 stub** (shared brute oracle) | PH-7e **after** F parity |
| 106 | `md_neighbor_verlet_skin` | LAMMPS skin | Catalog + stub path | WP2 stub pattern | After 105 |
| 107 | `md_integrator_leapfrog` | Leapfrog | `num_integ_*` micro | Tier-1 micro | Near org red: integrator family |
| 108–110 | thermostats / barostat | GROMACS/OpenMM | Catalog | Stub | Defer post-NVE |
| 111–112 | SHAKE/RATTLE | GROMACS LINCS / LAMMPS SHAKE | Catalog | Stub | After neighbor parity |
| 113–114 | Ewald / PME | GROMACS PME | Catalog | Stub | After cutoff path |
| 115–120 | init / analysis | Various | `md_init_fcc_mb` etc. | Catalog / partial | Init before large-N perf |

**Li honesty gap (105):** `li_md_compute_forces` remains O(N²) all-pairs; registry `implemented_smoke: true` on 105 is wiring only — see md-r2.

---

## Size scaling (survey table — harness targets)

| N | ρ (LJ units) | dt | Expected dominant cost | Li action |
|---|--------------|-----|------------------------|-----------|
| 128 | 0.75 | 0.004 | Force eval (small) | Baseline stability (`md-r1`) |
| 512 | 0.75 | 0.004 | Neighbor rebuild amortization | Skin sensitivity (106) |
| 2048 | 0.75 | 0.004 | Cell list + bandwidth | PH-7e SIMD / G-par after parity |

**Repro:**

```bash
cd lic/benchmarks/harness
python3 bench.py --tier 2 --only md_lennard_jones --runs 3
python3 stability.py
cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```

---

## Implementation path in lic (contracts + bench evidence)

1. **Validity (PH-5b):** Keep `md_core.c` cross-lang oracle; `verify-results` checksum before any `ratio_vs_cpp` claim.
2. **Neighbor (105 → `sim-p1-md-neighbor-cell`):** Half-shell cell list in `md_core`; gate **max |F_cell − F_brute|** @ N=256; see md-r2.
3. **Integrator micro (PH-7e):** Tier-1 `num_integ_verlet` feeds rows 102/107 after harmonic tier-0 green.
4. **G-math / G-par:** `@vectorized` / `parallel for (disjoint=)` on force loop only after drift lemma proves.
5. **Packages:** `li-sim-scientific` smoke = algo 101; expand `li-physics-particles` with `neighbor_*` APIs.
6. **Ingest:** Refresh dashboard so `md_lennard_jones` exits **unknown** — ecosystem visibility without weakening thresholds.

**Do not:** weaken `threshold_ratio_cpp`; ship `sorry`/`unsafe` for speed; copy harness into **benchmarks** repo.

---

## Quality / improvement (survey)

Survey-only: no before/after perf claims. Improvement = clarified registry→harness map and prioritized algo **105** implement handoff. Regression: none.

**Visuals:** deferred to `md-r1-stability-matrix` (energy drift PNG) and tier-2 GIF ingest after neighbor parity.

```bash
cd benchmarks && LIC_ROOT=../lic ./scripts/render-benchmark-visuals.sh
```

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | **pass (survey)** | refreshed | LJ tier-2 green; 105 harness exists but oracle-shared (honest stub) |
| Performance | **document only** | — | MD rows unknown on dashboard; org red unrelated to MD |
| Memory | N/A | — | Defer to `sim-bench-memory.sh` post-neighbor |
| Security | pass | — | No new FFI this survey |
| Stability | **partial** | — | `md-r1` matrix defines CFL/skin; AT NVE advisory |
| Size scaling | table attached | — | ≥3 N; metrics in `md-r1` |

---

## Tradeoffs

- **Locked:** validity + stability (NVE drift, checksum vs `md_core`, registry honesty).
- **Improved:** Corrected harness inventory (105 path exists, not missing); ingest stale called out; handoff `sim-p1-md-neighbor-cell` prioritized.
- **Regressed:** none (survey-only).
- **Not approved:** relaxing tier-0 or `threshold_ratio_cpp` for dashboard green.

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-05-27-md-r0-sota-survey.md` |
| Prior | `docs/numerics/studies/2026-05-26-md-r0-sota-survey.md` |
| Neighbor contract | `docs/numerics/studies/2026-05-25-md-r2-neighbor-list-gap.md` |
| Whitepaper | `research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/` |
| Audit | `benchmarks/data/latest/ecosystem-audit.json` |
| Catalog | `benchmarks/catalog.toml` — `md_lennard_jones`, `md_neighbor_cell_list` |
| Harness | `lic/benchmarks/tier2_physics/md_lennard_jones/`, `md_neighbor_cell_list/` |
| li-tests | `li-tests/composable/import_sim_scientific_run.li` |
| Bench | `md_lennard_jones` @ `48d23a7a`: verify drift=0.689; li/cpp≈0.996× — `python3 lic/benchmarks/harness/bench.py --tier 2 --only md_lennard_jones` |
