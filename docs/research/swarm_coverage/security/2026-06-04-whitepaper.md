# Swarm gap orchestration — security dimension

**Goal id:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `4a5d864b`  
**Date:** 2026-06-04  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/` (staging under lic)

## north_star_fit

Ecosystem orchestration for **secure** Li: proof-before-perf applies to security evidence too — httpd exploit rows must be **stricter-or-equal vs nginx**, CWE catalog must be complete before agents claim coverage, tier5 benches are the regression oracle.

Domains: **ecosystem**, **ai** (agent swarm control plane).

## Summary

The swarm gap registry correctly routes three **plan_debt** security todos (`sec-r1`–`sec-r3`) into `security-research-backlog.md`, but the **security-research plan loop is stopped** and briefing independently flags **19** Top25 CWE IDs missing from `cve-catalog.json`. Until catalog + tier5 CI are green, `unattended_safe` must remain **false** for security-sensitive dispatch.

## Findings

### 1. Catalog completeness (CWE Top 25)

- Briefing recommends `security_auditor` with reason: Top25 missing in catalog = **19**.
- `sec-r0-cwe-delta` completed in backlog; delta may be stale vs June briefing — re-run CWE feed sync on next `offensive_security` cadence.

### 2. Httpd / tier5 exploit parity

- Open gap `sec-r2-tier5-gap-exploit` aligns with httpd plan todos and **benchmarks** tier5 PR failures (e.g. PR #358 static_large wrk).
- **34** org PRs with failing CI — security regression gates cannot auto-merge.

### 3. Fuzz / runtime surface

- `sec-r1-httpd-fuzz-smoke` — libFuzzer/AFL smoke paths; blocked on runner idle.
- `sec-r3-runtime-surface` — ASan slice on native cores; depends on lic runtime changes (human review for `trusted.lean` policy).

### 4. Orchestration health

- **64** open swarm gaps; ingest script syntax fixed but **PyYAML** missing prevents refresh.
- Goal-directed snapshot **stale** (2026-05-30); security-research `log_age_sec` ~395k — supervisor off.

## Recommendations

1. Dispatch **`security_auditor`** on goal `offensive_security` for `sec-r1` (study-only fuzz smoke doc + gate checklist).
2. Pair **`bench_improver`** with `sec-r2` only after benchmarks tier5 CI green on main.
3. Add **PyYAML** to li-cursor-agents / briefing container; re-run `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py`.
4. Issue planner: close Top25 catalog gap via benchmarks #266 class honesty PR.

## Evidence paths

| Artifact | Path |
|----------|------|
| Quality scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Agent briefing | `/workspace/benchmarks/data/latest/agent-briefing.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Security backlog | `/workspace/lic/docs/ecosystem/security-research-backlog.md` |
| Goal snapshot | `/workspace/lic/data/goal-directed-agents/snapshot.json` |
| Observer digest | `/app/data/runs/swarm_observer-1780608089253.md` |
| Orchestrator note | `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-04-orch-swarm-coverage-security-4a5d864b.md` |

## Deferred

- Full `security_cwe_audit` preflight (skipped `--skip-slow`).
- Publish copy to `research-findings` remote.
- Runtime ASan work (`sec-r3`) until httpd fuzz smoke (`sec-r1`) documents attack surface.
