# Research goal digest — `chem_sim_algorithms`

**Session:** `1bdb6322-8399-425d-9257-9b9098475e89` · **Cycle:** 1 · **Agent:** `numerics_researcher`  
**Run:** `numerics_researcher-1779940539765` · **Generated:** 2026-05-28T03:56:40Z  
**North star fit:** Chemistry / QM — PH-5b (proved numerics), PH-7e (integral/Fock SIMD), domains: scientific_computing, hpc

---

## Executive summary

- **Mode A SOTA survey complete** (`chem-r0`): Psi4, PySCF, ORCA, Helgaker/Szabo mapped to **algo_registry 401–432**; implement **401–404** (integrals) before **408/418** (Fock/SCF energy).
- **Li gap:** All **32 `qm_*`** catalog rows remain **unknown** on the [dashboard](https://li-langverse.github.io/benchmarks/) (preflight 2026-05-28); tier-2 harnesses still use the **`schrodinger_1d_barrier` family template**, not QC kernels.
- **`li-sim-scientific`:** `vertical_qm_dft()` → `algo_qm_dft_scf_energy()` → `run_algo_registry_stub` (checksum **1.001**); registry ids 401–432 route through the same stub path.
- **`std/physics/chem.li`:** tag-only (`physics_chem_std_tag`); no GTO/SCF surface on `main` yet.
- **Composable gate missing:** `li-tests/composable/import_chem_dft_smoke.li` not on `main`; `verticals.toml` honesty stays **stub / external_binary** until it passes.
- **v1 implement target:** `chem-r2-dft-scf-gap` → `qm_dft_scf_energy` (418) with **Psi4 subprocess oracle** (H₂ STO-3G) before native RKS perf; validity/stability/accuracy axes locked.
- **Evidence pack:** [chem-r0 whitepaper](../../../../research-findings/whitepapers/2026-05/chem_sim_algorithms/chem-r0-qm-sota-survey/README.md) · [study](../../numerics/studies/2026-05-27-chem-r0-qm-sota-survey.md) · catalog `qm_dft_scf_energy` (`size_label=harness pending`).
- **No perf claims** this cycle; `threshold_ratio_cpp` (1.2) and tier-0 tolerances unchanged.

---

## Deliverable / findings

### Completed artifacts (cycle 1, session `1bdb6322`)

| Step | Run | Artifact |
|------|-----|----------|
| `survey_sota-1` | `numerics_researcher-1779916590880` | [Study](../../numerics/studies/2026-05-27-chem-r0-qm-sota-survey.md) · [Whitepaper](../../../../research-findings/whitepapers/2026-05/chem_sim_algorithms/chem-r0-qm-sota-survey/README.md) |
| `digest` | `numerics_researcher-1779940539765` | This file · [Session log](../../ecosystem/research-sessions/chem_sim_algorithms-cycle.md) |

### Learned from (SOTA, 2–4)

1. [Psi4 tutorials](https://psicode.org/psi4manual/master/tutorial.html) — minimal HF/DFT energy, basis sets, DIIS SCF → **v1 external oracle** for H₂/H₂O STO-3G.
2. [PySCF user guide](https://pyscf.org/user/scf.html) — AO integrals, density fitting, RKS drivers → **401–404 before 408/418**.
3. [ORCA manual](https://www.faccts.de/orca/manual/) — GGA/hybrid/grid (registry **412–417**) → stub honesty until LDA (412) reference energy on fixed geometry.
4. Helgaker, Jørgensen, Olsen — *Molecular Electronic-Structure Theory* → basis monotonicity required in `chem-r1` scaling table.

### Li mapping (PH / proof)

| Surface | PH / group | Status |
|---------|------------|--------|
| SCF convergence + Ha refs | PH-5b | Documented; Psi4 oracle path proposed |
| ERI/Fock contraction loops | PH-7e | Deferred until integral parity |
| Gaussian recurrence, symmetry | G-math | `chem.li` / future `li-physics-quantum` |
| AO block parallelism | G-par | Post-proof `@vectorized` / `parallel for` |

### In-repo gap evidence (verified 2026-05-28)

```167:195:packages/li-sim-scientific/src/lib.li
def run_algo_registry_stub(algo_id: int, detail: int) -> SimRunResult
  ...
  if algo_id >= 401:
    if algo_id <= 432:
      vert = vertical_qm_dft()
  ...
  r.checksum = 1.001
```

```246:248:packages/li-sim-scientific/src/lib.li
  if vertical_id == vertical_qm_dft():
    var d3: int = detail
    return run_algo(algo_qm_dft_scf_energy(), d3)
```

`benchmarks/catalog.toml` — `qm_dft_scf_energy`: `size_label = "harness pending"`, `threshold_ratio_cpp = 1.2`, `validity_required = true`.

### Grade matrix

| Axis | Li today | Target | Locked? |
|------|----------|--------|---------|
| Validity | registry smokes; vertical stub | Psi4 Ha oracle on 418 | **yes** |
| Stability | SCF max-iter undocumented | DIIS + damping table | **yes** |
| Accuracy | template only | basis monotonicity (`chem-r1`) | **yes** |
| Performance | all `qm_*` unknown | after validity | no (deferred) |
| Memory | N/A | ERI profile post-407 | no |

### Tradeoffs

Validity, stability (SCF convergence), and accuracy (basis-set monotonicity) remain **locked**. Speed on ERI/Fock rows is explicitly deferred until checksum/Ha parity. External Gaussian/ORCA binaries are **not** required in CI; Psi4 subprocess oracle is optional and documented. No axis may regress to green dashboard cells without human approval of locked-axis tradeoffs.

### Mandatory evidence (this run)

| Type | Path |
|------|------|
| Numerics study | `docs/numerics/studies/2026-05-27-chem-r0-qm-sota-survey.md` |
| Whitepaper | `research-findings/whitepapers/2026-05/chem_sim_algorithms/chem-r0-qm-sota-survey/` |
| Bench catalog | `benchmarks/catalog.toml` → `qm_dft_scf_energy` |
| Preflight | `benchmarks/data/latest/ecosystem-audit.json` (32 unknown `qm_*`) |

### Implementation path (handoff → `bench_improver` / sim worktree)

1. Add `common/qm_scf_core.c` or Psi4 subprocess oracle for H₂ STO-3G; wire `qm_dft_scf_energy` harness off `schrodinger_1d_barrier` template.
2. Implement integral microkernels **401–404** before Fock/SCF.
3. Replace `run_algo_registry_stub` for id **418** with real `run_qm_dft_scf_energy_smoke`.
4. Add `li-tests/composable/import_chem_dft_smoke.li`; flip `verticals.toml` only when green.
5. Deep gates in `lic-worktrees/sim-chem-research` only — no new systemd sim loops on `main`.

---

## Recommended issues/PRs

| Title | Repo | Labels | Owner agent |
|-------|------|--------|-------------|
| `chem-r2: qm_dft_scf_energy harness + Psi4 oracle (418)` | `lic` | `numerics-research`, `bench` | `bench_improver` / `sim-p2-qm-dft-scf` |
| `chem-r1: fill STO-3G / 6-31G / cc-pVDZ scaling table with Psi4 refs` | `lic` | `numerics-research` | `numerics_researcher` |
| `Add import_chem_dft_smoke composable gate` | `lic` | `numerics-research`, `li-tests` | `code_implementer` |
| `Honesty: verticals.toml qm_dft stub → oracle after smoke` | `benchmarks` | `numerics-research` | `bench_improver` |
| `Integral chain 401–404 — s-type overlap smoke` | `lic` | `numerics-research`, `PH-5b` | `bench_improver` |

**PR template reminder (when opening lic PR):**

```markdown
<!-- li-agent -->
## Agent deliverable
- [x] Tests added or updated — cite `docs/numerics/studies/2026-05-27-chem-r0-qm-sota-survey.md`
- [x] Bench evidence — catalog `qm_dft_scf_energy` (harness pending; dashboard unknown)
- [x] No merge-approved until human review
```

---

## Deferred

- **`chem-r3-package-placement`** — package layout (`li-physics-quantum` vs `std/physics/quantum.li`) after r2 smoke.
- **Post-HF rows 422–425** (MP2/CCSD/TDDFT) — after 418 green.
- **Grid/XC 412–417** — after LDA (412) reference energies on fixed geometry.
- **Native RKS perf / PH-7e SIMD** — after `chem-r1` basis scaling table filled with measured data.
- **Production DFT accuracy** — out of v1 scope per scaffold.
- **Autoresearch** — novel integral/SCF splittings only if SOTA path insufficient (`numerics-autoresearch` gates).

---

## Links

- [Benchmark dashboard](https://li-langverse.github.io/benchmarks/)
- [Sim chem backlog](../../ecosystem/sim-chem-research-backlog.md)
- [Grading rubric](../../ecosystem/sim-algo-research-grading.md)
- [Goal scaffold](../../../../li-cursor-agents/config/goal-scaffolds/chem_sim_algorithms.md)
