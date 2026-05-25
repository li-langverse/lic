# MD neighbor cell-list gap — SOTA vs Li stub (`md-r2-neighbor-list-gap`)

**Date:** 2026-05-25  
**Vertical:** `md`  
**Work item:** `md-r2-neighbor-list-gap` (`study_only: false` — gates + implementer handoff)  
**Grading:** [sim-algo-research-grading.md](../../ecosystem/sim-algo-research-grading.md)  
**Prior studies:** [md-r0-sota-survey](./2026-05-25-md-r0-sota-survey.md) · [md-r1-stability-matrix](./2026-05-25-md-r1-stability-matrix.md)  
**Registry:** [algo_registry.json](../../../benchmarks/competitive/algo_registry.json) — **algo 105** `md_neighbor_cell_list`, related **106** `md_neighbor_verlet_skin`  
**Implement handoff:** `sim-p1-md-neighbor-cell` on `cursor/sim-algo-plan-loop`

---

## Scope

Close the **honesty gap** between registry row **105** (`implemented_smoke: true`) and actual Li physics:

| Layer | Claim today | Reality |
|-------|-------------|---------|
| `md_core.h` header | “cell-linked list” | `li_md_compute_forces` is **O(N²)** brute MIC (lines 172–199) |
| `algo_registry.json` id **105** | smoke implemented | `run_algo_registry_stub` → fixed checksum **1.001**; no list build |
| `li-physics-particles` | MD helpers | `lj_force_scalar`, `md_mini_step` (N=16); **no** cell traversal API |
| Tier-2 `md_lennard_jones` | checksum gate | Valid for **brute** reference; unchanged until cell path proves parity |

This study specifies **incumbent cell-list semantics** (LAMMPS / GROMACS / OpenMM), a **size-scaling** table (≥3 N), **PH-5b / PH-7e / G-math / G-par** placement, and a **lic** implementation contract for **`sim-p1-md-neighbor-cell`**. No `threshold_ratio_cpp` edits; no `implemented_smoke` promotion without brute-force parity at N=256.

---

## Learned from (external references)

1. **LAMMPS — neighbor styles (`bin`, `nsq`)** — spatial bins of width ≥ cutoff; each atom searches own bin + adjacent bins; `neighbor bin` is the production O(N) path vs `nsq` for tiny systems. Skin and rebuild are separate (`neigh_modify`).  
   https://docs.lammps.org/neighbor.html

2. **GROMACS manual — neighbor searching** — **charge-group** based pair search on a **3D grid**; list radius includes **Verlet buffer**; list rebuilt when displacement exceeds buffer/2; domain decomposition adds **halo** cells at rank boundaries.  
   https://manual.gromacs.org/current/reference-manual/algorithms/neighbor-searching.html

3. **OpenMM User Guide — `NonbondedForce` and periodic boundaries** — short-range pair list inside cutoff (with switching); integrators assume lists are rebuilt on a schedule; for large systems the runtime uses spatial hashing (implementation detail) with same **no missed pairs inside r_c** invariant.  
   http://docs.openmm.org/latest/userguide/application/02_standard_forces.html

4. **Frenkel & Smit — *Understanding Molecular Simulation* (Ch. 3–4)** — **cell-linked list**: cell width *h* ≥ *r_c*; average O(N) pair checks when *h* chosen so each cell holds O(1) particles at target ρ; half-shell or full 26-neighbor stencil avoids double counting.  
   https://www.sciencedirect.com/book/9780123872324/understanding-molecular-simulation (textbook; algorithm standard in MD curricula)

---

## Incumbent cell-list contract (locked for Li)

| Parameter | LAMMPS `neighbor bin` | GROMACS grid | Li tier-2 target (`md_core`) |
|-----------|----------------------|--------------|------------------------------|
| Cutoff | `pair_cutoff` / `r_c` | `rvdw` | `LI_MD_RC = 2.5` |
| Cell width *h* | ≥ `r_c` (often = `r_c` initially) | from list + buffer | **h = LI_MD_RC** (skin=0 phase for 105) |
| Stencil | 3×3×3 − self (or half-shell) | 26 cells + DD halo | 26 neighbor cells, MIC across PBC |
| Pair test | `r² < r_c²`, MIC | same | same LJ kernel as brute loop |
| List radius (phase 2) | `r_c + skin` | `r_c + buffer` | defer to algo **106** |
| Validity gate | energy/force vs `nsq` | regression tests | **max \|F_cell − F_brute\|**, **PE parity** @ N=256 |

**Half-shell convention (recommended for Li):** for each cell pair (cx,cy,cz) ≤ (cx′,cy′,cz′) in lex order, iterate particles in cell A against cell B; for A=B use `j > i` only. Matches LAMMPS “half neighbor list” spirit and avoids duplicate i–j.

---

## Li gap analysis (algo 105)

### Registry row 105

```json
{ "id": 105, "name": "md_neighbor_cell_list", "family": "md", "implemented_smoke": true }
```

| Check | Status | Evidence |
|-------|--------|----------|
| Composable calls algo 105 | stub only | `run_algo_registry_stub` in `packages/li-sim-scientific/src/lib.li` |
| Tier-2 uses cell list | **no** | `li_md_compute_forces` all-pairs in `benchmarks/tier2_physics/md_lennard_jones/common/md_core.h` |
| Package API `neighbor_*` | **no** | `packages/li-physics-particles/src/lib.li` |
| Bench checksum documents list mode | **no** | `md_lennard_jones` checksum is brute-path fingerprint |

**Honesty rule (from md-r0):** `implemented_smoke: true` on 105 means registry/composable wiring only. **SOTA gap** = missing O(N) force path + parity proof. Implementer must not interpret smoke as production neighbor search.

### Related rows

| id | name | Relationship to 105 |
|----|------|---------------------|
| 101 | `md_lj_cutoff_mic` | Pair kernel + MIC — reuse inside cell loops |
| 102 | `md_integrator_verlet` | Calls force each step — unchanged schedule |
| 106 | `md_neighbor_verlet_skin` | **After** 105: extend list radius, rebuild counter (md-r1 skin table) |
| 103 | `md_energy_drift` | Drift metric must match when switching brute → cell |

---

## Size scaling (≥3 sizes)

Fixed **ρ ≈ N/L³**, **r_c = 2.5**, **h = r_c** (no skin in phase 1). **n_cell = floor(L/h)** per dimension. Approximate mean occupancy **⟨n⟩ ≈ ρ h³**.

| N | L (box) | n_cell | cells total | ⟨n⟩ per cell | neighbor cells / atom | pair checks / step (cell, order) | pair checks (brute) | Li status |
|---|---------|--------|-------------|--------------|----------------------|----------------------------------|---------------------|-----------|
| **256** | 10.0 | 4 | 64 | ~4.0 | ≤ 27 | O(N·⟨n⟩·27) ≈ **2.8×10⁴** | 3.3×10⁴ | **tier-2 today** — brute only |
| **4 096** | 18.2 | 7 | 343 | ~11.9 | ≤ 27 | O(N) ≈ **5×10⁵** | 8.4×10⁶ | **target** — 105 + checksum vs brute |
| **32 768** | 36.4 | 14 | 2 744 | ~11.9 | ≤ 27 (+ DD halo) | O(N/P) per rank | 5.4×10⁸ | **future** — **G-par** + halo |

**Cell-width scaling (same ρ):** as N grows, L ∝ N^(1/3) so **n_cell ∝ N^(1/3)**; ⟨n⟩ stays ~ρ h³ (constant if h = r_c). Dominant win is **O(N)** vs **O(N²)** force evaluation, not shrinking ⟨n⟩.

**Timestep column (stability locked, md-r1):** at N=256, **dt = 0.004** passes strict `harmonic_energy` / `momentum_drift`; cell-list implementation must **not** change integrator or dt when validating 105.

---

## Map to PH-5b / PH-7e / G-math / G-par

| Track | Algo 105 placement |
|-------|-------------------|
| **PH-5b** | Contract: cell list preserves MIC + cutoff invariants; tier-2 `verify.py` / trace checksum unchanged after parity proof |
| **PH-7e** | Pure-Li cell traversal only **after** C reference passes parity; subject to `bench.py` DCE guard |
| **G-math** | Scalar pair inside cells; optional `@vectorized` over particles in one cell |
| **G-par** | Parallel cell build + force reduce with `disjoint=` rows — required N ≥ 4k; not part of initial 105 slice |

---

## Proposed implementation path in **lic** (`sim-p1-md-neighbor-cell`)

### Phase A — Reference C in `md_core` (validity first)

1. Add `LiMdCellHead`, `LiMdCellList` (or static grid for fixed `LI_MD_BOX`, `LI_MD_RC`).
2. `li_md_cell_assign(s)` — hash each particle to `(ix,iy,iz)` with PBC wrap.
3. `li_md_compute_forces_cell(s, list)` — half-shell stencil, same LJ as brute.
4. `li_md_compute_forces_brute(s)` — keep for `#ifdef LI_MD_VERIFY_NEIGHBOR` parity tests.
5. **Gate:** at N=256, max force component diff < 1e-10 rel; PE rel diff < 1e-12; full trajectory checksum match for 10k steps.

### Phase B — Composable / registry honesty

1. `packages/li-physics-particles`: `neighbor_cell_build`, `neighbor_cell_pair_count` on fixed small N (e.g. 16) for lit/li-tests.
2. `li-sim-scientific`: `run_md_neighbor_cell_smoke` → algo **105** with checksum from real list ops (not 1.001).
3. Update **registry comment** in study/backlog only; set `implemented_smoke` meaning in traceability — full parity still requires tier-2 verify.

### Phase C — Bench / dashboard (coordinate **bench_improver**)

1. Optional `params.toml` key `neighbor = "cell"|"brute"` for A/B timing **after** validity.
2. Do **not** weaken `threshold_ratio_cpp`; perf claims only when verify green on cell path.

### Phase D — algo 106 (separate todo)

Skin + rebuild per [md-r1-stability-matrix](./2026-05-25-md-r1-stability-matrix.md); amortize list builds; still require brute/cell energy match at N=256 before perf.

---

## Registry map (focused rows)

Machine-readable fields: `benchmarks/competitive/algo_registry.json` → `research_map` keys **101**, **102**, **105**, **106**.

| id | name | Incumbent | Li today | PH / G | Next action |
|----|------|-----------|----------|--------|-------------|
| 105 | `md_neighbor_cell_list` | LAMMPS `neighbor bin`; GROMACS grid | **stub** + brute tier-2 | **G-par** (later) | **`sim-p1-md-neighbor-cell`** — implement §Phase A–B |
| 106 | `md_neighbor_verlet_skin` | `neigh_modify skin` | not implemented | **G-par** + schedule | Blocked on 105 parity |
| 101 | `md_lj_cutoff_mic` | LJ+cut+MIC | in brute loop | **G-math** | Reuse in cell inner loop |
| 102 | `md_integrator_verlet` | Verlet | `li_md_step` | **PH-5b** | No change for 105 |

---

## Grade matrix

| Axis | Result | vs prior (md-r1) | Notes |
|------|--------|------------------|-------|
| Validity | pass | — | Study documents gap; no threshold edits. Tier-2 brute checksum remains authoritative until cell parity lands. |
| Performance | N/A | — | Scaling table gives asymptotic O(N) vs O(N²); no wall-time claims. |
| Memory | N/A | — | Cell head arrays add O(N + n_cell³) integers; smaller pair footprint at N≥4k — not measured. |
| Security | pass/skip | — | No native FFI changes in this deliverable. |
| Stability | pass (locked) | — | dt=0.004 / Verlet unchanged; cell list must not alter symplectic path. |
| Size scaling | table attached | **refined for 105** | N = 256 / 4096 / 32768 with n_cell and pair-order estimates. |

---

## Tradeoffs

- **Locked:** validity (+ integrator stability from md-r1). No missed pairs inside `r_c`; no `implemented_smoke` upgrade without N=256 brute/cell parity.
- **Improved:** Explicit incumbent cell-list contract; half-shell + MIC spec; size-scaling with n_cell columns; clear stub vs tier-2 vs registry honesty.
- **Regressed:** none (documentation only).
- **Rejected:** treating registry `implemented_smoke: true` on 105 as implementation complete; shipping cell list without brute reference check; widening verify thresholds to pass Li column before parity; perf work before Phase A gate.

---

## Evidence pack

| Evidence | Path / command |
|----------|----------------|
| numerics doc | This file |
| bench id | `md_lennard_jones` — tier-2 brute reference (`benchmarks/tier2_physics/md_lennard_jones/`) |
| stability | `python3 benchmarks/harness/stability.py --strict` (integrator locked, md-r1) |
| gates (study present) | `SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_STUDY_ONLY=1 SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-05-25-md-r2-neighbor-list-gap.md ./scripts/sim-algo-research-gates.sh` |
| gates (full vertical) | `SIM_RESEARCH_VERTICAL=md ./scripts/sim-algo-research-gates.sh` (requires `lic` + `sim-plan-gates.sh`) |
| implement handoff | `sim-p1-md-neighbor-cell` → `cursor/sim-algo-plan-loop` |
