# Swarm gap orchestration — security dimension

**Goal id:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `5fde573d`  
**Date:** 2026-06-04  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/` (deferred — repo not mounted)  
**north_star_fit:** ecosystem, ai — provable, secure orchestration; no un audited agent retry storms

---

## Abstract

This pass audits whether the Li agent swarm can orchestrate security work (CWE catalog, offensive research, httpd exploit parity) without human intervention. Finding: **the gap registry pipeline is fail-closed but currently broken at ingest**, starving `security_auditor` while meta-audits consume the research lane. Restoring ingest + control-plane persistence is a security integrity requirement, not merely ops convenience.

---

## Threat model (orchestration)

| Risk | Observation | Mitigation |
|------|-------------|------------|
| Audit trail loss | MCP Postgres down; no CP disk mirrors | Restore Supabase; persist `latest-report.json` / `state.json` |
| Retry storm | Historical `swarm_observer` persist failures in `org-research-audit.jsonl` | Circuit-break org-research on DB failure; finalize runs on Job exit |
| Stale security backlog | sec-r1/2/3 pending 4d+; runner supervisor off | Route via `offensive_security` goal → `security_auditor` |
| CWE blind spot | 19/25 Top25 absent from `cve-catalog.json` | `security_auditor` + catalog PRs (human review) |
| Gap script integrity | `swarm-gap-ingest.py` SyntaxError L229 | Fix before any auto-apply; validate in CI |

---

## Security gap taxonomy (registry)

| Kind | Count | Security examples |
|------|-------|-------------------|
| `plan_debt` | 31 | sec-r1 httpd fuzz, sec-r2 tier5 exploit, sec-r3 runtime surface |
| `competitor_feature` | 30 | httpd tier5 / nginx parity exploit rows |
| `missing_package` | 3 | line profiler (observability for secure HPC loops) |

Apply patches for sec-r1/2/3 already written to `docs/ecosystem/security-research-backlog.md` (2026-05-31). Execution blocked on runner + swarm lane dispatch.

---

## Briefing vs execution (goal drift)

**Recommended (P0):** `ci_maintainer`, `security_auditor`  
**Observed in pod:** `swarm_observer` only (`data/runs/`)

The research lane should not monopolize SDK slots on meta-audit when briefing flags CWE catalog gaps at P0.

---

## Recommendations

1. **P0:** Fix `lic/scripts/swarm-gap-ingest.py:229`; add `python3-yaml` to org-research image.
2. **P0:** Restore control-plane DB + disk cache for observer auto-heal.
3. **P1:** Dispatch `security_auditor` for Top25 catalog expansion and sec-r1/2/3.
4. **P1:** Align research lane scheduler with briefing P0 security signals.
5. **Human:** Resolve lic#521; review li-httpd#30 edge/TLS CI failure.

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (grade D, unattended_safe false)
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780531239283.md`
