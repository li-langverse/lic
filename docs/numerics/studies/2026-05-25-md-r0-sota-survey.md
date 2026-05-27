# MD SOTA survey — integrators, neighbor lists, cutoffs (`md-r0-sota-survey`)

**Date:** 2026-05-25  
**Vertical:** `md`  
**Work item:** `md-r0-sota-survey` (`study_only`)  
**Grading:** [sim-algo-research-grading.md](../../ecosystem/sim-algo-research-grading.md)  
**Registry:** [algo_registry.json](../../../benchmarks/competitive/algo_registry.json) (family `md`, ids 101–117)

---

## Scope

Survey **existing** molecular-dynamics practice in LAMMPS, GROMACS, and OpenMM for:

- Short-range **cutoffs** and minimum-image conventions
- **Neighbor lists** (cell-linked, Verlet skin, rebuild policy)
- **Integrators** (symplectic Verlet / leap-frog, thermostats, barostats, constraints)
- **Long-range** electrostatics (Ewald / PME) where relevant to registry rows 113–114

Map each registry row to incumbent behavior, current Li placement (**PH-5b** simulation contracts, **PH-7e** math→native lowering, **G-math** / **G-par**), and a **lic** implementation path with bench evidence hooks. No threshold or `implemented_smoke` changes in this survey.

---

## Learned from (external references)

1. **LAMMPS neighbor documentation** — bin / `nsq` / multi styles, **skin** distance, and rebuild triggers (`neigh_modify every delay check yes`).  
   https://docs.lammps.org/neighbor.html

2. **LAMMPS `run_style` integrators** — default **velocity Verlet** (`verlet`), **RESPA** hierarchy, and thermostat/barostat fixes as separate modifiers on the same symplectic core.  
   https://docs.lammps.org/run_style.html

3. **GROMACS manual — neighbor searching** — charge-group / grid search, **Verlet buffer** (skin), and domain-decomposition-aware list builds for O(N) pair screening.  
   https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html

4. **OpenMM User Guide — integrators & nonbonded forces** — `VerletIntegrator`, Langevin variants, `NonbondedForce` cutoff + switching; long-range via **PME** on periodic systems.  
   http://docs.openmm.org/latest/userguide/application/02_standard_forces.html

---

## Li baseline (tier-2 `md_lennard_jones`)

| Piece | Incumbent pattern | Li today (`benchmarks/tier2_physics/md_lennard_jones/common/md_core.h`) |
|-------|-------------------|---------------------------------------------------------------------------|
| Potential | LJ 12-6, cutoff `rc` | `LI_MD_RC = 2.5`, shifted-force style cutoff in pair loop |
| Boundary | Periodic + MIC | `li_md_mic` / `li_md_wrap` on cubic box `LI_MD_BOX` |
| Integrator | Velocity Verlet / leap-frog | `li_md_step`: half-kick → drift → forces → half-kick |
| Neighbors | Cell list + skin (production) | **O(N²)** all-pairs in `li_md_compute_forces` (header comment says cell-list; implementation is brute MIC) |
| Sizes | Strong scaling studies | Fixed `LI_MD_N = 256`, `LI_MD_STEPS = 10000`, `LI_MD_DT = 0.004` |
| Composable smoke | Scalar LJ + mini Euler step | `packages/li-physics-particles` (`lj_force_scalar`, `md_mini_step` on 16 particles); `li-sim-scientific` `run_md_lj_smoke` → algo **101** only |

**Bench repro (validity, not perf claims):**

```bash
cd benchmarks
python3 harness/verify.py --only md_lennard_jones
# Dashboard row: https://li-langverse.github.io/benchmarks/ (kernel md_lennard_jones)
```

---

## Size scaling (≥3 problem sizes)

Literature scaling for **short-range LJ** with cutoff `r_c` and number density `ρ` (Frenkel & Smit, *Understanding Molecular Simulation*). Li tier-2 today is the **N = 256** column only; larger columns are **targets** for `md-r1-stability-matrix` / `sim-p1-md-neighbor-cell`.

| N | ρ (reduced, L=10) | Neighbor mode (incumbent) | Pair work / step (order) | List rebuild | Energy drift gate (target) | Li status |
|---|-------------------|---------------------------|--------------------------|--------------|----------------------------|-----------|
| **256** | 0.256 | All-pairs or small-cell | O(N²) ≈ 3.3×10⁴ pairs | every step (naive) | \|ΔE\|/E ≲ 10⁻³ (tier-2 trace) | **tier-2 fixed** (`md_lennard_jones`) |
| **4 096** | 0.256 | Cell-linked + Verlet skin | O(N) with ~4πρ r_c³/3 prefactor | every O(skin/v_max) steps | same drift class | **planned** — algo **105** / **106** |
| **32 768** | 0.256 | DD + cell list (GROMACS/LAMMPS) | O(N/P) per rank + halo | amortized rebuild | drift + momentum COM removal | **future** — needs **G-par** + honest `kernel_honesty` labels |

**Timestep scaling (stability, locked axis):** symplectic Verlet stable dt scales as ~0.1–0.5 reduced units for LJ solids near melting (empirical; see GROMACS recommended dt for comparable σ/ε). Li uses **dt = 0.004** at N=256 — conservative for FCC LJ; `md-r1-stability-matrix` should sweep dt at fixed N before any perf work.

---

## Registry map (algo 101–117 → incumbents → Li / PH / G)

| id | Registry name | LAMMPS / GROMACS / OpenMM | Li package / bench | PH-5b / PH-7e / G-math / G-par | Implementation path (lic) |
|----|---------------|---------------------------|--------------------|--------------------------------|---------------------------|
| 101 | `md_lj_cutoff_mic` | `pair_style lj/cut` (LAMMPS); `nb_kernel` cutoffs (GROMACS); `NonbondedForce` LJ (OpenMM) | `lj_force_scalar`; tier-2 MIC loop | **PH-5b** contract; **G-math** scalar | Keep reference C; add pure-Li pair kernel under **PH-7e** with checksum parity vs `md_core` |
| 102 | `md_integrator_verlet` | `run_style verlet`; GROMACS leap-frog ≡ Verlet; `VerletIntegrator` | `li_md_step` in `md_core.h` | **PH-5b** energy drift targets | Wire `run_algo_registry_stub` → real call-through to tier-2 driver; prove drift in `li-tests` / trace |
| 103 | `md_energy_drift` | Thermo `etotal` monitoring (all three) | `li_md_run_trace`, proof-db LEM-PHYS-001 | **PH-5b** validity | Document drift metric in study; no threshold relaxation |
| 104 | `md_oracle_external` | External binaries as columns (LAMMPS/GROMACS micro) | `benchmarks/competitive/registry.toml` watch rows | honesty `external_binary` | Hand off **`md-r3-oracle-plan`**; stub→pinned workload B0→B3 |
| 105 | `md_neighbor_cell_list` | `neighbor bin` (LAMMPS); grid search (GROMACS) | **stub** (registry smoke only) | **G-par** cell traversal | **`sim-p1-md-neighbor-cell`**: replace O(N²) in `md_core` with cell list; bench row unchanged checksum |
| 106 | `md_neighbor_verlet_skin` | `neigh_modify skin` (LAMMPS); Verlet buffer (GROMACS) | not implemented | **G-par** + rebuild schedule | Add skin `r_list = r_c + skin`; rebuild counter; validity: no missed pairs |
| 107 | `md_integrator_leapfrog` | Same as 102 (staggered r,v) | equivalent to `li_md_step` | **PH-5b** | Expose as alias test only; do not fork integrator |
| 108 | `md_thermostat_nose_hoover` | `fix nvt` NH (LAMMPS); `tcoupl` nh (GROMACS); `NoseHooverChain` (OpenMM) | stub smoke | **PH-5b** stochastic/stable | New module after Verlet baseline green; validity: T distribution, not wall time |
| 109 | `md_thermostat_berendsen` | `fix temp/berendsen` | stub | weak validity (non-Hamiltonian) | Document as **non-production**; prefer 108 for science runs |
| 110 | `md_barostat_parrinello_rahman` | `fix npt` aniso PR | stub | coupling stability | Defer until 108 NVT stable |
| 111 | `md_constraints_shake` | `fix shake` (LAMMPS); SHAKE (GROMACS) | stub | constraint drift | Bonded model not in LJ bench — separate tier-2 later |
| 112 | `md_constraints_rattle` | RATTLE for velocity constraints | stub | same | Same as 111 |
| 113 | `md_longrange_ewald` | `kspace_style ewald` | stub | N/A for LJ-only bench | QM/coulomb vertical crossover; not LJ tier-2 |
| 114 | `md_longrange_pme` | PPPM / PME (all three) | stub | FFT + charge | **`md-r3`** + chem/electrolyte backlog |
| 115 | `md_init_fcc_mb` | `lattice fcc` + velocity creation | `li_md_init_fcc`, MB velocities | **PH-5b** init | Already in C core; export init API to Li for composable tests |
| 116 | `nbody_pairwise_gravity` | `pair_style` not used; N-body gravity separate | `nbody_gravity` tier-2 | **G-math** softening | Keep separate from MD list — Barnes–Hut **117** |
| 117 | `nbody_barnes_hut` | Fast multipole / tree (N-body apps) | tier-2 `nbody_gravity` tree path | **G-par** tree | See autoresearch if novel; else implementer loop |

**Registry honesty note:** `implemented_smoke: true` on 101–117 reflects **composable stub coverage** (`run_algo_registry_stub`), not full physics parity with incumbents. Do **not** interpret as SOTA-complete without tier-2 verify + study gates.

---

## PH-5b / PH-7e / G-math / G-par placement

| Track | MD relevance in this survey |
|-------|----------------------------|
| **PH-5b** | Simulation contracts: `li-sim-scientific`, `li-physics-particles`, tier-2 `md_lennard_jones`, energy drift / trace hooks, Studio kernel `md_lennard_jones` |
| **PH-7e** | Pure-Li lowering of hot loops (pair force, cell traversal) with tier-1/tier-2 ≤1.2× C++ **after** checksum parity |
| **G-math** | `lj_force_scalar`, fixed-size array updates, future SIMD `@vectorized` on inner loops |
| **G-par** | Parallel cell-list build / force accumulation with proved `disjoint=` rows (**7d-c**); required at N ≳ 4k |

---

## Proposed lic implementation path (priority)

1. **`md-r1-stability-matrix`** — dt × N table at 256; document locked drift axis before perf.
2. **`sim-p1-md-neighbor-cell` (algo 105)** — cell-linked `li_md_compute_forces` matching LAMMPS `neighbor bin` semantics; verify checksum vs brute reference at N=256.
3. **`md_neighbor_verlet_skin` (106)** — skin rebuild; benchmark cost only after validity matrix passes.
4. **PH-7e pure-Li pair kernel** — only with `bench.py` DCE guard and `verify.py` green.
5. **`md-r3-oracle-plan`** — external LAMMPS/GROMACS columns with `kernel_honesty = external_binary`.

Coordinate perf work with **bench_improver**; do not weaken `threshold_ratio_cpp`.

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | pass | — | Survey-only; no threshold edits. Tier-2 repro command documented. |
| Performance | N/A | — | No perf claims; scaling table is asymptotic + planned sizes. |
| Memory | N/A | — | Cell list at 4k+ reduces cache footprint vs O(N²); not measured here. |
| Security | pass/skip | — | No native FFI changes in this deliverable. |
| Stability | pass (locked) | — | Verlet + dt=0.004 documented; thermostat/barostat deferred. |
| Size scaling | table attached | new | 256 / 4096 / 32768 columns per grading contract. |

---

## Tradeoffs

- **Locked:** validity (+ symplectic stability for MD integrators). No trading drift gates for wall time.
- **Improved:** Clear map from LAMMPS/GROMACS/OpenMM features to registry 101–117; explicit Li gap (O(N²) vs cell+skin); PH/G-par ownership for next slices.
- **Regressed:** none (documentation only).
- **Rejected for this slice:** marking additional `implemented_smoke` without `verify.py`; Berendsen (109) as default thermostat; PME (114) on LJ-only microbench without charges.

---

## Evidence pack

| Evidence | Path / command |
|----------|----------------|
| numerics doc | This file |
| bench id | `md_lennard_jones` — `python3 benchmarks/harness/verify.py --only md_lennard_jones` |
| gates | `SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_STUDY_ONLY=1 SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-05-25-md-r0-sota-survey.md ./scripts/sim-algo-research-gates.sh` |
