# Orchestrator note — `swarm_coverage@api-coverage`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `05d74c0e`  
**Research goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**north_star_fit:** ecosystem, ai — swarm gap orchestration API surface audit

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **D**, 64.8; `unattended_safe: false`) |
| Gap registry | **62 open** (31 plan_debt, 30 competitor_feature, 1 missing_package) |
| Ingest/apply | **Remediated this run** — `swarm-gap-ingest.py` Path fallback + PyYAML via apt |
| API coverage gaps | Control-plane persistence, MCP readers, grader `runs_dir` default |
| `orch-r3` / `orch-r4` | Still **open** — missing-package sweep + ui-ux signals |

---

## API-coverage audit (swarm orchestration lens)

| Surface | Status | Evidence |
|---------|--------|----------|
| `get_briefing_snapshot` (MCP) | **Partial** — returns 3 recommended agents; `ecosystem_explorer: null` | `li-ecosystem-context` MCP call 2026-06-07 |
| `describe_package` (MCP) | Available | MCP tool catalog |
| `read_gap_registry` | **Missing** — no MCP tool; YAML on disk only | prior observer runs |
| `read_ecosystem_quality_report` | **Missing** — grader JSON on disk; not exposed via MCP | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Control-plane `state.json` | **Bootstrapped** this run | `/app/data/control-plane/state.json` |
| Control-plane `latest-report.json` | **Bootstrapped** this run | `/app/data/control-plane/latest-report.json` |
| Grader `runs_dir` default | **Wrong path** — `/workspace/li-cursor-agents/data/runs` → `runs_sampled=0` | scorecard `inputs.runs_dir` |
| `swarm-gap-ingest.py` | **Fixed** — line 229 SyntaxError + `KeyError: BENCHMARKS_COMPETITIVE` | `lic/scripts/swarm-gap-ingest.py` |
| `swarm-gap-apply-actions.py` | **Runs** after `python3-yaml` install | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| GitHub org CI audit API | **404/403** — 9 phantom repos + rate limit | `agent-briefing.preflight_runs.org_ci_audit` |
| `roadmap/agent-kit` | **Not mounted** | `org_agent_kit_audit` stderr |

---

## Gap orchestration (Mode B)

### Scripts executed

```bash
apt-get install -y python3-yaml          # ephemeral; not baked in worker image
python3 lic/scripts/swarm-gap-ingest.py
python3 lic/scripts/swarm-gap-apply-actions.py
python3 benchmarks/scripts/ecosystem-quality-grade.py
```

### Open gaps routed this cycle

| `gap_kind` | Count | Handoff target |
|------------|------:|----------------|
| `plan_debt` | 31 | `plan_verifier`, runner-specific loops via control plane |
| `competitor_feature` | 30 | `gap_explorer`, `numerics_researcher`, `bench_improver` |
| `missing_package` | 1 | `issue_planner` (`gap-line-profiler-001`) |

### Swarm-observer backlog todos (still open)

- `orch-r3-missing-package-sweep` — close after `pkg-line-profiler` handoff to `issue_planner`
- `orch-r4-ui-ux-signals` — link `studio-ux-16/17` to `gui_ux_tester` via `ui_ux_quality` goal

### Apply patches (live)

23 backlog rows patched; 2 studio-ui skips (missing `lic-studio-ui` mount).

---

## Recommended control-plane fixes

1. **`benchmarks/scripts/ecosystem-quality-grade.py`** — default `LI_CURSOR_AGENTS_ROOT=/app` for `runs_dir`
2. **`li-ecosystem-context` MCP** — add `read_gap_registry`, `read_ecosystem_quality_report`
3. **`src/control-plane/build-report.ts`** — persist `state.json` + `latest-report.json` each supervisor tick
4. **Org-research worker image** — bake `python3-yaml`, set `BENCHMARKS_COMPETITIVE`, mount `roadmap/agent-kit`
5. **`lic/scripts/swarm-gap-ingest.py`** — merge Path fallback fix (this run)

---

## Handoffs (cite north_star_fit)

| To agent | Reason | PH / domain |
|----------|--------|-------------|
| `gap_explorer` | 30 competitor_feature + verticals.toml on main | ecosystem |
| `plan_verifier` | Refresh stale snapshot (2026-05-30) | provable |
| `issue_planner` | `gap-line-profiler-001` missing_package | ecosystem, PH-7e |
| `ci_maintainer` | 14 repos missing CI | secure |
| `pr_merger` | lip#52 gate-ready | ecosystem |

---

## Human-only blockers

- lip#52 merge (protected branch)
- lis#40–#42 failing CI (registry/MCP/edge)
- 19 CWE Top-25 catalog rows (human-gated security)
- `trusted.lean` — never auto-merge
