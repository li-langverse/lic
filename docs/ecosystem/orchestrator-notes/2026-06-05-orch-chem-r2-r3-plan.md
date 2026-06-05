# Orchestrator note — `chem-r2-dft-scf-gap` + `chem-r3-package-placement` (#522)

**Date:** 2026-06-05  
**Agent:** `issue_planner`  
**Worker:** `53e25712`  
**north_star_fit:** Scientific computing / computational chemistry — PH-5b, PH-QM, G-math; proof-before-perf Psi4 oracle + package boundaries

---

## Executive summary

| Field | Value |
|-------|-------|
| Issue | [lic#522](https://github.com/li-langverse/lic/issues/522) |
| Runner | `sim-chem-research` — 2/4 todos pending |
| Plan | `docs/superpowers/plans/2026-06-05-chem-r2-r3-qm-dft-plan.md` |
| Duplicate? | **No** — distinct from #355 (implement handoff); plan defines Done gates #355 must meet |
| Deferred | Psi4/PySCF binary on default CI; native 401–404 integral chain; post-HF 422–425 |

---

## Registry cross-link

| Registry id | Action |
|-------------|--------|
| `gap-plan-pending-sim-chem-research-chem-r2-dft-scf-gap` | Closes after chem-r2 gates B–D |
| `gap-plan-pending-sim-chem-research-chem-r3-package-placement` | Closes after chem-r3 gates E–F |
| `qm_dft_scf_energy` (algo 418) | Harness manifest + benchmarks#179 catalog path |
| PH-5b partial | Psi4 oracle honesty for QM vertical |

---

## Handoffs

| Agent | Next step |
|-------|-----------|
| `numerics_researcher` | Implement WP-chem-* on `cursor/sim-chem-research-loop` after `plan-approved` |
| `bench_improver` / **#355** | Harness + Psi4 oracle per chem-r2 gates |
| `plan_verifier` | Re-run snapshot post-merge |
| Human | Merge draft PR; label #522 |

---

## Gates (reference)

```bash
grep -E 'qm_external_oracle|qm_dft_scf_energy' \
  packages/li-sim-scientific/li-tests/manifest.toml li-tests/manifest.toml
SIM_RESEARCH_VERTICAL=chem SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/YYYY-MM-DD-chem-r2-dft-scf-gap.md \
  ./scripts/sim-algo-research-gates.sh
```
