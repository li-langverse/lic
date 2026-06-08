# Orchestrator note — SUNDIALS stiff ODE plan (#35)

**Date:** 2026-06-07  
**Agent:** `issue_planner`  
**Worker:** `629a129d`  
**north_star_fit:** Scientific computing / simulation time integration — PH-5b, PH-SCI, PH-7e, G-math; proof-first stiff ODE oracle before native BDF perf

---

## Executive summary

| Field | Value |
|-------|-------|
| Issue | [lic#35](https://github.com/li-langverse/lic/issues/35) |
| Explorer source | [2026-05-17-explorer](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-17-explorer.md) |
| Plan | `docs/superpowers/plans/2026-06-07-sundials-stiff-ode-sensitivity-plan.md` |
| Backlog | `docs/ecosystem/numerics-integrator-backlog.md` |
| Duplicate? | **No** — distinct from #28 (PETSc–Kokkos) and #523 (MD oracle) |
| Blocked | Implementation until `plan-approved` |

---

## Gap cross-link

| Rubric / gap | Action |
|--------------|--------|
| Explorer SUNDIALS *partial* | Maps to `ode-r1` … `ode-r4` track |
| Tier-1 `num_integ_*` | Baseline — not sufficient for SUNDIALS parity claim |
| **G-math** | Stiff-ODE slice added on implement |
| **G-num** | `num-ode-*.toml` proof-db stubs |
| **Physics tier-2** | `stiff_ode_robertson`, `stiff_ode_van_der_pol` proposed |

---

## Handoffs

| Agent | Next step |
|-------|-----------|
| `code_implementer` | Execute `ode-r1` → `ode-r4` after `plan-approved` |
| `numerics_researcher` | Optional CVODE pin study if oracle versions drift |
| `plan_verifier` | Re-run explorer rubric post-implement |
| Human | Merge draft PR; label #35 |

---

## Gates (reference)

```bash
bash scripts/ph-sci-ode-oracle-competitive-gates.sh   # after ode-r2
./li-tests/tooling/ode_external_oracle_stub.sh
grep -E 'bdf1_step|stiff_ode' packages/li-math-numerics/src/lib.li
```
