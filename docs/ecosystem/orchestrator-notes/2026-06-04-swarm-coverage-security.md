# Orchestrator note — swarm_coverage @ security

**Date:** 2026-06-04  
**Run:** `swarm_observer-1780546041217` · worker `b643b025`  
**Goal:** `swarm_coverage` (research lane)  
**north_star_fit:** ecosystem + ai orchestration; security lens on CWE catalog and security-research plan debt

## Summary

- Confirmed **62 open** swarm gaps after ingest/apply; security plan todos **`sec-r1`–`sec-r3`** remain **pending** in `docs/ecosystem/security-research-backlog.md` (patches applied by `swarm-gap-apply-actions.py`).
- Briefing **P0** recommends **`security_auditor`** (19 Top25 CWEs missing in catalog) but heap only scheduled **`ci_maintainer`** — dispatch gap.
- Fixed **`scripts/swarm-gap-ingest.py`** (`BENCHMARKS_COMPETITIVE` default + Path syntax) so registry ingest succeeds in org-research workers without env.

## Evidence

| Artifact | Path |
|----------|------|
| Meta audit report | `/app/data/runs/swarm_observer-1780546041217.md` |
| Scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| CWE feed | `/workspace/benchmarks/data/latest/security-cwe-feed.json` |
| Security backlog | `/workspace/lic/docs/ecosystem/security-research-backlog.md` |

## Routing (no new agent ids; no lic systemd loops)

| Gap kind | Action |
|----------|--------|
| `plan_debt` (sec-r*) | Handoff **`security_auditor`** via goal `offensive_security` or security-research backlog iteration |
| `missing_package` | `issue_planner` / `ecosystem-package-backlog.md` (`pkg-line-profiler`) |
| CWE catalog | Human-gated edits to `security/cve-catalog.json` — 19 Top25 rows |

## Follow-ups

1. PR **`lic`**: ingest script fix + orchestrator note.
2. **`li-cursor-agents`**: heap enqueue `security_auditor` when CWE P0 in briefing; bake `python3-yaml` in image.
3. **`benchmarks`**: unblock scorecard PR CI before merging refreshed `ecosystem-quality-report.json`.
