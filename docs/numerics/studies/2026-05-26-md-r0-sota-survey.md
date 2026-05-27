# MD algorithms — SOTA survey and Li gap analysis (`md-r0-sota-survey`)

**Goal:** `md_sim_algorithms` · **Session:** `6e53ee04-20a2-4846-836a-c46a8ec4fe0a` · **Run:** `numerics_researcher-1779774622783`  
**Agent:** `numerics_researcher` · **Mode:** study-only (validity locked; no perf claims)  
**North star:** PH-5b (proved numerics), PH-7e (math→SIMD), G-math / G-par for force loops  
**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-25T17:59Z · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Problem

Li’s MD vertical must reach **LAMMPS/GROMACS-class** neighbor lists, symplectic integrators, cutoffs, and (later) long-range electrostatics without trading **checksum parity** or **tier-0 stability** for `ratio_vs_cpp`. Today only **`md_lennard_jones`** has a full tier-2 harness under `lic/benchmarks/tier2_physics/`; registry rows **101–120** are mostly catalog/smoke honesty with harness paths **missing** on `main` (ecosystem audit catalog gaps).

Related **red** rows touching MD integrator math (not full MD): `num_integ_verlet` (1.35× cpp), `num_integ_euler` (1.40×). **Near-threshold** MD-shaped catalog ids: `md_neighbor_cell_list` (1.18×), `md_constraints_shake` (1.17×) — paths not present under lic root yet.

---

## Learned from (SOTA)

1. **LAMMPS** — cell-linked neighbor lists, pair cutoff + skin, velocity-Verlet family integrators, SHAKE/RATTLE constraints, Ewald/PPPM long-range.  
   - Docs: https://docs.lammps.org/neighbor.html , https://docs.lammps.org/Integrators.html  
   - **Takeaway for Li:** O(N) forces require **linked cells + skin** (algo 105–106); rebuild criteria must be explicit in `params.toml` before perf work.

2. **GROMACS** — domain decomposition, neighbor-search grids, LINCS/SETTLE constraints, PME for Coulomb.  
   - Manual: https://manual.gromacs.org/current/reference-manual/algorithms/index.html  
   - **Takeaway:** List update frequency vs energy drift is a **validity axis**; PME (algo 114) is deferred until cutoff+LJ path is green.

3. **OpenMM** — platform-neutral kernels; cutoff schemes; Langevin/Nosé thermostats; documented energy drift tests.  
   - User guide: https://docs.openmm.org/latest/userguide/application.html  
   - **Takeaway:** Thermostat/barostat rows (108–110) stay **stub/oracle honesty** until NVE tier-0 matrix (`md-r1`) is filled.

4. **Allen & Tildesley / Swope et al.** — NVE conservation benchmarks (timestep halving, energy MSD).  
   - https://github.com/Allen-Tildesley/examples , https://doi.org/10.1006/jcph.1997.5740  
   - **Takeaway:** Li already documents stress targets in `benchmarks/tier2_physics/md_lennard_jones/PERF.md`; cut-and-shift + equilibration still open before AT-grade claims.

---

## SOTA → Li mapping (algo_registry 101–120)

| ID | Registry name | Incumbent pattern | Li package / bench | Harness on `main` | PH / proof |
|----|---------------|-------------------|--------------------|-------------------|------------|
| 101 | `md_lj_cutoff_mic` | LAMMPS `pair/lj/cut` + MIC | `li-physics-particles` (`lj_force_scalar`), smoke in `li-sim-scientific` | **Yes** — `md_lennard_jones` | PH-5b; `proof-db/physics/lemmas/energy_drift_bound.li` |
| 102 | `md_integrator_verlet` | GROMACS VV / LAMMPS `run style verlet` | Shared `md_core.c` | Via `md_lennard_jones` | PH-5b; tier-0 harmonic gate |
| 103 | `md_energy_drift` | AT NVE MSD tests | `stability.py` + `[conservation]` in `params.toml` | Partial (stress in PERF.md) | Validity locked |
| 104 | `md_oracle_external` | LAMMPS/GROMACS micro oracles | `verticals.toml` `md_lennard_jones` — **stub** | Stub script only | Honesty: not external parity |
| 105 | `md_neighbor_cell_list` | LAMMPS `neighbor bin` | Planned `lic/benchmarks/tier2_physics/md_neighbor_cell_list` | **Missing path** | PH-7e after parity |
| 106 | `md_neighbor_verlet_skin` | LAMMPS skin distance | Catalog only | **Missing** | Same as 105 |
| 107 | `md_integrator_leapfrog` | Standard leapfrog | Catalog / tier-1 `num_integ_*` | Micro bench gap | Red: `num_integ_verlet` 1.35× |
| 108–110 | thermostats / barostat | GROMACS/OpenMM | Registry smoke | Catalog only | Defer until NVE locked |
| 111–112 | SHAKE/RATTLE | GROMACS LINCS / LAMMPS SHAKE | Near-threshold catalog | **Missing** | `md_constraints_shake` 1.17× when built |
| 113–114 | Ewald / PME | GROMACS PME | Catalog only | **Missing** | Long-range after cutoff path |
| 115–120 | init / analysis | Various | `md_init_fcc_mb` yellow in audit | Partial catalog | Init before large-N perf |

**Vertical honesty** (`benchmarks/competitive/verticals.toml` in compiler-studio worktree): `md_lennard_jones` oracle = `cpp`, incumbent = LAMMPS/GROMACS, workload = `stub` — matches composable reality.

---

## Size scaling (survey table — harness targets)

Literature and LAMMPS weak-scaling expect neighbor build ≈ O(N) and force eval ≈ O(N) with fixed density. Li default `N=256` (`params.toml`); propose three harness sizes for `md-r1` / neighbor gap:

| N | ρ (LJ units) | dt | Expected dominant cost | Li action |
|---|--------------|-----|------------------------|-----------|
| 128 | 0.75 | 0.004 | Force eval (small list) | Baseline stability row |
| 512 | 0.75 | 0.004 | Neighbor rebuild amortization | Skin sensitivity |
| 2048 | 0.75 | 0.004 | Cell list + memory bandwidth | PH-7e SIMD / G-par target |

**Repro (when harness exists):**

```bash
cd lic/benchmarks/harness
python3 bench.py --tier 2 --only md_lennard_jones --runs 3
python3 stability.py
```

Dashboard ingest: `cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh`

---

## Implementation path in lic (contracts + bench evidence)

1. **Validity first (PH-5b):** Keep `common/md_core.c` as cross-lang oracle; extend `stability.py` rows before any `threshold_ratio_cpp` relaxation. Pure-Li driver must pass `verify-results` on checksum, not just wall time.
2. **Neighbor list (algo 105 → `md-r2`):** Port cell-linked list from LAMMPS neighbor doc into `md_neighbor_cell_list/` sharing `md_core.h` SoA layout; `li-tests` row for single rebuild step parity vs C++.
3. **Integrator micro (PH-7e):** Fix tier-1 `num_integ_verlet` red (1.35×) using proved `parallel for` + SIMD on harmonic/VV microkernel — feeds MD integrator row 102/107 without weakening drift gates.
4. **G-math / G-par:** Force loop in `md_lennard_jones/li/main.li` — `@vectorized` / `parallel for (disjoint=)` only after `lic build` proves energy drift bound lemma (LEM-PHYS-001).
5. **Packages:** `li-sim-scientific` smoke stays algo 101; expand `li-physics-particles` with neighbor APIs (today: scalar LJ only). Studio vertical: `packages/li-scene` `md_kernel = "md_lennard_jones"`.
6. **External oracle (`md-r3`):** LAMMPS/GROMACS micro drivers in competitive layer — update `verticals.toml` only when `import_*` smoke matches composable reality.

**Do not:** weaken `threshold_ratio_cpp` (1.2 tier-2); ship `sorry`/`unsafe` for speed; copy harness into **benchmarks** repo.

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | **pass (survey)** | — | `md_lennard_jones` tier-2 green; registry honesty flags missing harness paths |
| Performance | **document only** | — | Near-limit: `md_neighbor_cell_list` 1.18×, `md_constraints_shake` 1.17× — no harness on main yet |
| Memory | N/A | — | Defer to `sim-bench-memory.sh` after neighbor harness |
| Security | pass | — | No new FFI; existing `md_core.c` in trusted audit |
| Stability | **partial** | — | PERF.md stress suite defined; AT-grade NVE still advisory |
| Size scaling | table attached | — | ≥3 N column above; fill metrics in `md-r1` |

---

## Tradeoffs

- **Locked:** validity + stability (NVE drift, checksum vs `md_core.c`, registry honesty for stubs).
- **Improved:** Clear SOTA→registry map; prioritized **105 neighbor list** before PME/thermostats; integrator red row linked to PH-7e microbench.
- **Regressed:** none (survey-only).
- **Explicitly not approved:** trading tier-0 tolerances or `threshold_ratio_cpp` for green dashboard cells.

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-05-26-md-r0-sota-survey.md` |
| Whitepaper | `research-findings/whitepapers/2026-05/md_sim_algorithms/md-r0-sota-survey/` |
| Preflight audit | `benchmarks/data/latest/ecosystem-audit.json` (red + near_threshold MD rows) |
| Catalog | `benchmarks/catalog.toml` — `md_lennard_jones`, `md_neighbor_cell_list`, … |
| Registry | `lic/benchmarks/competitive/algo_registry.json` ids 101–120 |
| Harness | `lic/benchmarks/tier2_physics/md_lennard_jones/` |
| Grading | `lic/docs/ecosystem/sim-algo-research-grading.md` |
| Backlog | `lic/docs/ecosystem/sim-md-research-backlog.md` |
| li-tests | `li-tests/composable/import_sim_scientific_run.li` |
| Bench repro | `python3 lic/benchmarks/harness/bench.py --tier 2 --only md_lennard_jones` |
