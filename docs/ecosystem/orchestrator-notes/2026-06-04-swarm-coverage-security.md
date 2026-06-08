# Orchestrator note — swarm_coverage @ security (2026-06-04)

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `e0bbebeb`  
**north_star_fit:** ecosystem, ai — secure orchestration; proof-before-perf

## Summary

Swarm is **degraded** (quality grade **D**, `unattended_safe: false`). Security work is **briefing-prioritized** (`security_auditor` for 19 missing Top25 CWEs) but **execution-blocked** by gap-script deps and inactive security-research runner.

## Actions this pass

1. **Fixed** `scripts/swarm-gap-ingest.py` L229 — unterminated Path fallback for `verticals.toml` (syntax verified with `py_compile`).
2. **Documented** security gap reconcile: route `sec-r1/2/3` via `offensive_security` → `security_auditor`; do **not** spawn new systemd `security-research` loop.
3. **Regenerated** ecosystem quality scorecard (`overall_score=69.3`).

## Blocked

- **PyYAML** not in org-research Job image → `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` cannot run.
- **Control plane** disk mirrors + MCP Postgres unavailable in this pod.
- **`research-findings`** not mounted → whitepaper publish deferred.

## Security gap rows (open)

| Todo | Registry id | Handoff |
|------|-------------|---------|
| sec-r1-httpd-fuzz-smoke | `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `security_auditor` |
| sec-r2-tier5-gap-exploit | `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `security_auditor` |
| sec-r3-runtime-surface | `gap-plan-pending-security-research-sec-r3-runtime-surface` | `security_auditor` |
| wp-n5-security-bench | `gap-plan-pending-ph-db-wp-n5-security-bench` | `security_auditor` / `issue_planner` |

Backlog patches already recorded in `docs/ecosystem/security-research-backlog.md` (apply step pending PyYAML).

## Next tick

1. Merge ingest fix + bake `python3-yaml` in Job image.
2. Re-run ingest → apply; verify `benchmarks/data/latest/swarm-gap-actions.json` timestamp.
3. Dispatch `security_auditor` on `offensive_security` for sec-r1.
4. Human: expand `security/cve-catalog.json` for Top25 gaps (19 missing).

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780534136639.md`
