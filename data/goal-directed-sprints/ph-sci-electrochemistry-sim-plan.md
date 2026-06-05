---
workflow_repo: lic
branch: cursor/ph-sci-gpu-chem-dft
plan: data/goal-directed-sprints/ph-sci-electrochemistry-sim-plan.md
pr: https://github.com/li-langverse/lic/pull/847
---

# PH-SCI electrochemistry simulation plan

**Status:** WP-ECHEM-01 landed on `cursor/ph-sci-gpu-chem-dft` (CHE/SHE/EDL/NEB stubs + PH-SCI-GPU-19)  
**Entry point:** **Easy electrochemistry** — Computational Hydrogen Electrode (CHE), SHE referencing, scalar electrode potential in DFT energy shift, 1D EDL capacitance toy, static 3-image barrier stub.  
**Parent:** [ph-sci-simulation-gap-close-plan.md](ph-sci-simulation-gap-close-plan.md) · [ph-sci-gpu-chem-dft.md](ph-sci-gpu-chem-dft.md) (GPU DFT kernels) · [chem_sim_algorithms.md](../../docs/research/goals/chem_sim_algorithms.md)

## North star

Li supports **base simulation** of the principal electrochemistry methods (atomistic → mesoscale), with **easy electrochemistry** as the default onboarding path: compute H\* adsorption vs RHE at a chosen potential, reference SHE, estimate Helmholtz capacitance, and read a static barrier — before AIMD, grand-canonical, or TDDFT complexity.

## Research synthesis (structured)

### TL;DR

AIMD and DFT deliver atomistic, electronic-structure–accurate descriptions of electrified interfaces and reaction pathways; classical MD captures long-range solvent and transport reorganization; constrained DFT, grand-canonical formalisms, and ML-accelerated potentials bridge accuracy, length, and time scales.

### Methods overview → Li mapping

| Method | Physical information | Li package / vertical | Notes |
|--------|---------------------|----------------------|-------|
| **DFT static** | Ground-state energies, geometries, adsorption, zero-T barriers, CHE thermodynamics | `li-chem` (`chem_dft_*`) | Existing GPU DFT scaffold; electrochemistry adds potential shift + surface stubs |
| **AIMD** | Finite-T dynamics, explicit solvation, short-time interface events | `li-sim-scientific` + `li-chem` coupling | Registry + multi-physics tick; AIMD = DFT energy eval per MD step |
| **Classical MD** | Large systems, solvent organization, diffusion, outer-sphere reorganization | `li-physics-particles`, solvent extensions | LJ/empirical FF; EDL ion distributions |
| **Constrained DFT / Marcus** | Diabatic states, reorganization energies, ET rates | `li-chem` extension (`echem_*` → future `li-chem-electro`) | Charge-localized states on top of DFT kernel |
| **Grand-canonical / computational SHE** | Electrode potential control, coupled diffuse layer | Electrochemistry vertical (`echem_*`) | Builds on WP-ECHEM-01 SHE stub → explicit GC-DFT |
| **TDDFT / nonadiabatic** | Electronic excitations, e–n coupling beyond BO | `li-physics-quantum` + `li-chem` (Phase 3+) | Deferred until static + AIMD CHE path green |
| **Linear-scaling DFT / ESM** | Larger AIMD cells, uniform field boundaries | `li-chem` + `lig` GPU placement | Aligns with PH-SCI-GPU-CHEM-04 vendor path |
| **ML potentials** | Near-DFT accuracy at MD timescales | `li-ml` bridge to `li-chem` / `li-physics-particles` | Surrogate for AIMD sampling |
| **Multiscale kMC** | SEI growth, long-time interphase evolution | `li-sim-scientific` `run_algo_registry` | DFT/AIMD-derived rates → kMC registry row |

### Strengths and applications (by problem)

| Problem | Best method(s) | Li target |
|---------|----------------|-----------|
| Electrode–electrolyte structure, Helmholtz capacitance | AIMD, classical MD | WP-ECHEM-01 EDL stub → WP-ECHEM-07 PB toy → WP-ECHEM-08 AIMD |
| Reaction barriers, microkinetics | DFT static, NEB | WP-ECHEM-01 NEB stub → WP-ECHEM-05 slab adsorption → full NEB |
| Charge-transfer kinetics (Marcus) | Constrained DFT + MD | WP-ECHEM-10 |
| pKa / redox potentials | AIMD explicit solvation | WP-ECHEM-08 + WP-ECHEM-11 GC-SHE |
| SEI / battery interfaces | AIMD + kMC multiscale | WP-ECHEM-08 + WP-ECHEM-14 |

### Limitations (honesty)

| Challenge | Affected methods | Li response |
|-----------|------------------|-------------|
| Time/length scale | AIMD, ab initio | Classical MD + ML surrogates (Phase 2–3) |
| Electrode potential / finite size | CHE, neutral cells | Grand-canonical WP-ECHEM-11; explicit EDL toys first |
| Charge transfer accuracy | Constrained DFT, diabatic | Marcus stubs after static CHE green |
| Nonadiabatic cost | rt-TDDFT | Phase 3+ WP-ECHEM-12 |
| Multiscale gaps | Continuum vs explicit solvent | kMC registry + parametrized barriers |

### Recent advances → plan hooks

- **Grand-canonical frameworks** → WP-ECHEM-11  
- **Computational SHE + AIMD capacitance** → WP-ECHEM-01 SHE/EDL → WP-ECHEM-08  
- **Linear-scaling / ESM** → PH-SCI-GPU-CHEM vendor + larger cells  
- **ML interatomic potentials** → WP-ECHEM-13  
- **Diabatic / constrained DFT** → WP-ECHEM-10  
- **Multiscale kMC** → WP-ECHEM-14  

---

## Easy electrochemistry track (P0)

Smallest shippable slice — **toy Pt(111) H\*** OR **H₂O/metal slab stub** (geometry in WP-ECHEM-03):

| Capability | WP-ECHEM-01 API | Acceptance |
|------------|-----------------|------------|
| Computational SHE reference | `echem_she_reference_ev()` | Fixed 4.44 eV NHE stub; documented vs experiment |
| CHE H\* vs RHE | `echem_che_h_adsorption_energy(potential_v)` | ΔG decreases with negative U; unit test range |
| Electrode potential shift | `- potential_v` in CHE formula | Scalar U couples to DFT energy shift stub |
| 1D EDL / Helmholtz | `echem_edl_helmholtz_capacitance_stub()` | μF/cm² in physical range (10–30) |
| Static NEB barrier | `echem_static_barrier_neb_stub()` | 3-image path; barrier = TS − min(IS, FS) |
| GPU placement | `echem_gpu_che_h_ads.li` (PH-SCI-GPU-19) | `compile_open_ok` in `science_gpu` |

---

## Work packages

**Effort:** S ≈ 1–3 days, M ≈ 1–2 weeks, L ≈ multi-week.

### Phase 0 — Easy electrochemistry (P0)

#### WP-ECHEM-01 — CHE / SHE / EDL / NEB stubs + GPU smoke

- **Status:** done (2026-06-05)  
- **Scope:** `packages/li-chem/src/lib.li`, `chem_gpu_che_h_ads.li`, `import_echem_che_h_smoke.li`  
- **Dependencies:** `li-chem` DFT kernel (PH-SCI-GPU-CHEM-01)  
- **Acceptance:** `lic build packages/li-chem/src/lib.li --allow-open-vc`; PH-SCI-GPU-19 `compile_open_ok`; composable gate green  

#### WP-ECHEM-02 — PySCF electrochemistry energy oracle

- **Status:** done (2026-06-05) — `bench-ph-sci-echem-competitive.sh`, `ph-sci-electrochemistry.toml`, row `echem_che_h`  
- **Goal:** License-free primary oracle for H adsorption / CHE shift vs PySCF cluster model.  
- **Scope:** `scripts/bench-ph-sci-echem-competitive.sh`, `benchmarks/competitive/ph-sci-electrochemistry.toml`  
- **Dependencies:** WP-ECHEM-01  
- **Acceptance:** JSON row `echem_che_h`; `energy_delta_ev` documented; ORCA user-run only (see [README-chem-dft.md](../../benchmarks/competitive/README-chem-dft.md))  
- **Priority / effort:** P0 / S  

#### WP-ECHEM-03 — H₂O on metal slab geometry stub

- **Status:** done (2026-06-05) — `echem_slab_atom_count`, `echem_slab_geometry_smoke`  
- **Goal:** Replace pure H\* toy with 3-layer Pt slab + single H₂O adsorbate coordinates (no full SCF yet).  
- **Scope:** `echem_slab_atom_count()`, fixed lattice constants in `li-chem`  
- **Dependencies:** WP-ECHEM-01  
- **Acceptance:** Geometry smoke; energies still CHE-shifted scalars  
- **Priority / effort:** P1 / S  

#### WP-ECHEM-04 — `verticals.toml` + competitive row honesty

- **Status:** done (2026-06-05) — `echem_che_h` flipped to `workload_class=pilot`, `oracle=pyscf`  
- **Goal:** `echem_che_h` row with `workload_class=stub` until PySCF oracle green.  
- **Scope:** `benchmarks/competitive/verticals.toml`, `ph-sci-electrochemistry.toml`, `ph-sci-echem-competitive-gates.sh`  
- **Dependencies:** WP-ECHEM-02  
- **Acceptance:** Row cited in Studio claims; flip to `pilot` when oracle passes  
- **Priority / effort:** P0 / S (row added at ECHEM-01; flip at ECHEM-02)  

---

### Phase 1 — Static electrochemistry on DFT kernel (P1)

#### WP-ECHEM-05 — Pt(111) H\* adsorption from `chem_dft_energy_kernel`

- **Status:** done (2026-06-05) — `echem_dft_h_star_energy_hartree`, `echem_dft_h2_energy_hartree`, CHE from SCF  
- **Goal:** Bind CHE adsorption to converged SCF energy difference (H\* + slab − ½ H₂).  
- **Packages:** `li-chem`  
- **Dependencies:** PH-SCI-GPU-CHEM-04, WP-ECHEM-01  
- **Acceptance:** Energy within PySCF tolerance on mini basis; bench row green  
- **Priority / effort:** P1 / M  

#### WP-ECHEM-06 — Potential-dependent SCF (scalar U in Fock shift)

- **Status:** done (2026-06-05) — `echem_dft_energy_at_potential`, `chem_dft_fock_apply_potential_shift`, volcano smoke  
- **Goal:** `echem_dft_energy_at_potential(u_v)` applies `-eU` shift to electron chemical potential.  
- **Dependencies:** WP-ECHEM-05  
- **Acceptance:** Volcano trend vs U; matches CHE stub at toy geometry  
- **Priority / effort:** P1 / M  

#### WP-ECHEM-07 — 1D EDL Poisson–Boltzmann toy

- **Status:** done (2026-06-05) — `echem_edl_pb_capacitance_uf_cm2`, `echem_edl_pb_vs_helmholtz_smoke`  
- **Goal:** Replace capacitance constant with solved ψ(x) on 32-point grid; C = dσ/dU.  
- **Packages:** `li-chem` or `li-math-numerics`  
- **Dependencies:** WP-ECHEM-01  
- **Acceptance:** C within 20% of Helmholtz stub at same ε, d  
- **Priority / effort:** P1 / M  

#### WP-ECHEM-08 — Full static NEB (3+ images)

- **Status:** done (2026-06-05) — `echem_static_barrier_neb`, 5-image DFT linear interp + climbing bump  
- **Goal:** Replace barrier stub with climbing-image or linear interpolation NEB on 1D reaction coordinate.  
- **Dependencies:** WP-ECHEM-05  
- **Acceptance:** Barrier ≥ stub oracle; `compile_open_ok` smoke  
- **Priority / effort:** P1 / M  

---

### Phase 2 — Dynamics and charge transfer (P1–P2)

#### WP-ECHEM-09 — AIMD coupling (DFT + MD tick)

- **Status:** done (2026-06-05) — `sim_scientific_oracle_checksum_echem_aimd`, `algo_echem_aimd_interface` (433), `echem_aimd_interface_smoke.li`  
- **Goal:** `li-sim-scientific` registry row `echem_aimd_interface`; each MD step calls `chem_dft_energy_kernel_hartree`.  
- **Packages:** `li-sim-scientific`, `li-chem`  
- **Dependencies:** WP-ECHEM-05, WP-SCI-GPU-02  
- **Acceptance:** Energy drift oracle over 8 AIMD steps (toy thermostat)  
- **Priority / effort:** P1 / L  

#### WP-ECHEM-10 — Classical MD solvent shell

- **Status:** done (2026-06-05) — `echem_solvent_gr_peak_smoke`, `ph-sci-echem-solvent-gr-reference.json`  
- **Goal:** Explicit water sphere around slab via `li-physics-particles` LJ + Ewald stub.  
- **Packages:** `li-physics-particles`  
- **Dependencies:** WP-ECHEM-03  
- **Acceptance:** Radial g(r) peak smoke vs reference JSON  
- **Priority / effort:** P1 / M  

#### WP-ECHEM-11 — Constrained DFT / Marcus reorganization stub

- **Goal:** Two charge-localized states; λ = E(D⁺A⁻) − E(DA) diabatic gap toy.  
- **Packages:** extend `li-chem` (`echem_marcus_lambda_stub`)  
- **Dependencies:** WP-ECHEM-06  
- **Acceptance:** λ > 0; Marcus rate monotonic in coupling  
- **Priority / effort:** P2 / M  

---

### Phase 3 — Advanced formalisms (P2–P3)

#### WP-ECHEM-12 — Grand-canonical / computational SHE AIMD

- **Goal:** μ_electron(U) boundary condition; constant-potential MD scaffold.  
- **Dependencies:** WP-ECHEM-09, WP-ECHEM-06  
- **Acceptance:** Charge neutrality drift < tol over 10 steps (toy cell)  
- **Priority / effort:** P2 / L  

#### WP-ECHEM-13 — TDDFT / nonadiabatic (deferred)

- **Goal:** Coupled electron-nuclear step beyond BO for ET barrier crossing.  
- **Packages:** `li-physics-quantum`, `li-chem`  
- **Dependencies:** WP-ECHEM-11  
- **Acceptance:** Documented stub only until PH-SCI-GPU vendor path matures  
- **Priority / effort:** P3 / L  

#### WP-ECHEM-14 — ML-accelerated potentials

- **Goal:** `li-ml` surrogate wraps AIMD energy calls; 10× step count at same accuracy band.  
- **Packages:** `li-ml`, `li-chem`  
- **Dependencies:** WP-ECHEM-09, PH-ML spine  
- **Acceptance:** Energy MAE vs DFT kernel on holdout frames  
- **Priority / effort:** P2 / L  

#### WP-ECHEM-15 — Multiscale kMC (SEI growth registry)

- **Goal:** `run_algo_registry` id for `echem_sei_kmc`; rates from WP-ECHEM-08 barriers.  
- **Packages:** `li-sim-scientific`  
- **Dependencies:** WP-ECHEM-08, WP-ECHEM-14  
- **Acceptance:** Registry checksum tier-2; growth law vs analytic oracle  
- **Priority / effort:** P2 / L  

---

## Cross-links

| Resource | Link |
|----------|------|
| GPU DFT plan | [ph-sci-gpu-chem-dft.md](ph-sci-gpu-chem-dft.md) |
| Simulation gap-close | [ph-sci-simulation-gap-close-plan.md](ph-sci-simulation-gap-close-plan.md) |
| PR #847 | `cursor/ph-sci-gpu-chem-dft` |
| Competitive bench (DFT) | `scripts/bench-ph-sci-chem-dft-competitive.sh` |
| Competitive bench (echem) | WP-ECHEM-02 → `ph-sci-electrochemistry.toml` |
| Layer B registry | `benchmarks/competitive/verticals.toml` → `echem_che_h` |
| PySCF oracle (primary) | Apache-2.0; H cluster / minimal slab in WP-ECHEM-02 |
| ORCA oracle | Academic free, **not** redistributable in CI — user-run external |
| science_gpu gate | `scripts/check-science-gpu-gate.sh` (PH-SCI-GPU-19 additive) |
| chem GPU gate | `scripts/ph-sci-gpu-chem-gates.sh` |

### PySCF / ORCA comparison methodology (electrochemistry energies)

1. **Primary (CI):** PySCF RKS/LDA single-point on fixed H/Pt toy geometry; compute ΔE_ads and apply CHE shift `−eU` vs Li `echem_che_h_adsorption_energy`.  
2. **Tolerance:** Large `energy_delta_ev` expected until WP-ECHEM-05 couples real SCF; report ratio and document stub honesty.  
3. **ORCA:** Optional user-run; same geometry/basis in input deck; results pasted to `benchmarks/results/ph-sci-echem-competitor-orca.json` (not bundled).  
4. **Flip `verticals.toml`:** `workload_class=stub` → `pilot` only when WP-ECHEM-02 gate passes with documented tolerance.

---

## Iteration rules

1. **P0 first:** WP-ECHEM-01 → WP-ECHEM-02/04 before AIMD or GC-DFT.  
2. One WP per iteration; commit + push to `cursor/ph-sci-gpu-chem-dft` (PR #847).  
3. Verify: `bash scripts/ph-sci-gpu-chem-gates.sh` (includes science_gpu + chem DFT bench).  
4. Do not claim VASP/CP2K parity — PySCF mini-model oracle only.

## Completion gate (Phase 0)

```bash
# WSL from lic repo root (lic-chem-wt on cursor/ph-sci-gpu-chem-dft)
./build-wsl/compiler/lic/lic build packages/li-chem/src/lib.li --allow-open-vc
bash scripts/ph-sci-gpu-chem-gates.sh
./li-tests/run_all.sh science_gpu  # includes PH-SCI-GPU-19
```

---

## K8s handoff

Dedicated worker: `li-ph-sci-electrochemistry` — see `li-cursor-agents/deploy/k8s/engine/README.md`.

```bash
cd li-cursor-agents
export KUBECONFIG=~/.kube/config-homelab
bash scripts/setup-engine-k8s-ph-sci-electrochemistry.sh
kubectl -n li-swarm scale deploy/li-ph-sci-electrochemistry --replicas=1
kubectl -n li-swarm logs -f deploy/li-ph-sci-electrochemistry
```

Goal file: `data/goal-directed-sprints/ph-sci-electrochemistry-gpu-roadmap.md` (combined echem + GPU chem + gap-close).

---

## WP index (15 packages)

| ID | Title | Phase | Priority | Status |
|----|-------|-------|----------|--------|
| WP-ECHEM-01 | CHE/SHE/EDL/NEB stubs + GPU-19 | 0 | P0 | **done** |
| WP-ECHEM-02 | PySCF echem oracle | 0 | P0 | **done** |
| WP-ECHEM-03 | H₂O slab geometry stub | 0 | P1 | **done** |
| WP-ECHEM-04 | verticals.toml honesty flip | 0 | P0 | **done** |
| WP-ECHEM-05 | H\* from DFT kernel | 1 | P1 | **done** |
| WP-ECHEM-06 | Potential-dependent SCF | 1 | P1 | **done** |
| WP-ECHEM-07 | 1D EDL Poisson–Boltzmann | 1 | P1 | **done** |
| WP-ECHEM-08 | Full static NEB | 1 | P1 | **done** |
| WP-ECHEM-09 | AIMD coupling | 2 | P1 | **done** |
| WP-ECHEM-10 | Classical MD solvent | 2 | P1 | **done** |
| WP-ECHEM-11 | Constrained DFT / Marcus | 2 | P2 | open |
| WP-ECHEM-12 | Grand-canonical SHE AIMD | 3 | P2 | open |
| WP-ECHEM-13 | TDDFT nonadiabatic | 3 | P3 | open |
| WP-ECHEM-14 | ML potentials | 3 | P2 | open |
| WP-ECHEM-15 | Multiscale kMC | 3 | P2 | open |
