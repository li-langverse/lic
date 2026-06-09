# Orchestrator note — swarm_coverage @ security

**Date:** 2026-06-03 · **Worker:** `0f42b067` · **Goal:** `swarm_coverage`  
**north_star_fit:** ecosystem, ai — secure provable swarm (pillar: secure)

## Prep status

| Step | Status | Detail |
|------|--------|--------|
| `swarm-gap-ingest.py` | **partial** | Fixed L229 `Path` syntax locally; blocked on PyYAML in Job image |
| `swarm-gap-apply-actions.py` | **blocked** | `PyYAML required` |
| `ecosystem-quality-grade.py` | **ok** | Regenerated → score 70.8, `unattended_safe=false` |
| Registry read | **ok** | 1230 lines, 64 open gaps (stale apply from 2026-05-31) |

## Open security gaps — reconcile plan

| Gap | Kind | Target agent | Backlog / handoff |
|-----|------|--------------|-------------------|
| `sec-r1-httpd-fuzz-smoke` | `plan_debt` | `security_auditor` | security-research backlog; ties to li-httpd#30 |
| `sec-r2-tier5-gap-exploit` | `plan_debt` | `offensive_security` | `config/research-goals.yaml` goal `offensive_security` |
| `sec-r3-runtime-surface` | `plan_debt` | `security_auditor` | lic security bench surface |
| `wp-n5-security-bench` | `plan_debt` | `gap_explorer` | ph-db runner backlog |

**CWE catalog:** 19/25 Top25 missing — briefing already queues `security_auditor`; no new registry id.

## Heap / briefing drift

- Briefing P0: `ci_maintainer`, `security_auditor`
- Heap `flat_tasks`: `ci_maintainer` only — **add `security_auditor`** at coord_platform priority ≥50

## Human-only

- lic#436 registry merge conflict (if still open)
- Governance / provability PRs
- Direct push to protected `main`

## Next orchestrator tick

1. Merge ingest fix + PyYAML in Job image → re-run ingest + apply
2. Enqueue `security_auditor` from heap when CWE P0 persists
3. Patch `sec-r1` handoff after gap apply refreshes `swarm-gap-actions.json`
