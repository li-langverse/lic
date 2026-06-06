# Swarm coverage — security dimension whitepaper (staging)

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `fffe2637`  
**Date:** 2026-06-06  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`  
**north_star_fit:** ecosystem, ai — provable, secure swarm orchestration

---

## Abstract

This audit evaluates whether the Li agent swarm can **orchestrate security gaps unattended**: CWE catalog completeness, offensive-security research backlog (`sec-r1/2/3`), and control-plane self-heal for security-lane dispatch. Posture is **degraded (D, 62.6)** — security work is correctly identified in briefing and gap registry but **blocked on infra** (stopped runner, PyYAML, missing control-plane state).

---

## 1. Threat model for swarm security orchestration

| Risk | Observation | Mitigation |
|------|-------------|------------|
| Stale security backlog | sec-r1/2/3 pending 12+ days | Dispatch `security_auditor` on `offensive_security` |
| CWE catalog drift | 19/25 Top25 missing | Human-gated catalog PR; enable `security_cwe_audit` preflight |
| Gap ingest failure | SyntaxError + PyYAML | Merge ingest fix; bake PyYAML in worker |
| Observer blind spot | No CP state on disk | Persist `latest-report.json` / `state.json` offline |
| Retry storm (historical) | May-31 `agent_runs upsert` failures | Circuit-break; finalize runs on Job exit |
| Auto-merge of security PRs | Governance risk | Human-only for catalog + exploit mitigations |

---

## 2. Evidence summary

- **Grade:** D (62.6), `unattended_safe: false` — `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- **Briefing P0:** `security_auditor` — Top25 missing=19 — `/workspace/benchmarks/data/latest/agent-briefing.json`
- **CWE feed:** `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- **Gap registry:** 64 open; 3 security plan_debt — `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- **Snapshot:** `security-research` runner stopped — `/workspace/lic/data/goal-directed-agents/snapshot.json`

---

## 3. Security gap taxonomy (swarm_coverage Mode B)

| `gap_kind` | Security examples | Primary discoverer | Orchestrator action |
|------------|-------------------|--------------------|---------------------|
| `plan_debt` | sec-r1/2/3, wp-n5-security-bench | `plan_verifier` | Patch `security-research-backlog.md`; handoff `security_auditor` |
| `competitor_feature` | httpd tier5 exploits (indirect) | `gap_explorer` | Route to `numerics_researcher` / httpd backlog — not security lane |
| `missing_package` | — | `gap_explorer` | N/A this dimension |
| `ui_ux` | — | `gui_ux_tester` | N/A this dimension |

---

## 4. Recommended dispatch sequence

1. **`pr_merger`** — lip#52 (deps bump; low risk).
2. **`ci_maintainer`** — 6 repos missing CI (restores org audit signal).
3. **`security_auditor`** — `offensive_security` goal → `sec-r1-httpd-fuzz-smoke`.
4. **`plan_verifier`** — refresh goal-directed snapshot; reconcile 31 plan_debt rows.

---

## 5. Conclusion

Security gap **discovery and routing are sound** (registry + backlog + briefing alignment). **Execution is blocked** on worker deps (PyYAML), stale snapshot, and missing observer persistence. Swarm cannot run security research unattended until ingest/apply runs and `security_auditor` dispatches on cadence.

---

## References

- `lic/docs/ecosystem/security-research-backlog.md`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r7-security-handoffs.md`
- `/app/data/runs/swarm_observer-1780755892210.md`
- `docs/ecosystem/research-verticals.md` — `offensive_security` goal
