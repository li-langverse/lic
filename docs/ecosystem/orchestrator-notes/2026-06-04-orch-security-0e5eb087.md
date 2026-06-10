# Orchestrator note — swarm_coverage @ security (worker 0e5eb087)

**Date:** 2026-06-04  
**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**north_star_fit:** ecosystem, secure — proof-before-perf; CWE catalog honesty; httpd fuzz path without weakening Lean policy.

## Evidence reviewed

| Artifact | Path |
|----------|------|
| Ecosystem scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Agent briefing | `/workspace/benchmarks/data/latest/agent-briefing.json` |
| CWE feed | `/workspace/benchmarks/data/latest/security-cwe-feed.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap apply | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Security backlog | `/workspace/lic/docs/ecosystem/security-research-backlog.md` |

## Security gap reconcile (Mode B)

| Registry id | `gap_kind` | Action this pass |
|-------------|------------|----------------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `plan_debt` | Applied → `security-research-backlog.md` (`sec-r1-httpd-fuzz-smoke` pending) |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `plan_debt` | Applied → backlog (`sec-r2-tier5-gap-exploit` pending) |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `plan_debt` | Applied → backlog (`sec-r3-runtime-surface` pending) |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | `plan_debt` | Deferred — no ph-db runner backlog mapping in apply script |

**CWE catalog (human-gated):** 19 of 25 MITRE Top25 CWEs missing from `lic/security/cve-catalog.json` (`security-cwe-feed.json` → `top25_missing_in_catalog`). Not auto-patched — requires governance review per swarm mandate.

## Control-plane routing (no new agent ids)

1. **`security_auditor`** — goal `offensive_security`; next todo `sec-r1-httpd-fuzz-smoke` (httpd fuzz smoke, study-only).
2. **`ci_maintainer`** — briefing: 3 repos missing CI; org CI audit incomplete (GitHub rate limit / 404 repos).
3. **Heap alignment** — compact briefing heap lists only `ci_maintainer`; scorecard + P0 also recommend `security_auditor`. Suggest `li-cursor-agents` heap coordinator enqueue both on `coord_platform` when CWE P0 present.

## Script remediations (this worker)

- Fixed `lic/scripts/swarm-gap-ingest.py` L229 syntax + `BENCHMARKS_COMPETITIVE` default (no `KeyError`).
- Installed `python3-yaml`; ran ingest + apply @ 2026-06-04T18:46Z.
- Regenerated scorecard with `LI_CURSOR_AGENTS_ROOT=/app` (`runs_dir` → `/app/data/runs`).

## Do not

- Merge governance PRs for CVE catalog rows.
- Install retired `install-goal-plan-loop-systemd.sh` loops — route via `config/research-goals.yaml` / async swarm only.

## Handoffs

`security_auditor` → `sec-r1`; `ci_maintainer` → missing CI + benchmarks CI wave; `gap_explorer` → 62 open registry rows after catalog PRs land.
