# Swarm coverage — security dimension (2026-06-04)

**Goal:** `swarm_coverage`  
**Worker:** `eb399737`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/` (staging on `lic` until publish repo is mounted)

## Summary

The Li agent swarm is **degraded** for unattended operation (`ecosystem-quality-report.json`: grade **D**, score **64.8**, `unattended_safe: false`). Security-specific pressure is **high** but **orchestrable**: nineteen MITRE CWE Top 25 identifiers are absent from `cve-catalog.json`, three `security-research` plan todos remain pending with the runner supervisor off, and briefing correctly recommends `security_auditor` — yet the coordinator heap still prioritizes only `ci_maintainer`.

Gap orchestration Mode B refreshed `swarm-gap-actions.json` (62 open gaps; security plan_debt rows patched into `security-research-backlog.md`). Programmatic gap apply succeeded after installing `python3-yaml`; ingest still requires `BENCHMARKS_COMPETITIVE` pointing at `benchmarks/workloads/competitive/verticals.toml` until the ingest script default is merged.

## Security signals

| Signal | Value | Evidence |
|--------|-------|----------|
| CWE catalog rows | 15 | `security-cwe-feed.json` → `catalog_cwe_count` |
| Top 25 missing in catalog | 19 | `security-cwe-feed.json` → `top25_missing_in_catalog` |
| Security workflow gaps (repos) | 0 | `agent-briefing.json` recommended_agents |
| `security-research` pending todos | 3 (`sec-r1`–`r3`) | `security-research-backlog.md`, `snapshot.json` |
| `security_cwe_audit` preflight | skipped (`--skip-slow`) | `agent-briefing.preflight_runs` |

## Proof-before-perf alignment

Security work must not weaken provability gates: tier5 httpd exploit rows require **stricter-or-equal** behavior vs nginx (`sec-r2`); runtime surface review (`sec-r3`) should use ASan on touched native cores only. Catalog CWE mapping is documentation + test harness alignment — not `trusted.lean` changes.

## Recommended dispatch order

1. `security_auditor` — `sec-r1-httpd-fuzz-smoke` under `offensive_security`
2. `ci_maintainer` — unblock benchmarks metrics/catalog PR CI so security feeds stay fresh
3. Human review — map 19 CWE rows into `cve-catalog.json`
4. `gap_explorer` — close `gap-infra-verticals-toml-missing-benchmarks-main` after catalog PR merge

## north_star_fit

Domains: **ecosystem**, **ai**. Pillar: **secure** (within proof → easy → fast ordering). PH linkage: httpd Phase H exploit parity; PH-5b catalog honesty for tier-5 security benchmarks.
