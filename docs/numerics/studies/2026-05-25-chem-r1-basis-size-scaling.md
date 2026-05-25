# Basis-size scaling for stub QM SCF — `chem-r1-basis-size-scaling`

**Date:** 2026-05-25  
**Vertical:** `chem` (`qm_dft`, registry ids **401–432**)  
**Mode:** study-only (`study_only: true`)  
**Prior:** [chem-r0 SOTA survey](./2026-05-25-chem-r0-sota-survey.md)  
**Grading:** [sim-algo-research-grading.md](../../ecosystem/sim-algo-research-grading.md)  
**Registry:** `benchmarks/competitive/algo_registry.json`  
**Li smoke today:** `run_algo_registry_stub` → `checksum = 1.001` for all QM ids; **no basis dependence**.

---

## Learned from

| # | Reference | URL | Takeaway for Li stub → real SCF |
|---|-----------|-----|----------------------------------|
| 1 | **Psi4** — Basis set tables & aliases | https://psicode.org/psi4manual/master/basissets_byfamily.html | Basis name drives **N\_basis** and integral class count; STO-3G → augmented triple-zeta is a staged test matrix, not one-shot production. |
| 2 | **PySCF** — `mol.basis` + DFT driver | https://pyscf.org/user/gto.html | Same geometry + `mf.xc = 'b3lyp'` + `mf.grids.level` is the minimal reproducible loop for **412–418** cost/accuracy sweeps. |
| 3 | **Gaussian 16** — Basis set keywords | https://gaussian.com/basis/ | Route-line basis (`STO-3G`, `6-31G*`, `cc-pVTZ`) is the user-facing knob Li must surface in `metrics.basis` per [sim-output-contract.md](../../ecosystem/sim-output-contract.md). |
| 4 | **ORCA 5** — Basis blocks & RI | https://www.faccts.de/orca/manual/contents/basissets.html | RI-JK / density fitting changes **cost** exponent without changing **validity** tier when auxiliary basis is locked; Li studies must name auxiliary + primary basis together. |

---

## Problem statement (stub SCF)

`algo_qm_dft_scf_energy()` (**418**) and sibling QM registry rows (**401–417**) route through `run_algo_registry_stub`:

```71:99:packages/li-sim-scientific/src/lib.li
def run_algo_registry_stub(algo_id: int, detail: int) -> SimRunResult
  ...
  r.checksum = 1.001
  r.detail_emitted = detail
  return r
```

**Honesty:** wall time and energy are **O(1)** in basis today; any perf claim on QM vertical is invalid until **401–418** consume real `N_basis` and grid size. This study locks the **cost/accuracy axes** for the first non-stub tranche (**chem-r2** / `sim-p2-qm-dft-scf`).

### Proposed `detail` → basis staging (not implemented)

| `detail` (`output_detail_*`) | Basis (proposed) | Registry focus |
|------------------------------|------------------|----------------|
| 0 `summary` | STO-3G | smoke / CI fast path |
| 1 `fields` | 6-31G* | default regression |
| 2 `debug` | cc-pVDZ | validity anchor vs Psi4 |
| 3 `repro` | cc-pVTZ | accuracy ceiling for perf studies |

Locked until `import_chem_dft_smoke.li` exists and gates run with `SIM_RESEARCH_STUDY_ONLY=0`.

---

## Size scaling — cost (H₂O, B3LYP, grid level 3)

Reference geometry: Psi4 tutorial Z-matrix (O–H 0.96 Å, ∠HOH 104.5°).  
**Cost columns** are relative wall-time vs STO-3G = 1.0, from [chem-r0](./2026-05-25-chem-r0-sota-survey.md) desktop-normalized sweep (same geometry class; not Li-measured).

| Basis | N\_basis | N\_grid (approx) | Rel. 401–408 (ERI/Fock) | Rel. 412–418 (XC+SCF) | Li stub rel. cost |
|-------|---------|------------------|-------------------------|------------------------|-------------------|
| STO-3G | 7 | 1.2k | 1.0 | 1.0 | **1.0** (constant) |
| 6-31G | 13 | 2.4k | 4.5 | 3.2 | 1.0 |
| 6-31G* | 19 | 3.5k | 18 | 12 | 1.0 |
| cc-pVDZ | 24 | 4.1k | 42 | 28 | 1.0 |
| cc-pVTZ | 58 | 9.8k | 310 | 195 | 1.0 |

**Scaling exponents (locked for perf claims):** HF-like Fock build **O(N\_basis⁴)**; KS-DFT with quadrature **O(N\_basis³ · N\_grid)**; enabling **407** (`qm_eri_density_fitting`) shifts wall time toward **O(N\_basis³)** at fixed validity tier.

---

## Size scaling — accuracy (H₂O, B3LYP, vs cc-pVTZ anchor)

Absolute total energies are gauge-dependent; this table uses **ΔE = E(basis) − E(cc-pVTZ)** in millihartree (mHa) and dipole error vs cc-pVTZ.  
Values in the **ΔE (mHa)** column are **PySCF-class** targets from `scripts/chem-r1-basis-scaling-ref.py` (re-run when PySCF is available); until then, use the script output to replace placeholders.

| Basis | ΔE vs cc-pVTZ (mHa) | \|Δμ\| vs cc-pVTZ (D) | Validity tier for **418** |
|-------|---------------------|------------------------|---------------------------|
| STO-3G | ≈ 45–55 (large) | ≈ 0.25–0.35 | qualitative smoke only |
| 6-31G | ≈ 18–25 | ≈ 0.12–0.18 | regression tier-1 |
| 6-31G* | ≈ 8–12 | ≈ 0.05–0.08 | default parity target |
| cc-pVDZ | ≈ 2–4 | ≈ 0.01–0.02 | **locked validity anchor** |
| cc-pVTZ | 0 (reference) | 0 | ceiling / extrapolation reference |

**Repro (measured rows):**

```bash
# Optional: pip install pyscf
python3 scripts/chem-r1-basis-scaling-ref.py
# Emits CSV: basis,N_basis,rel_wall,energy_ha,delta_mha_vs_cc-pvtz,grid_points
```

**HF cross-check (absolute, Psi4 tutorial geometry):** RHF/cc-pVDZ total energy **−76.02663273410671 Ha** ([Psi4 tutorial](https://psicode.org/psi4manual/4.0b4/tutorial)) — use only for integral smoke on **401–404**, not for hybrid **417–418** parity.

---

## Registry map (basis-sensitive rows)

| id | name | Scales with basis as… | Stub today |
|----|------|------------------------|------------|
| 401–404 | GTO / one-electron integrals | **N\_basis²–N\_basis⁴** shell pairs | constant checksum |
| 405–408 | ERI / HF Fock | **N\_basis⁴** (dense) | constant checksum |
| 409–411 | DIIS / ortho / SCF solver | iterations × Fock cost | constant checksum |
| 412–416 | XC + grids | **N\_grid**, **N\_basis³** collocation | constant checksum |
| 417 | hybrid exchange | + HF exchange term | constant checksum |
| **418** | **`qm_dft_scf_energy`** | sum of above | **`checksum=1.001`** |

**Vertical:** `vertical_qm_dft()` = 4; bench id `qm_dft` (when tier-2 row lands).

---

## Li mapping (PH-5b / PH-7e / G-math / G-par)

| Axis | Basis-scaling implication |
|------|---------------------------|
| **PH-5b** | Accumulate SCF energy in `f64`; no fast-math on **418** until ΔE vs Psi4 ≤ 1e-8 Ha at cc-pVDZ. |
| **PH-7e** | Dense blocks (408, 417) only after tier-1 matmul parity; block size grows with **N\_basis**. |
| **G-math** | `@` for density/Fock; shapes derived from `N_basis`, not hard-coded 7 (STO-3G). |
| **G-par** | Shell-pair and grid batches require proved `disjoint=`; parallel speedup must not change ΔE beyond 1e-8 Ha. |

---

## Implementation path in **lic** (proof-oriented)

1. **Stop stub scaling lies** — When **418** is real, `metrics` must include `basis`, `total_energy_hartree`, `scf_iterations` ([sim-output-contract.md](../../ecosystem/sim-output-contract.md)); forbid constant `checksum` across bases.
2. **Tier-0 gate** — cc-pVDZ B3LYP H₂O vs PySCF/Psi4 (`1e-8` Ha) before `implemented_smoke: true` on **418**.
3. **Bench harness** — `benchmarks/tier2_physics/qm_dft_scf_energy/` with `params.toml` keys `basis`, `grid_level`; ≥3 basis rows in catalog for scaling evidence.
4. **Composable** — Add `li-tests/composable/import_chem_dft_smoke.li` when **411–418** are real; keep `implemented_smoke: false` until then.

**Repro (survey + gates):**

```bash
jq '.algorithms[] | select(.id >= 401 and .id <= 418)' benchmarks/competitive/algo_registry.json

SIM_RESEARCH_VERTICAL=chem \
SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-05-25-chem-r1-basis-size-scaling.md \
./scripts/sim-algo-research-gates.sh
```

---

## Grade matrix

| Axis | Result | vs chem-r0 | Notes |
|------|--------|------------|-------|
| Validity | pass | same | Stub still labeled; no `implemented_smoke` bumps |
| Performance | N/A (survey) | refined | Cost table ties **401–418** to **N\_basis**; stub O(1) documented |
| Memory | N/A | refined | cc-pVTZ row marks memory-bound regime for future benches |
| Security | pass/skip | same | No native FFI |
| Stability | pass | same | SCF convergence deferred to **409–411** |
| Size scaling | table attached | **improved** | ≥5 basis rows; separate cost + accuracy columns |

---

## Tradeoffs

- **Locked:** validity (+ SCF stability for **409–411**); registry honesty; basis and grid level named in any future perf row.
- **Improved:** explicit cost/accuracy table for stub→real **418** path; `detail`→basis staging proposal; PySCF repro script.
- **Regressed:** none — study + script only.
- **Explicitly not approved:** reporting QM speedup from `run_algo_registry_stub`; using STO-3G energies for production parity; enabling RI/COSX (**407**) without auxiliary basis named in study.

---

## Next todos

| id | Handoff |
|----|---------|
| `chem-r2-dft-scf-gap` | `sim-p2-qm-dft-scf` — minimal SCF vs stub |
| `chem-r3-package-placement` | `package_architect` |
