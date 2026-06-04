# Swarm coverage — security dimension (2026-06-04)

**Goal id:** `swarm_coverage`  
**Publish repo:** `research-findings` (staged under `lic` until mount)  
**Worker:** `0e5eb087`  
**north_star_fit:** Li secure-by-design ecosystem — provable language first; security research without bypassing proof gates.

## Summary

The swarm is **degraded** for unattended operation (`unattended_safe: false`, grade **C**, score **73.6**). Security-specific pressure is **high**: nineteen MITRE Top25 CWEs are absent from the canonical CVE catalog, three offensive-security plan todos remain pending in the registry apply pipeline, and the briefing heap under-schedules `security_auditor` relative to scorecard recommendations.

## CWE / catalog posture

Source: `/workspace/benchmarks/data/latest/security-cwe-feed.json` (synced 2026-06-04T18:45Z).

| Signal | Value |
|--------|-------|
| Catalog CWE count | 15 |
| Top25 missing in catalog | 19 |
| Actionable catalog_gaps (briefing) | 0 |
| Repos missing security workflow | 0 |

Missing CWE ids include CWE-79, CWE-89, CWE-20, CWE-22, CWE-352, CWE-434, CWE-862, CWE-476, CWE-287, CWE-502, CWE-77, CWE-119, CWE-798, CWE-918, CWE-306, CWE-269, CWE-94, CWE-863, CWE-276.

**Recommendation:** Human-gated expansion of `lic/security/cve-catalog.json` with mapped `li-tests` harness rows — not auto-merged by swarm agents.

## Security plan debt (registry → backlog)

Gap apply patched these rows into `/workspace/lic/docs/ecosystem/security-research-backlog.md`:

| Todo | Status | Handoff agent |
|------|--------|---------------|
| `sec-r1-httpd-fuzz-smoke` | pending | `security_auditor` |
| `sec-r2-tier5-gap-exploit` | pending | `security_auditor` |
| `sec-r3-runtime-surface` | pending | `security_auditor` |

`sec-r0-cwe-delta` is **completed** (feed sync operational).

## Swarm orchestration findings

1. **Gap ingest was broken** on main (`SyntaxError` L229, `KeyError` for `BENCHMARKS_COMPETITIVE`) — repaired locally; ingest/apply green after `python3-yaml`.
2. **Control plane disk cache empty** — no `/app/data/control-plane/latest-report.json` or `state.json`; programmatic observer retries not visible on this host.
3. **Preflight:** `org_ci_audit` exit 1 (GitHub API rate limit); `org_agent_kit_audit` exit 1 (`roadmap/agent-kit` missing).
4. **Benchmarks CI wave:** 32 failing PRs including metrics refresh stack (#348–#355) blocks honest catalog ingest on `main`.
5. **`CURSOR_API_KEY`:** set — SDK auth is not the blocker.

## Proof → easy → fast alignment

Security work must not weaken Lean/`trusted.lean` policy. Fuzz and exploit studies (`sec-r1`–`sec-r3`) are **study_only** until proof certificates exist for changed runtime surfaces.

## Next dispatch order

1. `security_auditor` — `offensive_security` / `sec-r1-httpd-fuzz-smoke`
2. `ci_maintainer` — unblock benchmarks metrics PRs + missing CI repos
3. `gap_explorer` — reconcile 62 open gaps after catalog honesty PRs merge

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780597902246.md`
