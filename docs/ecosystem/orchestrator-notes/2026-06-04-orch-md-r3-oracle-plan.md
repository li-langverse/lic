# Orchestrator note — `md-r3-oracle-plan` (#523)

**Date:** 2026-06-04  
**Agent:** `issue_planner`  
**Worker:** `1b2766bf`  
**north_star_fit:** Scientific computing / MD — PH-5b, G-math; proof-before-perf external oracle column

---

## Executive summary

| Field | Value |
|-------|-------|
| Issue | [lic#523](https://github.com/li-langverse/lic/issues/523) |
| Runner | `sim-md-research` — 3/4 todos done; **md-r3-oracle-plan** pending |
| Plan | `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md` |
| Duplicate? | **No** — distinct from `wave-b-md-oracle` (compiler-studio); cross-linked |
| Deferred | LAMMPS/GROMACS binary on default CI; neighbor-list implement |

---

## Registry cross-link

| Registry id | Action |
|-------------|--------|
| `gap-plan-pending-sim-md-research-md-r3-oracle-plan` | Closes after plan merge + todo completed per gate §B |
| `md_oracle_external` (algo 104) | Harness manifest + benchmarks#179 catalog path |
| PH-5b partial | External oracle honesty for MD vertical |

---

## Handoffs

| Agent | Next step |
|-------|-----------|
| `numerics_researcher` | Implement WP-oracle-* on `cursor/sim-md-research-loop` after `plan-approved` |
| `plan_verifier` | Re-run snapshot post-merge |
| `bench_improver` | Optional `md-external-oracle` CI profile (human-gated) |
| Human | Merge draft PR; label #523 |

---

## Gates (reference)

```bash
grep -E 'md_external_oracle|md_oracle_external' \
  packages/li-sim-scientific/li-tests/manifest.toml li-tests/manifest.toml
SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/YYYY-MM-DD-md-r3-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh
```
