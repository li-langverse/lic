# Orchestrator note — `swarm_coverage@security`

**Date:** 2026-06-05  
**Agent:** `swarm_observer`  
**Worker:** `56b0cd2b`  
**Research goal:** `swarm_coverage`  
**Dimension:** `security`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai (security lens)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — ecosystem grade **D** (64.8), `unattended_safe: false` |
| Security lane | **Starved** — briefing P0 `security_auditor` not in recent `data/runs/`; `offensive_security` goal idle |
| Gap pipeline | **Blocked** — ingest L229 syntax error (fixed this pass); apply needs PyYAML in org-research image |
| Open security gaps | **3** plan_debt rows (`sec-r1`–`sec-r3`) + **19** CWE Top25 missing in catalog |
| Unattended? | **No** — preflight failures, 35 failing PRs, gap scripts cannot run in container |

---

## Security gap reconcile (registry → backlog → handoff)

| Gap id | `gap_kind` | Status | Backlog patch | Handoff |
|--------|------------|--------|---------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `plan_debt` | open | `security-research-backlog.md` → `sec-r1` pending | `security_auditor` (`offensive_security`) |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `plan_debt` | open | `security-research-backlog.md` → `sec-r2` pending | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `plan_debt` | open | `security-research-backlog.md` → `sec-r3` pending | `security_auditor` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | `plan_debt` | open | deferred (no ph-db backlog mapping) | `issue_planner` |
| `gap-plan-pending-httpd-gap-phase2-mitigation-exploits` | `plan_debt` | closed in snapshot | httpd runner completed | — |

**CWE feed** (`security-cwe-feed.json`): `top25_missing_in_catalog=19`, `catalog_cwe_count=15`.  
**Briefing dispatch:** `security_auditor` P0 — aligns with `offensive_security` goal; not yet executed this cycle.

**Apply actions (stale 2026-05-31):** prior run patched `sec-r1/2/3` → pending in `security-research-backlog.md` (confirmed on disk). Live re-apply blocked by PyYAML.

---

## Scripts executed

| Script | Result | Evidence |
|--------|--------|----------|
| `python3 scripts/ecosystem-quality-grade.py` (benchmarks) | **OK** — 64.8 / D | `benchmarks/data/latest/ecosystem-quality-report.json` |
| `python3 scripts/swarm-gap-ingest.py` | **FAIL** → **syntax fixed** L229 | `lic/scripts/swarm-gap-ingest.py` |
| `python3 scripts/swarm-gap-apply-actions.py` | **FAIL** — PyYAML required | container has no `yaml` module |

---

## Control-plane fixes (this pass)

1. **`lic/scripts/swarm-gap-ingest.py` L229** — close `Path` fallback for `verticals.toml` (unterminated string).
2. **Orchestrator note** — this file.
3. **Whitepaper staging** — `lic/docs/research/swarm_coverage/security/2026-06-05-whitepaper.md`.
4. **Scorecard refresh** — regenerated `ecosystem-quality-report.json` (2026-06-05T05:39:40Z).

---

## Recommended dispatch order (security lens)

1. `security_auditor` — `offensive_security` goal: CWE catalog delta + `sec-r1` httpd fuzz smoke.
2. `ci_maintainer` — 3 repos missing CI (blocks security workflow gates).
3. `gap_explorer` — reconcile 64 open gaps after PyYAML + ingest fix land.
4. `plan_verifier` — refresh plan audit (skipped `--skip-slow`).

**Do not** recommend `install-goal-plan-loop-systemd.sh` — security-research migrated to async swarm (`security_auditor` + `offensive_security` goal).

---

## Human-only blockers

- Merge **benchmarks#364** / **lic#867** (or successor) after CI green — metrics + ingest fix.
- Map 19 CWE Top25 into `lic/security/cve-catalog.json` — human-gated catalog expansion.
- GitHub API rate limit on `org_ci_audit` — wait or use PAT with higher quota.
- `roadmap/agent-kit` missing — `org_agent_kit_audit` exit 1.

---

## Evidence paths

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/agent-briefing.json`
- `benchmarks/data/latest/security-cwe-feed.json`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/docs/ecosystem/security-research-backlog.md`
- `li-cursor-agents/data/runs/swarm_observer-1780637179350.md`
