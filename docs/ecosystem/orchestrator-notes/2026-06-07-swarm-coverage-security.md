# Orchestrator note — `swarm_coverage` security dimension

**Date:** 2026-06-07  
**Agent:** `swarm_observer` (worker `9e82f631`)  
**Research goal:** `swarm_coverage`  
**north_star_fit:** ecosystem, ai — security lens: CWE catalog, security-research backlog, swarm gap handoffs  
**Publish:** `research-findings/whitepapers/2026-06/swarm_coverage/`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (60.9); `unattended_safe: false` |
| Security gaps (open) | 3 `security-research` plan todos + 19 Top-25 CWE catalog holes |
| Gap prep | **Blocked** — PyYAML missing; ingest syntax error fixed, not re-ingested |
| Swarm route | `offensive_security` goal → `security_auditor` for `sec-r1`–`sec-r3` |
| Unattended? | **No** — CWE expansion + fuzz smoke need `security_auditor`; infra needs PyYAML |

---

## Security gap reconciliation

| Registry id | Todo | Status | Handoff |
|-------------|------|--------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | open / backlog pending | `security_auditor` via `offensive_security` |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | open | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | open | `security_auditor` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | `wp-n5-security-bench` | open / apply deferred | `issue_planner` (ph-db plan) |

**CWE feed:** `benchmarks/data/latest/security-cwe-feed.json` — 19 Top-25 CWEs missing from `lic/security/cve-catalog.json`. Completed: `sec-r0-cwe-delta`. Next: catalog row expansion + `security_cwe_audit` preflight un-skip.

**Evidence paths:**

- `lic/docs/ecosystem/security-research-backlog.md`
- `lic/data/swarm-gap-registry/registry.yaml` (security-research rows)
- `benchmarks/data/latest/swarm-gap-actions.json` (patches @ 2026-05-31)
- `benchmarks/data/latest/ecosystem-quality-report.json` (regen 2026-06-07)
- `app/data/runs/swarm_observer-1780820314516.md`

---

## Control-plane actions (this pass)

1. **Fixed** `lic/scripts/swarm-gap-ingest.py:229` — `verticals.toml` fallback path syntax.
2. **Regenerated** ecosystem quality scorecard (`grade D`, `unattended_safe: false`).
3. **Could not run** `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` — PyYAML absent in runner image.

---

## Recommended dispatch (no new agent ids)

| Next agent | Reason |
|------------|--------|
| `security_auditor` | Briefing P0: 19 CWE catalog gaps; `sec-r1` fuzz smoke |
| `gap_explorer` | 64 open registry rows; verticals.toml ingest blocked |
| `ci_maintainer` | 13 repos missing CI |
| `pr_merger` | `lip#52` gate-ready |

Do **not** install retired `security-research` systemd loop — work routes through `offensive_security` research goal per `docs/ecosystem/swarm-architecture.md`.

---

## Deferred

- `orch-r4-ui-ux-signals` — UI security adjacent (GPU fail recovery); `gui_ux_tester` lane.
- Bulk `plan_debt` master-plan rows — `plan_verifier` + human PH review.
- `wp-n5-security-bench` — needs ph-db backlog mapping before auto-apply.
