# Orchestrator note — `swarm_coverage@api-coverage`

**Date:** 2026-06-05  
**Agent:** `swarm_observer` · **Worker:** `6d6eae2d`  
**Research goal:** `swarm_coverage`  
**Work item:** Gap registry API path audit + ingest remediation

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **D**, 64.8; `unattended_safe: false`) |
| Gap registry | **64 open** — apply pipeline stale since 2026-05-31 |
| Ingest API | **Broken** → L229 syntax fixed; PyYAML still missing in runner |
| Control plane | **Empty** — no observer state / latest-report on disk |
| Unattended? | **No** — gap ingest, CI wave, CWE catalog API gaps block routine updates |

---

## api-coverage dimension findings

### Agent / orchestration JSON surfaces

| Surface | Coverage | Gap |
|---------|----------|-----|
| `agent-briefing.json` | Preflight stdout tails, triage tables | 8 scripts `--skip-slow`; 2 non-zero exits |
| `ecosystem-quality-report.json` | Multi-dimension scorecard | `runs_sampled: 0` (wrong path) |
| `swarm-gap-actions.json` | Patch audit trail | Stale 5d; cannot refresh without PyYAML |
| Vision-LLM diagnostics | Partial | `lic check --format=json`, `lic diagnose` — plan_debt row open |
| CWE catalog API | 19/25 Top25 missing | `security-cwe-feed.json` |
| Control-plane REST | Dashboard reads | `latest-report.json` / `state.json` absent |

### Gap ingest API path (fixed)

**Before:** `swarm-gap-ingest.py:229` — unterminated string in Path fallback for `BENCHMARKS_COMPETITIVE/verticals.toml`.

**After:** Multi-line Path + env default to `benchmarks/workloads/competitive/verticals.toml`.

**Remaining:** PyYAML required for registry read/write; org-research Job image must include `python3-yaml`.

---

## Open gaps by runner (plan_debt handoff)

| Runner | Pending todos | Handoff |
|--------|---------------|---------|
| `sim` | `sim-p1-num-dot-axpy`, `sim-p1-md-neighbor-cell`, `sim-p2-qm-dft-scf` | `numerics_researcher` via sim backlog |
| `sim-md-research` | `md-r3-oracle-plan` | `numerics_researcher` |
| `sim-chem-research` | `chem-r2-dft-scf-gap`, `chem-r3-package-placement` | `numerics_researcher` |
| `security-research` | `sec-r1`–`sec-r3` | `security_auditor` |
| `studio-ui-ux` | `studio-ux-16`, `studio-ux-17` | `gui_ux_tester` |
| `ph-db` | 9 wp-* todos | deferred (no backlog mapping) |
| `swarm-observer` | `orch-r3`, `orch-r4` | this pass partial (`orch-r3` blocked on PyYAML) |

---

## Scripts executed

```bash
# benchmarks
python3 scripts/ecosystem-quality-grade.py   # → 64.8 / D

# lic (post-fix)
python3 scripts/swarm-gap-ingest.py          # → PyYAML required
python3 scripts/swarm-gap-apply-actions.py # → not reached
```

---

## Handoffs

| To | Reason | north_star_fit |
|----|--------|----------------|
| `gap_explorer` | 64 open registry rows; verticals ingest API | ecosystem |
| `ci_maintainer` | 3 repos missing CI; 30 failing PRs | secure, provable |
| `security_auditor` | 19 CWE catalog API gaps | secure |
| `issue_planner` | Vision-LLM JSON API plan_debt | ai-first, provable |
| `plan_verifier` | Re-enable plan_audit preflight | provable |

Do **not** recommend new systemd plan loops or new agent registry ids.

---

## Evidence

- Run digest: `/app/data/runs/swarm_observer-1780635377855.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- Gap actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Whitepaper: `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-05-whitepaper.md`
