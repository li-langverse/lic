# Orchestrator note — swarm_coverage @ security (c69aa249)

**Date:** 2026-06-03  
**Goal:** `swarm_coverage` · **Dimension:** `security` · **Worker:** `c69aa249`  
**north_star_fit:** ecosystem, ai — secure pillar; gap orchestration without new lic systemd loops

## Snapshot

| Signal | Value | Evidence |
|--------|-------|----------|
| Ecosystem grade | **C** (71.8) · `unattended_safe=false` | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Open gaps | **64** (plan_debt 31, competitor 30, missing_package 1 open) | `swarm-gap-actions.json`, `registry.yaml` |
| Security backlog | sec-r1/2/3 **pending** | `lic/docs/ecosystem/security-research-backlog.md` |
| CWE catalog | 15 CWEs; **19/25 Top25 missing** | `benchmarks/data/latest/security-cwe-feed.json` |
| Briefing heap | `ci_maintainer`, `security_auditor` | `agent-briefing.json` |
| Gap ingest | **blocked** → syntax fix applied this pass | `lic/scripts/swarm-gap-ingest.py:229` |
| Gap apply | **blocked** (PyYAML missing in Job image) | `swarm-gap-apply-actions.py` |

## Security gap reconcile (Mode B)

| gap_id | kind | Action | Handoff |
|--------|------|--------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | plan_debt | Already patched → `security-research-backlog.md` | `security_auditor` (`offensive_security`) |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | plan_debt | Patched backlog | `security_auditor` + `code_implementer` for tier5 rows |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | plan_debt | Patched backlog | `security_auditor` |
| `gap-line-profiler-001` | missing_package | Only **open** missing_package in registry | `issue_planner` |
| `orch-r3-missing-package-sweep` | plan_debt | Deferred (no runner mapping) | Close via `swarm_observer` after pkg sweep |

**Do not** recommend `install-goal-plan-loop-systemd.sh` for `security-research`; route via `offensive_security` goal + `security_auditor` on agents control plane.

## PR / CI security lens

- **li-httpd#30** — edge/TLS staging; failing CI — blocks sec-r1 fuzz/smoke evidence
- **benchmarks#302** — tier5 GET retry after slowloris (ready) — supports httpd exploit parity
- Preflight: `security_cwe_audit` **skipped** (`--skip-slow`) — weakens unattended security posture

## Human-only

- GitHub API **403 rate limit** on `org_ci_audit` — cannot auto-fix missing CI repo this tick
- `roadmap/agent-kit` missing — `org_agent_kit_audit` exit 1
- lic#436 swarm-gap-registry merge conflict (if still open on main)
- Merge governance on 57 open PRs / 224 redundant pairs

## Next orchestrator todos

1. Re-run `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` after PyYAML in Job image
2. Handoff `security_auditor` for sec-r1 with li-httpd#30 CI green or study-only doc
3. `issue_planner`: CWE Top25 → `cve-catalog.json` expansion (19 gaps)
4. Complete `orch-r3-missing-package-sweep` — close `gap-line-profiler-001` or escalate
