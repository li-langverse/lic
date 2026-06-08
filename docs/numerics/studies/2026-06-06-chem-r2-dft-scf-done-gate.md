# chem-r2 done gate — `qm_dft_scf_energy` (algo 418)

**Date:** 2026-06-06  
**Todo:** `chem-r2-dft-scf-gap` · **Issue:** [#522](https://github.com/li-langverse/lic/issues/522)  
**North star fit:** PH-5b (proved numerics), PH-2i / G-math (QM surface honesty)  
**Agent:** `code_implementer`

---

## Executive summary

- **Done gate defined** for algo **418** (`qm_dft_scf_energy`): Li H₂ STO-3G mini SCF scaffold checksum + PySCF subprocess oracle.
- **Li dispatch:** `run_qm_dft_scf_tier2_registry` replaces registry stub **1.001** with `echem_dft_h2_energy_hartree()` from `li-chem`.
- **Composable gate:** `li-tests/composable/import_chem_dft_smoke.li` — required for `SIM_RESEARCH_VERTICAL=chem` research gates.
- **External oracle:** `benchmarks/competitive/pyscf_sto3g_h2_energy.py` (Apache-2.0 PySCF RKS/LDA H₂ STO-3G); Psi4 optional via existing `psi4_sto3g_h_energy.py` pattern.
- **Perf / dashboard:** timing rows remain **deferred**; validity axis locked — no `threshold_ratio_cpp` relaxation until Ha parity tightens.

---

## Definition of Done (chem-r2)

| Gate | Criterion | Evidence path |
|------|-----------|---------------|
| **Harness** | `run_algo(algo_qm_dft_scf_energy(), detail)` returns `checksum != 1.001` | `packages/li-sim-scientific/li-tests/smoke/qm_dft_scf_interface_smoke.li` |
| **Vertical route** | `run_simulation(vertical_qm_dft(), detail)` dispatches to 418 oracle | same smoke |
| **Registry tier-2** | `run_algo_registry_tier2.li` asserts 418 checksum matches oracle | `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li` |
| **Composable** | `lic build li-tests/composable/import_chem_dft_smoke.li` succeeds | `li-tests/manifest.toml` composable row |
| **Oracle (OSS)** | PySCF H₂ STO-3G LDA energy JSON with `executed: true` when PySCF installed | `benchmarks/competitive/pyscf_sto3g_h2_energy.py` |
| **Honesty** | `verticals.toml` `qm_dft` notes pilot scaffold — not full Gaussian parity | `benchmarks/competitive/verticals.toml` |
| **Study** | This file + chem-r0 survey remain canonical SOTA context | `docs/numerics/studies/2026-05-27-chem-r0-qm-sota-survey.md` |

### Locked axes (no regression without human approval)

| Axis | v1 criterion |
|------|--------------|
| Validity | H₂ SCF energy `< 0` Ha; Li checksum matches `sim_scientific_oracle_checksum_qm_dft_scf()` |
| Stability | SCF scaffold converges within 8 iterations (`chem_dft_scf_h2_iteration_scaffold`) |
| Accuracy | PySCF oracle documents reference; energy delta logged in competitive JSON (loose tolerance until 401–404 integrals) |
| Performance | **Deferred** — no green dashboard timing until validity tightens |

### Out of scope (follow-on issues)

- Integral chain **401–404** (GTO ERIs)
- Native RKS perf / PH-7e SIMD
- `threshold_ratio_cpp` green on catalog `qm_dft_scf_energy`

---

## Repro commands

```bash
# Package smokes (from lic root, after ./scripts/build.sh)
./scripts/bench-package.sh li-sim-scientific

# Composable gate
lic build li-tests/composable/import_chem_dft_smoke.li

# PySCF H₂ oracle (optional; Apache-2.0)
pip install -r scripts/requirements-ph-sci-chem-dft-competitive.txt
python3 benchmarks/competitive/pyscf_sto3g_h2_energy.py

# Chem research gates
SIM_RESEARCH_VERTICAL=chem ./scripts/sim-algo-research-gates.sh
```

---

## Links

- [Sim chem backlog](../../ecosystem/sim-chem-research-backlog.md)
- [chem-r3 package placement](./2026-06-06-chem-r3-package-placement.md)
- [chem-r0 SOTA survey](./2026-05-27-chem-r0-qm-sota-survey.md)
- Related: [#355](https://github.com/li-langverse/lic/issues/355) harness handoff
