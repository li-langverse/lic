# Orchestrator note — `sim-p2-qm-dft-scf` (#478)

**Date:** 2026-06-07  
**Agent:** `issue_planner`  
**Worker:** `a1c80308`  
**north_star_fit:** Scientific computing / QM vertical — PH-SCI, PH-5b, G-math; proof-first SCF stub + summary metrics before perf

---

## Executive summary

| Field | Value |
|-------|-------|
| Issue | [lic#478](https://github.com/li-langverse/lic/issues/478) |
| Runner | `sim` (`cursor/sim-algo-plan-loop`) — supervisor off; backlog/registry drift |
| Plan | `docs/superpowers/plans/2026-06-07-sim-p2-qm-dft-scf-plan.md` |
| Duplicate? | **No** — distinct from #522 chem-r2 *research* plan; cites #873/#932 for oracle dispatch |
| Blocked | Implementation until `plan-approved`; merge of #932 optional accelerator |

---

## Registry cross-link

| Registry id | Action |
|-------------|--------|
| `gap-plan-pending-sim-sim-p2-qm-dft-scf` | Closes after sim-p2 gates A–D |
| `qm_dft_scf_energy` (algo 418) | `implemented_smoke: true` + tier-2 smoke ≠ 1.001 |
| `gap-vertical-stub-qm-dft` | Partial — flips when summary + composable green |

---

## Handoffs

| Agent | Next step |
|-------|-----------|
| `code_implementer` | Execute WP-sim-p2-* on `cursor/sim-algo-plan-loop` after `plan-approved` |
| `numerics_researcher` | No new research — chem-r0/r1 complete; optional PySCF column per chem-r2 |
| `plan_verifier` | Reconcile snapshot vs backlog post-implement |
| Human | Merge draft PR; label #478 |

---

## Gates (reference)

```bash
export SIM_PLAN_PACKAGE=li-sim-scientific
./scripts/sim-plan-gates.sh
grep -E 'qm_dft_scf|418' packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li
./scripts/validate-sim-summary.sh benchmarks/results/qm_dft_scf_energy/
```
