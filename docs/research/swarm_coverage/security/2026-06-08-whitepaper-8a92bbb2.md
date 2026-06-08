# Swarm gap orchestration — security dimension

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `8a92bbb2`  
**Date:** 2026-06-08  
**north_star_fit:** Swarm gap orchestration — domains: ecosystem, ai; security pillar: secure

---

## Abstract

This whitepaper audits swarm gap orchestration through a **security lens**: whether open registry rows, CWE catalog coverage, and security-research plan debt are routed to the correct swarm agents without weakening provability gates. The Li swarm is **degraded** (ecosystem grade D, 63.4) and **not unattended-safe** until gap apply infrastructure (PyYAML) and security backlog dispatch (`sec-r1`–`sec-r3`) are unblocked.

---

## Security posture summary

| Signal | Value | Evidence |
|--------|-------|----------|
| CWE Top-25 in catalog | 6/25 (19 missing) | `security-cwe-feed.json` |
| Security workflows on org repos | 0 missing (audit) | `agent-briefing.json` |
| Open security plan_debt gaps | 3 (+ 1 ph-db) | `registry.yaml` |
| sec-r0 CWE delta | completed | `security-research-backlog.md` |
| sec-r1 httpd fuzz | **pending** | backlog + registry |
| Failed security observer (prior) | SDK error tools=0 | `org-research-audit.jsonl` 2026-06-08T07:34Z |

---

## Gap taxonomy — security rows

### plan_debt → security-research runner

| Gap id | Todo | Priority | Swarm handoff |
|--------|------|----------|---------------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | sec-r1 | 7 | `security_auditor` (`offensive_security`) |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | sec-r2 | 7 | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | sec-r3 | 7 | `security_auditor` |

Apply-actions (2026-05-31) patched all three to `pending` in `security-research-backlog.md`. No product code changes in this orchestration pass.

### plan_debt → ph-db (deferred)

`gap-plan-pending-ph-db-wp-n5-security-bench` — no runner backlog mapping; defer to `issue_planner` for ph-db WP-N5 issue.

### competitor_feature (security-adjacent)

- httpd tier5 exploit parity rows — mostly completed on httpd runner; perf wrk soak pending
- No new competitor_feature security gaps ingested this cycle (ingest blocked by PyYAML)

---

## Orchestration integrity risks

1. **Retry storm without durable audit** — prior `swarm_observer` security runs failed on DB persist; wastes SDK slots (security exhaustion risk).
2. **CWE catalog drift** — 19 Top-25 CWEs absent from `cve-catalog.json`; `security_auditor` briefing signal not closing gaps.
3. **Gap apply stall** — registry frozen at 64 open rows since 2026-05-31; security todos cannot auto-advance without `swarm-gap-apply-actions.py`.
4. **Goal drift** — briefing heap prioritizes `pr_merger` + `ci_maintainer`; `security_auditor` third — acceptable but sec-r1 must not slip past cadence.

---

## Recommendations

1. Dispatch `security_auditor` on `sec-r1-httpd-fuzz-smoke` (study deliverable under `docs/security/studies/`).
2. Human-gated issue: CWE Top-25 catalog backfill (19 rows) on `lic`.
3. Bake `python3-yaml` in org-research worker image; re-run ingest + apply.
4. Circuit-break org-research on repeated SDK/persist failures (prior security dimension error).

---

## References

- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/docs/ecosystem/security-research-backlog.md`
- `benchmarks/data/latest/security-cwe-feed.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `li-cursor-agents/config/research-goals.yaml` (`offensive_security`, `swarm_coverage`)
