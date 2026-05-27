# Chemistry / QM algorithms — SOTA survey and Li gap analysis (`chem-r0-qm-sota-survey`)

**Goal:** `chem_sim_algorithms` · **Session:** `66d1f3bf-7ced-4520-95f5-7c6fba34da72` · **Run:** `numerics_researcher-1779869405908`  
**Agent:** `numerics_researcher` · **Mode:** study-only (validity locked; no perf claims)  
**North star:** PH-5b (proved numerics), PH-7e (math→SIMD on integral/ERI loops), G-math / G-par for AO contraction kernels  
**Preflight:** `benchmarks/data/latest/ecosystem-audit.json` @ 2026-05-27T08:10Z · [dashboard](https://li-langverse.github.io/benchmarks/)

---

## Problem

Li’s chemistry vertical must reach **Gaussian/ORCA/Psi4-class** minimal workflows (AO integrals → Fock build → SCF → DFT energy) without trading **SCF convergence honesty** or **basis-set correctness** for `ratio_vs_cpp`. Today **algo_registry 401–432** rows are **catalog compile smokes** (`implemented_smoke: true`) wired to the **`schrodinger_1d_barrier` family template** — not quantum-chemistry kernels. `li-sim-scientific` routes `vertical_qm_dft()` to `run_algo_registry_stub` for all registry QM ids except the vertical entry point, which calls `algo_qm_dft_scf_energy()` but still returns a stub checksum. **All 32 `qm_*` catalog rows** are **unknown** on the dashboard (harness pending); no red QM timing rows yet because timing is deferred.

---

## Learned from (SOTA)

1. **Psi4** — Python QC reference; minimal Hartree–Fock/DFT energy APIs, basis-set library, DIIS SCF.  
   - Docs: https://psicode.org/ , https://psicode.org/psi4manual/master/tutorial.html  
   - **Takeaway for Li:** v1 oracle path = **Psi4 single-point** on H₂/H₂O with STO-3G and 6-31G* before native RKS; use as `external_binary` honesty in `verticals.toml`.

2. **PySCF** — Modular AO integrals, density-fitting ERIs, RKS/UKS drivers; cost scales as O(N_basis⁴) naive ERIs, O(N²–N³) with DF.  
   - Docs: https://pyscf.org/user.html , https://pyscf.org/user/scf.html  
   - **Takeaway:** Implement **401–404 integral chain** (GTO eval, overlap, kinetic, nuclear attraction) before **408 Fock** or **418 `qm_dft_scf_energy`**; density fitting (407) is a PH-7e target, not v1.

3. **ORCA** — Production DFT (GGA/hybrid/grid); Becke/Lebedev grids and XC families map directly to registry ids **412–417**.  
   - Manual: https://www.faccts.de/orca/manual/ , https://doi.org/10.1063/1.4824486 (RI-JK)  
   - **Takeaway:** Grid/XC rows stay **stub honesty** until LDA (412) passes reference energies on a fixed geometry.

4. **Helgaker et al. / Szabo & Ostlund** — Standard AO integral recurrences, SCF stability, basis-set limit behavior.  
   - Text: *Molecular Electronic-Structure Theory* (Helgaker, Jørgensen, Olsen); *Modern Quantum Chemistry* (Szabo, Ostlund)  
   - **Takeaway:** Basis-size table (`chem-r1`) must show **monotonic energy improvement** and **O(N_basis⁴)** wall-time trend for naive ERIs before perf claims.

---

## SOTA → Li mapping (algo_registry 401–432)

| ID | Registry name | Incumbent pattern | Li package / bench | Harness on `main` | PH / proof |
|----|---------------|-------------------|--------------------|-------------------|------------|
| 401 | `qm_gto_eval` | Libint / PySCF `gto` | `std/physics/chem.li` (tag only) | Smoke → `schrodinger_1d_barrier` template | PH-5b integral bounds |
| 402–404 | overlap / kinetic / nuclear | PySCF `intor` | Registry smoke | Template only | G-math: Gaussian recurrence |
| 405–407 | ERI OS / screening / DF | ORCA RI-JK, Psi4 DF | Catalog smoke | Template only | PH-7e after parity |
| 408–411 | HF Fock / DIIS / ortho / SCF | Psi4 `scf`, ORCA SCF | `qm_scf_solver`, `qm_hf_*` smokes | Template only | SCF convergence = validity axis |
| 412–417 | DFT XC / grid / hybrid | ORCA/Psi4 functional libs | `qm_dft_*` tier-2 paths | **Compile smoke**; `size_label=harness pending` | Locked until LDA ref energy |
| 418 | `qm_dft_scf_energy` | Psi4 `energy('b3lyp')` | `li-sim-scientific` vertical route | Template only | **v1 implement target** (`chem-r2`) |
| 419–421 | grad / geom opt | ORCA `Opt` | Catalog smoke | Template only | Defer until 418 green |
| 422–425 | MP2 / CCSD / TDDFT | Psi4 correlated | Catalog smoke | Template only | Post-HF deferred |
| 426–428 | xTB / D3 / ECP | Grimme xTB, DFT-D3 | Catalog smoke | Template only | Optional semiempirical track |
| 429–432 | ASE / properties / job IO | PySCF + ASE | `qm_job_queue_io` | Template only | Composable workflow only |

**Vertical honesty** (`benchmarks/competitive/verticals.toml` in sim worktrees): `qm_dft` — incumbent Gaussian/ORCA/Psi4, `workload_class=stub`, `oracle=external_binary`, notes **not parity** until `import_chem_dft_smoke` composable gate passes.

---

## Basis-size scaling (survey targets — fill in `chem-r1`)

Reference: PySCF H₂ cc-pVDZ vs STO-3G single-point timings. Li stub must reproduce **trend** before absolute Ha parity.

| Basis | AO count (H₂) | Dominant cost | Li action |
|-------|---------------|---------------|-----------|
| STO-3G | 2 | O(N⁴) ERI | v1 reference geometry |
| 6-31G | 4 | Same | Convergence damping study |
| cc-pVDZ | 10 | Memory + ERI | PH-7e SIMD / screening target |

**Repro (when native stub exists):**

```bash
cd lic/benchmarks/harness
python3 bench.py --tier 2 --only qm_dft_scf_energy --runs 3
cd benchmarks && LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
```

---

## Implementation path in lic (contracts + bench evidence)

1. **Validity first (PH-5b):** Add `common/qm_scf_core.c` (or reuse Psi4 subprocess oracle) for H₂ STO-3G total energy; `verify-results` checksum before wall time. No `threshold_ratio_cpp` relaxation (catalog default **1.2**).
2. **Integral microkernel chain (401–404):** Port closed-form s-type overlaps then general `(μν|λσ)` via Obara–Saika recurrence in `packages/li-physics-quantum` (new) or extend `std/physics/quantum.li` beyond tag stub.
3. **SCF driver (411, 418):** DIIS + level-shifting in `qm_scf_solver`; `li-sim-scientific` must call real `run_qm_dft_scf_energy_smoke` instead of `run_algo_registry_stub` for id 418.
4. **PH-7e / G-par:** ERI contraction and Fock build — `@vectorized` / `parallel for (disjoint=)` only after `lic build` proves integral symmetry lemmas.
5. **Composable gate:** `li-tests/composable/import_chem_dft_smoke.li` + `qm_dft.toml`; flip `verticals.toml` `workload_class` only when smoke passes.
6. **Worktree:** Deep gates in `lic-worktrees/sim-chem-research` only — no new systemd sim loops on `main`.

**Do not:** weaken `threshold_ratio_cpp`; ship `sorry`/`unsafe` for speed; copy harness into **benchmarks** repo; claim Gaussian/ORCA parity from `schrodinger_1d_barrier` template timings.

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Validity | **pass (survey)** | — | Registry smokes honest; vertical `stub` + `external_binary` |
| Stability | **document** | — | SCF convergence (max iter, damping) required before perf |
| Performance | **document only** | — | All `qm_*` unknown — no ratio rows yet |
| Memory | N/A | — | Defer until ERI allocation profiled |
| Security | pass | — | External oracle = optional subprocess; no new trusted C without audit |
| Accuracy | table attached | — | Basis-size targets in `chem-r1`; Ha refs from Psi4 |

---

## Tradeoffs

- **Locked:** validity (SCF convergence, reference energies), accuracy (basis-set monotonicity), registry honesty for template smokes.
- **Improved:** Clear SOTA→registry map; v1 scope = **418 + integral chain 401–404**; Psi4 external oracle path documented.
- **Regressed:** none (survey-only).
- **Explicitly not approved:** trading tier-0 tolerances or `threshold_ratio_cpp` for green dashboard cells; production DFT accuracy claims.

---

## Evidence

| Type | Path / command |
|------|----------------|
| Study | `docs/numerics/studies/2026-05-27-chem-r0-qm-sota-survey.md` |
| Whitepaper | `research-findings/whitepapers/2026-05/chem_sim_algorithms/chem-r0-qm-sota-survey/` |
| Preflight audit | `benchmarks/data/latest/ecosystem-audit.json` (32 unknown `qm_*` rows) |
| Catalog | `benchmarks/catalog.toml` — `qm_dft_scf_energy`, `qm_dft_xc_*`, … |
| Registry | `lic/benchmarks/competitive/algo_registry.json` ids 401–432 |
| Backlog | `lic/docs/ecosystem/sim-chem-research-backlog.md` |
| Composable | `li-sim-scientific` `run_simulation(vertical_qm_dft())` |
| Bench repro | `python3 lic/benchmarks/harness/bench.py --tier 2 --only qm_dft_scf_energy` (when harness lands) |
