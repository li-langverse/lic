# Swarm gap orchestration — security dimension

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `5f83cf7b`  
**Agent:** `swarm_observer`  
**Generated:** 2026-06-11T20:45Z  
**north_star_fit:** ecosystem, ai (orchestration); security lens: **secure** pillar  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`

---

## Abstract

This pass audits whether the Li agent swarm can orchestrate **security-related gap closure** without human intervention. Execution health is good (zero error runs sampled, `CURSOR_API_KEY` present, swarm execution dimension 100%) but **gap ingest remains blocked** (PyYAML unavailable), **CWE catalog coverage is incomplete** (19/25 MITRE Top-25 missing), and **`security_auditor` is recommended but not in the briefing execution heap**. Security plan_debt rows (`sec-r1`–`sec-r3`) are correctly patched to backlogs from the last apply cycle (00:05Z) and require handoff via the `offensive_security` research goal — not retired systemd loops.

---

## Method

1. Scorecard: `ecosystem-quality-report.json` refreshed @ 20:45Z → grade C (76.1), `unattended_safe: true`
2. Briefing: `agent-briefing.json` @ 20:44Z — recommends `ci_maintainer`, `security_auditor`; heap schedules `ci_maintainer` only
3. CWE feed: `security-cwe-feed.json` @ 20:44Z vs `lic/security/cve-catalog.json`
4. Gap registry: 62 open rows; security-research plan_debt subset in `swarm-gap-actions.json`
5. Dry-run: `swarm-gap-ingest.py` (PyYAML failure; `pip` absent)
6. Control plane: `state.json` / `latest-report.json` absent under `/app/data/control-plane/`
7. PH-DB security bench: `tier-db-security.json` status **stub** (`injection_blocked`, `rls_bypass_blocked` null)

---

## Findings

### 1. CWE catalog gap (high)

| Metric | Value |
|--------|-------|
| Top-25 baseline | 25 |
| Catalog rows | 15 |
| Missing in catalog | **19** |

Representative missing: CWE-79 (XSS), CWE-89 (SQLi), CWE-352 (CSRF), CWE-798 (hardcoded credentials).

**Implication:** `security_auditor` cannot close the org security scorecard until catalog backfill is human-approved.

### 2. Security plan_debt routing (medium)

Three `security-research` runner todos remain open in snapshot; apply-actions (00:05Z) patched them to `security-research-backlog.md`:

| Todo | Content |
|------|---------|
| `sec-r1-httpd-fuzz-smoke` | libFuzzer/AFL smoke vs live li-httpd |
| `sec-r2-tier5-gap-exploit` | Close empty tier5 exploit row vs nginx |
| `sec-r3-runtime-surface` | Runtime attack surface + ASan slice |

Orchestration policy:

- Route via `config/research-goals.yaml` → `offensive_security` → `security_auditor`
- Do **not** spawn `security-research` systemd plan loop

### 3. Goal-orientation drift (medium)

| Source | Recommended agents |
|--------|-------------------|
| Briefing heap | `ci_maintainer` only |
| Briefing recommended_agents | `ci_maintainer`, `security_auditor` |
| Scorecard recommended_agents | `gap_explorer`, `plan_verifier`, `ci_maintainer`, `security_auditor` |
| Recent runs | `swarm_observer` meta passes |

### 4. Gap ingest dependency (high)

PyYAML missing in org-research worker image blocks live registry refresh. Stale apply artifact (00:05Z) still routes sec-r rows correctly but cannot absorb new explorer signals or close `wp-n5-security-bench` (deferred).

### 5. Control-plane observability (high)

Absent CP disk mirrors prevent verifying programmatic observer retries, healer dispatch, or `stopped_agents` — an integrity concern when security audit trails are incomplete.

### 6. Benchmark security unknowns (medium)

`tier5_http_exploits`, `injection_blocked`, and `rls_bypass_blocked` appear in ecosystem audit **unknown** list. `tier-db-security.json` remains stub since 2026-05-25. Aligns with `wp-n5-security-bench` ph-db todo.

---

## Recommendations

1. Bake `python3-yaml` in org-research worker image.
2. Union scorecard agents into briefing heap (especially `security_auditor`).
3. Dispatch `offensive_security` on cadence for sec-r1–sec-r3.
4. Human-approved CWE catalog PR for 19 missing Top-25 rows.
5. Persist observer state each supervisor tick.
6. Map `wp-n5-security-bench` in gap apply (stop deferring ph-db security bench).

---

## Evidence paths

- `/app/data/runs/swarm_observer-1781207493669.md`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/tier-db-security.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-11-orch-security-5f83cf7b.md`
