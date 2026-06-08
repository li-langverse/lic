# chem-r3 package placement — QM / DFT surface map

**Date:** 2026-06-06  
**Todo:** `chem-r3-package-placement` · **Issue:** [#522](https://github.com/li-langverse/lic/issues/522)  
**North star fit:** PH-5b, G-math (honest module boundaries)  
**Agent:** `code_implementer` · **study_only:** true

---

## Executive summary

- **Decision:** DFT/SCF chemistry kernels live in **`li-chem`** (`import chem`); 1D TDSE / wavefunction hooks stay in **`li-physics-quantum`**; **`std/physics/quantum.li`** remains a thin std tag/re-export surface until integral chain (401–404) lands.
- **Rationale:** `li-chem` already hosts proved mini STO-3G SCF scaffold, GPU smokes, and echem coupling; splitting DFT into a new package would duplicate dispatch already wired through `sim.scientific`.
- **sim bridge:** `algo_qm_dft_scf_energy()` (418) in `li-sim-scientific` calls `echem_dft_h2_energy_hartree()` — no new package for v1.
- **Future:** When Gaussian ERIs (401–404) mature, evaluate `li-physics-quantum` extension vs dedicated `li-physics-chem-integrals` — deferred until chem-r2 harness is green on CI.

---

## Placement matrix

| Concern | Package / module | Status | Owner |
|---------|------------------|--------|-------|
| DFT energy / SCF scaffold | `packages/li-chem` → `chem_dft_*`, `echem_dft_*` | **v1 home** | `bench_improver` / chem vertical |
| AIMD / echem coupling | `packages/li-sim-scientific` + `li-chem` | done (433–435) | echem wave |
| Algo registry dispatch (418) | `packages/li-sim-scientific` | done (chem-r2) | sim plan loop |
| 1D quantum normalize / TDSE hooks | `packages/li-physics-quantum` | partial (GPU normalize) | PH-SCI-GPU-06 |
| Std re-export / tags | `std/physics/quantum.li`, `std/physics/chem.li` | tag-only | std maintainer |
| Competitive oracles | `benchmarks/competitive/` + `scripts/bench-ph-sci-chem-*` | PySCF primary | numerics_researcher |
| Studio MCP `chem_dft_run` | `packages/li-studio` | routes to chem kernel | studio |

---

## Import conventions

```li
import chem                    # DFT/SCF kernels, echem CHE surface
import sim.scientific          # run_algo(418), vertical_qm_dft()
import physics.quantum          # 1D normalize / future TDSE (not DFT)
```

**Do not** add Gaussian integral ERIs to `std/physics/quantum.li` before proof chain exists — keeps std honest and avoids `Any`/`unsafe` shortcuts.

---

## Done gate (chem-r3)

| Gate | Criterion |
|------|-----------|
| Doc | This study published under `docs/numerics/studies/` |
| Backlog | `chem-r3-package-placement` marked `completed` in `sim-chem-research-backlog.md` |
| No duplicate package | No new `li-physics-chem-*` package until integral milestone (401–404) issue opened |

---

## Deferred

- Package split for analytic GTO integrals (post 401–404)
- `std/physics/chem.li` expansion beyond tag stub
- Mirror repos (`li-physics-quantum` org package) — track in ecosystem-package-backlog when integral work starts

---

## Links

- [chem-r2 done gate](./2026-06-06-chem-r2-dft-scf-done-gate.md)
- [Physics overview](../../physics/overview.md)
- [Sim chem backlog](../../ecosystem/sim-chem-research-backlog.md)
