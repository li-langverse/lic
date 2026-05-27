# MD stability matrix — CFL analog, neighbor skin, size scaling (`md-r1-stability-matrix`)

**Date:** 2026-05-25  
**Vertical:** `md`  
**Work item:** `md-r1-stability-matrix` (`study_only`)  
**Grading:** [sim-algo-research-grading.md](../../ecosystem/sim-algo-research-grading.md)  
**Prior survey:** [2026-05-25-md-r0-sota-survey.md](./2026-05-25-md-r0-sota-survey.md)  
**Registry:** [algo_registry.json](../../../benchmarks/competitive/algo_registry.json) (family `md`, ids 101–106, 102–103)

---

## Scope

Lock **numerical stability axes** for tier-2 `md_lennard_jones` before neighbor-list or perf work:

1. **Timestep stability** (MD “CFL” analog for symplectic Verlet on LJ)
2. **Neighbor skin / rebuild policy** (incumbent semantics vs Li O(N²) today)
3. **Size scaling** (N and ρ with fixed integrator/cutoff)
4. **Tier-0 stability row proposal** wiring `stability.py` strict tests into CI/manifest

No threshold edits, no `implemented_smoke` changes, no native kernel changes in this deliverable.

---

## Learned from (external references)

1. **Allen & Tildesley examples — conservation tests** — NVE energy MSD and timestep-halving (dt⁴) acceptance bands for reduced-unit LJ liquids.  
   https://github.com/Allen-Tildesley/examples/blob/master/GUIDE.md

2. **Swope et al. 1997 — harmonic oscillator Verlet bound** — max relative energy error scales as **dt²/2** for velocity Verlet on a quadratic potential (strict integrator gate).  
   https://doi.org/10.1006/jcph.1997.5740

3. **GROMACS manual — time integration** — leap-frog ≡ Verlet; recommended **dt** tied to σ and system density; neighbor list **Verlet buffer** (skin) sized from maximum particle displacement between rebuilds.  
   https://manual.gromacs.org/current/reference-manual/algorithms/time-integration.html  
   https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html

4. **LAMMPS `neigh_modify` — skin distance** — list cutoff `r_c + skin`; rebuild when any particle moves more than half the skin thickness; pairs `every delay check yes`.  
   https://docs.lammps.org/neighbor.html

---

## MD “CFL” analog (timestep stability)

Classical hyperbolic **CFL** does not apply to short-range MD. The locked stability rule is:

| Quantity | Reduced LJ (σ=ε=m=1) | Li tier-2 / stress |
|----------|----------------------|-------------------|
| Force scale | ~48/r¹³ − 24/r⁷ near r≈2^(1/6) | `li_md_compute_forces` O(N²) MIC |
| Empirical liquid dt | ~0.005–0.01 τ (Frenkel & Smit Ch. 4) | **dt = 0.004** (`LI_MD_DT`, `params.toml`) |
| Integrator gate | Verlet global error O(dt²) on smooth potentials | `harmonic_energy` strict: value < **dt²/2** |
| NVE liquid gate (advisory) | MSD(E/N) < 3×10⁻⁸ @ 40k steps, ρ=0.75 | `nve_energy_msd` — **fails today** (see measured) |

**Symplectic timestep sweep (strict tests, N=256 liquid box only for momentum):**

| dt | `harmonic_energy` max \|ΔE\|/E₀ | threshold (dt²/2) | pass | `momentum_drift` max \|P−P₀\|/N | pass |
|----|----------------------------------|-------------------|------|--------------------------------|------|
| 0.001 | 2.5×10⁻⁷ | 5.0×10⁻⁷ | yes | 4.4×10⁻¹⁶ | yes |
| **0.004** | **4.0×10⁻⁶** | **8.0×10⁻⁶** | **yes** | **1.6×10⁻¹⁵** | **yes** |
| 0.008 | 1.6×10⁻⁵ | 3.2×10⁻⁵ | yes | 1.2×10⁻¹⁵ | yes |
| 0.016 | 6.4×10⁻⁵ | 1.3×10⁻⁴ | yes | 9.9×10⁻¹⁶ | yes |

**Repro:**

```bash
# Native stress (no lic required)
MD_DIR=benchmarks/tier2_physics/md_lennard_jones
cc -O2 -march=native -I"$MD_DIR/common" \
  "$MD_DIR/cpp/md_stress_main.c" "$MD_DIR/common/md_stress.c" -lm \
  -o build/bench/md_lennard_jones/md_stress_native
build/bench/md_lennard_jones/md_stress_native --all

# Full harness (needs ./scripts/build.sh for li column)
python3 benchmarks/harness/stability.py --strict
```

**Measured @ dt=0.004 (2026-05-25, native `md_stress.c`):**

| test | value | threshold | tier | pass |
|------|-------|-----------|------|------|
| `harmonic_energy` | 4.0×10⁻⁶ | 8.0×10⁻⁶ | **strict** | yes |
| `momentum_drift` | 1.1×10⁻¹⁵ | 1.0×10⁻⁸ | **strict** | yes |
| `nve_energy_msd` | 3.8×10⁻³ | 3.0×10⁻⁸ | advisory | **no** |
| `timestep_halving_ratio` | 0.79 | 16 (12–20) | advisory | **no** |

**Interpretation:** Verlet implementation is **valid at the integrator level** (strict rows). LJ NVE liquid conservation is **not AT-grade** until shifted-force + longer equilibration (documented in [PERF.md](../../../benchmarks/tier2_physics/md_lennard_jones/PERF.md)). Do **not** widen `threshold_ratio_cpp` or relax strict thresholds to green advisory rows.

**Policy lock:** tier-2 perf kernel may keep **dt=0.004**; any dt increase requires strict harmonic pass at new dt **and** human approval in a study with locked validity axes.

---

## Neighbor skin / rebuild matrix

| Policy | Incumbent (LAMMPS / GROMACS) | Li `md_core.h` today | Validity risk if wrong |
|--------|------------------------------|----------------------|-------------------------|
| Pair cutoff | `r_c` (LJ cut) | `LI_MD_RC = 2.5` | missed pairs → force spikes |
| List radius | `r_c + skin` | *none* (all pairs within MIC) | N/A at O(N²) |
| Skin thickness | 0.1–0.3 σ typical; GROMACS buffer from v_max·dt | — | too small → missed pairs |
| Rebuild trigger | displacement > skin/2 or `every N` | every force call (implicit full list) | stale list if skin used without rebuild |
| Complexity | O(N) with cell + skin | O(N²) brute MIC | perf only until list wrong |

**Skin sizing rule (for algo 106 implementation):**

```
skin ≥ v_max * dt * safety_factor   # safety_factor ≥ 2 typical
r_list = r_c + skin
rebuild when max_i |r_i(t) - r_i(t_last_rebuild)| > skin / 2
```

At **dt=0.004**, **T=1**, **ρ=0.75**, **N=256**: incumbent codes use **skin ≈ 0.3–0.5** (reduced units) and rebuild every **10–20** steps. Li tier-2 should adopt the same semantics when `md_neighbor_verlet_skin` (106) replaces brute force — **parity check**: brute O(N²) vs cell+skin energies at N=256 before enabling perf claims.

**Registry linkage:**

| id | name | Stability role |
|----|------|----------------|
| 101 | `md_lj_cutoff_mic` | cutoff + MIC correctness |
| 105 | `md_neighbor_cell_list` | must not miss pairs vs brute reference |
| 106 | `md_neighbor_verlet_skin` | skin/rebuild schedule locked here |
| 102 | `md_integrator_verlet` | half-kick–drift–half-kick |
| 103 | `md_energy_drift` | tier-2 trace + stress MSD |

---

## Size scaling (≥3 sizes)

Fixed **ρ = 0.75**, **T = 1**, **r_c = 2.5**, **dt = 0.004**, Verlet. Columns: asymptotic cost, stability evidence, Li status.

| N | L (box) | pairs/step (order) | strict stability @ dt=0.004 | advisory NVE MSD | neighbor mode | Li status |
|---|---------|-------------------|----------------------------|------------------|-----------------|-----------|
| **256** | 7.24 | 3.3×10⁴ (N²/2) | **measured** strict pass | **fail** 3.8×10⁻³ | brute MIC | **tier-2 + stress** |
| **1 024** | 11.5 | 5.2×10⁵ | projected: same integrator | not run | cell + skin target | **planned** (105/106) |
| **4 096** | 18.2 | 8.4×10⁶ | projected | not run | cell + skin + **G-par** | **planned** |
| **32 768** | 36.4 | 5.4×10⁸ | DD + halo (GROMACS) | not run | distributed list | **future** |

**Timestep × size corner (locked before perf):** stability matrix requires **dt sweep at N=256** (table above) before N≥1024 perf work. At larger N, **v_max** may rise slightly → skin must be recomputed, not copied from N=256.

**Tier-2 checksum column (validity, not scaling):** `python3 benchmarks/harness/verify.py --only md_lennard_jones` — fixed N=256 only today.

---

## Tier-0 stability row proposal

Current tier-0 MD coverage is a **placeholder** (`md_energy_single_step.li` returns a constant). Proposed tier-0 row (documentation + implementer handoff):

| Field | Proposed value |
|-------|----------------|
| **bench id** | `md_stability_strict` |
| **track** | `bench_tier0` in [registry.toml](../../../benchmarks/competitive/registry.toml) |
| **harness** | `python3 benchmarks/harness/stability.py --strict` (exit 1 if `harmonic_energy` or `momentum_drift` fail) |
| **strict tests** | `harmonic_energy`, `momentum_drift` only |
| **advisory (non-blocking CI)** | `nve_energy_msd`, `timestep_halving_ratio` until shifted LJ + equilibration |
| **li-tests manifest** | optional row: `suite = "benchmarks"` → wrapper `tier0_correctness/md_verlet_harmonic.li` calling stress scalar via `LI_EXTRA_C=md_stress.c` |
| **Dashboard** | stability.csv languages; link from [benchmarks dashboard](https://li-langverse.github.io/benchmarks/) tier-0 stability chart |

**Do not** mark `implemented_smoke` on 105/106 until cell+skin passes brute-force energy parity at N=256.

---

## Map to Li PH-5b / PH-7e / G-math / G-par

| Track | `md-r1` placement |
|-------|-------------------|
| **PH-5b** | Locked `NumericalTargets`: `max_energy_drift`, `max_momentum_drift`; stress suite = tier-0 evidence |
| **PH-7e** | Pure-Li Verlet must pass same strict harmonic bound before replacing `md_core.c` |
| **G-math** | Scalar harmonic + LJ pair for property tests |
| **G-par** | Size scaling at N≥4096 requires proved disjoint cell traversal **after** skin validity |

---

## Implementation path in lic (next slices)

1. **`sim-p1-md-neighbor-cell` (105)** — brute vs cell checksum at N=256; skin=0 first.
2. **`md_neighbor_verlet_skin` (106)** — implement skin table above; rebuild counter in `md_core`.
3. **Tier-0 row** — add `md_stability_strict` manifest + `stability.py --strict` in `scripts/ci.sh` tier-0 path (already invoked from `bench.py --tier 0`).
4. **Advisory green** — shifted-force LJ in `md_stress.c` + longer equilibration; separate study; no threshold relaxation.
5. **bench_improver** — perf only after strict matrix locked at target N.

---

## Grade matrix

| Axis | Result | vs prior (md-r0) | Notes |
|------|--------|------------------|-------|
| Validity | pass | — | Survey-only; no threshold edits. Tier-2 verify command unchanged. |
| Performance | N/A | — | No perf claims; O(N²) vs O(N) documented only. |
| Memory | N/A | — | Skin/cell reduces neighbor footprint at N≥1k; not measured. |
| Security | pass/skip | — | No native changes. |
| Stability | pass (locked) | **new measured** | Strict harmonic + momentum pass @ dt∈{0.001,0.004,0.008,0.016}; advisory NVE/halving fail documented. |
| Size scaling | table attached | refined | N=256 measured; 1k/4k/32k projected with skin rules. |

---

## Tradeoffs

- **Locked:** validity (+ strict symplectic integrator tests). Advisory AT NVE gates stay **non-blocking** until physics model matches AT examples.
- **Improved:** dt stability table with measured strict passes; skin/rebuild semantics tied to registry 105/106; tier-0 row spec for CI.
- **Regressed:** none (documentation only).
- **Rejected:** relaxing `nve_energy_msd` threshold to pass current 3.8×10⁻³; using advisory pass to enable `implemented_smoke` on neighbor stubs; Berendsen thermostat as stability workaround.

---

## Evidence pack

| Evidence | Path / command |
|----------|----------------|
| numerics doc | This file |
| bench id | `md_lennard_jones` — `python3 benchmarks/harness/stability.py` / `--strict` |
| stress binary | `build/bench/md_lennard_jones/md_stress_native --all` |
| gates | `SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_STUDY_ONLY=1 SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-05-25-md-r1-stability-matrix.md ./scripts/sim-algo-research-gates.sh` |
