# Swarm gap orchestration — security dimension audit

**Goal:** `swarm_coverage`  
**Dimension:** security  
**Worker:** `87f3cbde`  
**Run:** `swarm_observer-1780893550319`  
**Generated:** 2026-06-08T05:04Z  
**north_star_fit:** ecosystem, ai — secure swarm orchestration for Li agent control plane

**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/2026-06-08-whitepaper-87f3cbde.md`

---

## Abstract

This pass audits Li swarm health through a **security lens**: whether gap orchestration reliably routes offensive-security work (`sec-r1`…`sec-r3`), whether CWE catalog coverage is current, and whether control-plane failures create unattended security debt. The swarm is **degraded** (grade D, 65.8); security-specific backlog rows exist but live gap ingest/apply remains blocked by missing PyYAML in the org-research worker image.

---

## Security posture signals

| Signal | Status | Evidence |
|--------|--------|----------|
| CWE catalog gaps | **19 Top-25 missing** | `agent-briefing.json` security_cwe section |
| Security workflows on repos | 0 missing | briefing preflight |
| `sec-r0-cwe-delta` | completed | registry + snapshot |
| `sec-r1` httpd fuzz smoke | **pending** | `security-research-backlog.md` |
| `sec-r2` tier5 exploit matrix | **pending** | registry + backlog |
| `sec-r3` runtime surface | **pending** | registry + backlog |
| httpd tier5 exploit gate | mostly complete | snapshot runner=httpd |
| lis edge/registry PRs | **CI failing** | ecosystem-audit failed_prs #40–42 |

---

## Gap orchestration (Mode B) — security findings

1. **Registry → backlog apply (stale but mapped):** `swarm-gap-actions.json` (2026-05-31) patched `sec-r1`…`sec-r3` to `security-research-backlog.md`. Rows remain `pending` — dispatch `security_auditor` under `offensive_security` goal, not a new lic systemd loop.

2. **Live ingest blocked:** `swarm-gap-ingest.py:229` SyntaxError remediated this run; PyYAML still required for registry R/W. Without it, security gap closure cannot be verified unattended.

3. **ph-db security bench:** `gap-plan-pending-ph-db-wp-n5-security-bench` has no backlog mapping — route via `issue_planner` or extend `swarm-gap-apply-actions.py` mapping table.

4. **Proof-before-perf:** Security research must not bypass Lean policy or disable tier5 exploit gates; orchestration fixes only.

---

## Recommendations

1. Bake `python3-yaml` (or vendored PyYAML) in org-research Job image — unblocks ingest/apply for all gap kinds including security plan_debt.
2. Dispatch `security_auditor` for `sec-r1-httpd-fuzz-smoke` after `pr_merger` clears lip#52 and CI lane is stable.
3. Human-gated issue: map CWE Top-25 delta → `cve-catalog.json` (19 rows).
4. Persist `/app/data/control-plane/state.json` + `latest-report.json` on every supervisor tick (observer cannot rely on meta-agent bootstrap).

---

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r13-security-gap-orchestration.md`
- `/app/data/runs/swarm_observer-1780893550319.md`
