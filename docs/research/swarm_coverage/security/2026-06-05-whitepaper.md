# Swarm coverage — security dimension whitepaper

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `56b0cd2b`  
**Date:** 2026-06-05  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`  
**north_star_fit:** ecosystem, ai — provable security posture before perf shortcuts

---

## Abstract

This pass audits Li swarm health through a **security lens**: whether gap orchestration routes offensive-security work (`security_auditor`, `offensive_security` goal), whether CWE/catalog signals reach dispatch, and whether security plan debt (`sec-r1`–`sec-r3`) is reconciled. The swarm is **degraded** (grade D, 64.8); unattended operation is **unsafe** until gap ingest/apply runs reliably and briefing-recommended `security_auditor` executes.

---

## 1. Security signals in the briefing pipeline

| Signal | Value | Source |
|--------|------:|--------|
| CWE catalog entries | 15 | `lic/security/cve-catalog.json` |
| MITRE Top25 in catalog | 6 / 25 | `security-cwe-feed.json` |
| Top25 missing | 19 | `security-cwe-feed.json` |
| `security_cwe_audit` preflight | skipped (`--skip-slow`) | `agent-briefing.json` |
| `cwe_feed_sync` preflight | exit 0 | `agent-briefing.json` |
| Briefing P0 agent | `security_auditor` | `agent-briefing.json` |

**Finding:** CWE feed sync succeeds, but deep CWE audit is skipped in fast preflight. The scorecard still recommends `security_auditor` — dispatch alignment is correct, but **execution drift** exists (no `security_auditor` run in `data/runs/` this host).

---

## 2. Security plan debt in gap registry

Three open `plan_debt` rows tie to `security-research` runner:

| Todo | Title | Backlog | Handoff |
|------|-------|---------|---------|
| `sec-r1-httpd-fuzz-smoke` | HTTPD fuzz smoke gate | `security-research-backlog.md` | `security_auditor` |
| `sec-r2-tier5-gap-exploit` | Tier5 exploit parity gaps | same | `security_auditor` |
| `sec-r3-runtime-surface` | Runtime attack surface survey | same | `security_auditor` |

`sec-r0-cwe-delta` is **closed** in registry (completed in snapshot).  
Backlog on disk shows `sec-r1/2/3` as **pending** — prior `swarm-gap-apply-actions.py` patch (2026-05-31) is reflected; no product code change required in this meta pass.

**Related httpd security work:** `gap-phase2-mitigation-exploits` completed on httpd runner; `gap-phase2-perf-wrk-soak` and streaming wrk remain pending (perf, not blocking sec-r1).

---

## 3. Swarm orchestration risks (security impact)

| Risk | Severity | Mechanism |
|------|----------|-----------|
| Gap ingest syntax error | high | `swarm-gap-ingest.py` L229 prevented vertical + plan_debt ingest |
| PyYAML missing in container | high | `swarm-gap-apply-actions.py` cannot patch backlogs → stale handoffs |
| 35 PRs failing CI | high | security metrics PRs (#364 stack) cannot merge → stale grade |
| 6/9 goal runners stopped | high | `security-research` runner not live; sec todos stall |
| GitHub API 403 on org_ci_audit | medium | cannot verify CI on repos missing security workflows |
| `runs_sampled: 0` in scorecard | medium | swarm_execution dimension under-informed |

**Integrity note:** `CURSOR_API_KEY` is set — SDK auth is not the blocker. Control-plane disk mirrors (`latest-report.json`, `state.json`) are absent; programmatic observer cannot record retries.

---

## 4. Recommendations (orchestration only)

1. **Bake `python3-yaml`** in org-research Job image (`li-cursor-agents` deploy).
2. **Merge ingest fix** (`lic/scripts/swarm-gap-ingest.py` L229) via PR — unblocks vertical stub ingest.
3. **Dispatch `security_auditor`** on `offensive_security` goal — close `sec-r1` first (httpd fuzz smoke).
4. **Enable `security_cwe_audit`** in non-fast preflight at least daily.
5. **Handoff to `issue_planner`:** catalog expansion issue for 19 missing CWE Top25 rows.

---

## 5. Proof-before-perf alignment

Security gaps must not bypass provability gates:

- Tier5 exploit rows require **live li-httpd vs nginx** compare with `--fail-on-regression` (already gated on httpd runner).
- CWE catalog changes are **human-gated** — no auto-merge of `cve-catalog.json`.
- `trusted.lean` and Lean policy remain out of swarm auto-merge scope.

---

## References

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/security-cwe-feed.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/docs/ecosystem/security-research-backlog.md`
- `docs/ecosystem/research-verticals.md` — `offensive_security` goal
- `li-cursor-agents/data/runs/swarm_observer-1780637179350.md`
