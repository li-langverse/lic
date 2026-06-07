# Swarm coverage — security dimension whitepaper (staging)

**Goal:** `swarm_coverage` · **Worker:** `2af0fb58` · **Date:** 2026-06-07  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`  
**north_star_fit:** ecosystem, ai — provable, secure language; swarm must not starve security research

## Abstract

Meta-audit of Li agent swarm health through a **security lens**: gap registry orchestration, CWE catalog completeness, and security-research plan debt. Grade **D (63.9)** with `unattended_safe: false`. Gap ingest/apply unblocked this cycle; three `security-research` todos remain pending with clear handoff to `security_auditor`.

## Security posture signals

| Signal | Value | Source |
|--------|-------|--------|
| CWE Top-25 missing in catalog | 19 | `agent-briefing.json` → `cwe_feed_delta` |
| Security workflow repos missing | 0 | briefing `security_auditor` reason |
| Open security plan todos | 3 (`sec-r1`–`sec-r3`) | `security-research-backlog.md` |
| Failed governance PRs | `lic#1021`, `#1014` | `ecosystem_audit.failed_prs` |
| Open swarm gaps (total) | 62 | `swarm-gap-actions.json` |

## Gap orchestration (security taxonomy)

### plan_debt → security-research

The registry maps `security-research` runner todos to `docs/ecosystem/security-research-backlog.md`. Apply pipeline patched:

- **sec-r1-httpd-fuzz-smoke** — tier5/httpd fuzz entry; gates in `security-research-gates.sh`
- **sec-r2-tier5-gap-exploit** — nginx mitigation exploit parity; ties to httpd tier5 rows
- **sec-r3-runtime-surface** — runtime attack surface survey (compiler/runtime, not `trusted.lean` without human approval)

**Route:** `offensive_security` research goal → `security_auditor` agent. No new systemd plan loops.

### CWE feed vs catalog

`sec-r0-cwe-delta` is **completed**. Remaining risk is catalog representation: 19 Top-25 CWE classes lack rows in `cve-catalog.json`. Until backfilled, `security_auditor` briefing signal stays P0.

## Swarm health (security impact)

1. **Retry storms (historical):** org-research persist failures burned SDK slots without closed audit records — integrity and exhaustion risk.
2. **Goal drift:** briefing P0 (`pr_merger`, `ci_maintainer`, `security_auditor`) vs meta-only `swarm_observer` runs — security lane starved.
3. **Missing CP mirrors:** without `state.json`/`latest-report.json`, programmatic observer cannot auto-dispatch `security_auditor` on CWE signals.

## Recommendations

1. **P0:** Dispatch `security_auditor` for `sec-r1` + CWE catalog gap narrative.
2. **P1:** Human review PR for `cve-catalog.json` Top-25 backfill (19 rows).
3. **P1:** Bake `python3-yaml` in org-research worker; persist control-plane disk cache each tick.
4. **P2:** Re-enable `security_cwe_audit` in briefing preflight (not `--skip-slow`).

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1780839217793.md`

## Deferred publish

Copy to `research-findings` when repo is mounted; index per `docs/ecosystem/research-verticals.md`.
