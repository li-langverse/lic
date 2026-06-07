# Orchestrator note — orch-r9 security gap handoffs

**Date:** 2026-06-07  
**Worker:** `2af0fb58`  
**Goal:** `swarm_coverage` · **Dimension:** security  
**north_star_fit:** ecosystem, ai — proof-before-perf; security research feeds provability posture

## Context

Swarm observer pass refreshed ecosystem grade (**D / 63.9**, `unattended_safe: false`). Gap ingest was blocked by a syntax error and missing `BENCHMARKS_COMPETITIVE` fallback in `scripts/swarm-gap-ingest.py`; apply required `python3-yaml`. Both fixed and executed this cycle.

## Security-relevant open gaps (reconciled)

| Gap ID | Kind | Backlog patch | Handoff |
|--------|------|---------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `plan_debt` | `security-research-backlog.md` → `sec-r1` pending | `security_auditor` (`offensive_security`) |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `plan_debt` | `security-research-backlog.md` → `sec-r2` pending | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `plan_debt` | `security-research-backlog.md` → `sec-r3` pending | `security_auditor` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | `plan_debt` | deferred (snapshot stale) | `plan_verifier` after snapshot refresh |

**Closed:** `sec-r0-cwe-delta` (CWE feed sync complete).

## CWE catalog pressure

Briefing `cwe_feed_delta.missing_in_catalog` lists **19** Top-25 CWE IDs not represented in `cve-catalog.json`. This is **human-gated** — do not auto-merge catalog expansion without security review.

Dispatch `security_auditor` with briefing reason: *Top25 missing in catalog=19*.

## Dispatch order (do not invent new agent ids)

1. `pr_merger` — `lip#52` (merge-approved, gate-ready)
2. `ci_maintainer` — 14 repos missing CI
3. `security_auditor` — `sec-r1` httpd fuzz smoke + CWE catalog gap survey
4. `gap_explorer` — competitor/httpd tier5 rows after security lane clears

## Control-plane fixes (lic)

- `scripts/swarm-gap-ingest.py`: Path/env fallback for `verticals.toml` (orch-r9)
- Do **not** recommend `install-goal-plan-loop-systemd.sh` for `security-research` — use async swarm + `offensive_security` goal per `docs/ecosystem/swarm-architecture.md`

## Evidence

- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1780839217793.md`
