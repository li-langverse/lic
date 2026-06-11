# Swarm gap orchestration — security dimension

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `0b41beb1`  
**Agent:** `swarm_observer`  
**Generated:** 2026-06-11T07:30Z  
**north_star_fit:** ecosystem, ai (orchestration); security lens: **secure** pillar  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`

---

## Abstract

This pass audits whether the Li agent swarm can orchestrate **security-related gap closure** without human intervention. Leaf execution is healthy (zero error runs, SDK auth present) but orchestration remains degraded: CWE catalog coverage is **19/25 Top-25 short**, `security_auditor` is recommended but not heap-scheduled, gap ingest is blocked on PyYAML, and control-plane observer state is not persisted to disk. Security plan_debt rows (`sec-r1`–`sec-r3`) are correctly backlogged and must route via the `offensive_security` research goal — not retired systemd loops.

---

## Method

1. Scorecard: `ecosystem-quality-report.json` @ 05:20Z → grade C (76.1), `unattended_safe: true`
2. Briefing: `agent-briefing.json` @ 07:27Z — `recommended_agents` vs `heap_plan` drift
3. CWE feed: `security-cwe-feed.json` @ 07:26Z vs `lic/security/cve-catalog.json`
4. Gap registry: 62 open rows; security-research subset in `registry.yaml`
5. Dry-run: `swarm-gap-ingest.py` (PyYAML failure @ 07:30Z)
6. Control plane: `state.json` / `latest-report.json` absent under `/app/data/control-plane/`
7. Run sample: `/app/data/runs/*.json` — 1 running (`swarm_observer`), 0 errors

---

## Findings

### 1. CWE catalog gap (high)

| Metric | Value |
|--------|-------|
| Top-25 baseline | 25 |
| Catalog rows | 15 |
| Missing in catalog | **19** |

Representative missing: CWE-79 (XSS), CWE-89 (SQLi), CWE-352 (CSRF), CWE-798 (hardcoded credentials).

**Implication:** Org security scorecard cannot reach green until catalog backfill is human-approved and `security_auditor` runs on cadence.

### 2. Security plan_debt routing (medium)

Three `security-research` runner todos remain open. Apply-actions (00:05Z) patched them to `security-research-backlog.md`:

- `sec-r1-httpd-fuzz-smoke` — httpd fuzz smoke
- `sec-r2-tier5-gap-exploit` — tier5 exploit parity
- `sec-r3-runtime-surface` — runtime surface audit

Orchestration policy: route via `config/research-goals.yaml` → `offensive_security` → `security_auditor`. Do **not** spawn `security-research` systemd plan loop.

### 3. Goal-orientation drift (medium)

Briefing heap schedules only `ci_maintainer` while both briefing and scorecard recommend `security_auditor` (P0 CWE signal). Scorecard additionally recommends `gap_explorer` and `plan_verifier` — none appear in heap.

### 4. Gap ingest dependency (high)

```
swarm-gap-ingest: PyYAML required (pip install pyyaml)
```

Stale apply artifact (00:05Z) still routes sec-r rows correctly but cannot absorb new explorer signals or close completed httpd mitigation rows.

### 5. Control-plane observability (high)

Absent CP disk mirrors prevent verifying programmatic observer retries, healer dispatch, or `stopped_agents` — an audit-trail integrity gap for security governance.

### 6. Preflight / external API (medium)

- `org_ci_audit`: exit_code=1 — CI posture re-verify incomplete
- `org_agent_kit_audit`: exit_code=1 — missing `/workspace/roadmap/agent-kit`
- 8 scripts skipped (`--skip-slow`) including `plan_audit`

---

## Security dimension scorecard

| Signal | Score impact | Route |
|--------|--------------|-------|
| CWE Top-25 coverage 6/25 | briefing_health − | `security_auditor` |
| sec-r1–sec-r3 pending | gap_pressure − | `offensive_security` |
| Failed security-related CI PRs | ecosystem_posture − | human triage |
| Zero agent error runs | swarm_execution + | maintain |
| Gap ingest blocked | gap_pressure − | infra fix |

---

## Recommendations

1. **Immediate:** Dispatch `security_auditor` on CWE delta; enqueue `offensive_security` for sec-r1.
2. **Infra:** Bake `python3-yaml` into org-research worker image; persist CP observer state each tick.
3. **Orchestration:** Union scorecard agents into briefing heap when `gap_pressure.score < 80`.
4. **Governance:** Human PR for CWE catalog backfill — do not auto-merge `cve-catalog.json`.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1781159779266.md`

---

## Related

- `docs/ecosystem/swarm-architecture.md`
- `docs/ecosystem/research-verticals.md` — `swarm_coverage`, `offensive_security`
- Orchestrator note: `docs/ecosystem/orchestrator-notes/2026-06-11-orch-security-0b41beb1.md`
