# Orchestrator note — orch-r20 security gap orchestration

**Date:** 2026-06-08  
**Author:** `swarm_observer` (worker `1504941f`, dimension `security`)  
**Goal:** `swarm_coverage`  
**north_star_fit:** ecosystem, ai — secure swarm control plane; proof-before-perf on security benches

## Evidence

| Artifact | Path |
|----------|------|
| Gap registry | `lic/data/swarm-gap-registry/registry.yaml` (92 rows after ingest) |
| Gap actions | `benchmarks/data/latest/swarm-gap-actions.json` (62 open @ 17:51Z) |
| CWE feed | `benchmarks/data/latest/security-cwe-feed.json` (19 Top25 missing in catalog) |
| Security backlog | `lic/docs/ecosystem/security-research-backlog.md` |
| Quality scorecard | `benchmarks/data/latest/ecosystem-quality-report.json` (66.8, grade D) |
| Observer digest | `/app/data/runs/swarm_observer-1780938559863.md` |

## Security plan_debt reconciliation

| Gap id | Backlog todo | Action | Handoff |
|--------|--------------|--------|---------|
| `gap-plan-pending-security-research-sec-r0-cwe-delta` | `sec-r0-cwe-delta` | **closed** — snapshot `completed_ids` includes todo | — |
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | patched → `security-research-backlog.md` pending | **`security_auditor`** via `offensive_security` goal |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | patched → backlog pending | **`security_auditor`** |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | patched → backlog pending | **`security_auditor`** |

**Do not** recommend `install-goal-plan-loop-systemd.sh` for `security-research`. Route via async swarm:

- `config/research-goals.yaml` → `offensive_security` (agent `security_auditor`, priority 9)
- `swarm_coverage` handoff_to already includes `gap_explorer`, `plan_verifier`, `issue_planner`

## CWE catalog pressure (human-gated)

- `security-cwe-feed.json`: 19 of MITRE Top25 CWEs absent from `lic/security/cve-catalog.json`
- `catalog-audit.json`: `tier5_http_exploits` in `missing_problem_size_sample` — blocks full tier5 security bench evidence
- Handoff: **`security_auditor`** → human-reviewed catalog expansion PR (never auto-merge `trusted.lean` / governance)

## Control-plane fixes shipped this cycle

1. **`swarm-gap-ingest.py`** — repaired `verticals.toml` Path fallback (line 229 SyntaxError) + `BENCHMARKS_COMPETITIVE` default
2. **`python3-yaml`** installed in observer container — `swarm-gap-apply-actions.py` now runs
3. **Bootstrap** — `/app/data/control-plane/state.json` + `latest-report.json` materialized on cold start

## Next dispatch order

1. `pr_merger` — lip#52 (merge-approved, gate-ready)
2. `security_auditor` — `sec-r1-httpd-fuzz-smoke` + CWE Top25 delta triage
3. `ci_maintainer` — 12 repos missing CI (10× HTTP 404 phantom repos in audit)
4. `gap_explorer` — reconcile 30 `competitor_feature` stubs after ingest refresh
