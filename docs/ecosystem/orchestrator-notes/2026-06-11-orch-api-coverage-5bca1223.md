# Orchestrator note — API-coverage gap orchestration (`5bca1223`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `5bca1223`  
**Run:** `1781184987542`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (76.1), `unattended_safe: true` conditional |
| Gap prep | **Ingest blocked** (PyYAML); apply artifact @ `00:05:46Z` (~14h stale) |
| Open gaps | **62** (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1) |
| API coverage | File mounts OK; REST N/A in Job; MCP missing scorecard/registry readers; CP disk mirrors absent |
| Observer self-heal | **None observable** — `state.json` / `latest-report.json` ENOENT |
| SDK | `CURSOR_API_KEY` set |

---

## API-coverage reconciliation

Swarm gap orchestration requires read APIs that work in homelab, K8s org-research Jobs, and CI.

### Verified this pass

| Surface | Result |
|---------|--------|
| `get_briefing_snapshot` (MCP, `benchmarks_root=/workspace/benchmarks`) | ✅ returns `recommended_agents`, `generated_at` |
| `ecosystem-quality-report.json` | ✅ refreshed, score 76.1 |
| `swarm-gap-actions.json` + `registry.yaml` | ✅ 62 open gaps |
| `swarm-gap-ingest.py` | ❌ `PyYAML required` |
| `/app/data/control-plane/state.json` | ❌ absent |

### MCP gaps (`li-ecosystem-context`)

| Tool | Status |
|------|--------|
| `get_briefing_snapshot` | Works when `benchmarks_root` passed |
| `list_pending_handoffs` | ok (0 to `swarm_observer`) |
| `read_ecosystem_quality_report` | **missing** |
| `read_swarm_gap_registry` | **missing** |

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

Last apply: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (19 backlog patches).

| `gap_kind` | Open | Route |
|------------|------|-------|
| `plan_debt` | 31 | `plan_verifier` + sim/security backlogs |
| `competitor_feature` | 30 | `gap_explorer` → numerics research goals |
| `missing_package` | 1 | `issue_planner` (`li-line-profiler`) |

### Rows reconciled this pass

| Gap id | Action |
|--------|--------|
| `gap-line-profiler-001` | Handoff `issue_planner`; close when package issue filed |
| `orch-r3-missing-package-sweep` | Covered by line-profiler gap |
| `orch-r4-ui-ux-signals` | Handoff `ui_ux_quality` → `gui_ux_tester` |
| `gap-infra-verticals-toml-missing-benchmarks-main` | `gap_explorer` + `docs_maintainer` |
| Master-plan `plan_debt` (9) | Deferred — no runner backlog mapping |
| ph-db `wp-*` (9) | Route `database_platform` research goal |
| `studio-ux-16/17` | Defer until `STUDIO_UI_UX_PLAN_PATH` set |

**Do not** recommend `install-goal-plan-loop-systemd.sh`.

---

## Briefing vs scorecard drift

| Source | Top agents |
|--------|------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

**Fix:** Union scorecard recommendations into briefing enrichment pipeline.

---

## Handoffs (north_star_fit: ecosystem, ai)

| To agent | Reason |
|----------|--------|
| `gap_explorer` | 62 open gaps; `gap_pressure` score 60 |
| `plan_verifier` | 31 plan_debt; `plan_audit` skipped |
| `ci_maintainer` | 34 repos missing CI; 10 org 404s |
| `security_auditor` | Top-25 CWE catalog gaps (19 missing) |
| `issue_planner` | MCP api-coverage tools + PyYAML image + `li-line-profiler` |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1781184987542.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-11-whitepaper-5bca1223.md`
