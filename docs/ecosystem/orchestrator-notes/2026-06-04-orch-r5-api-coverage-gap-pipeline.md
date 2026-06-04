# Orchestrator note — `orch-r5-api-coverage-gap-pipeline`

**Date:** 2026-06-04  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage` (org research worker `709a644a`)  
**Briefing hash:** `b5c1489da8a88520`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (69.3); `unattended_safe: false` |
| Gap pipeline | **Repaired this run** — ingest syntax + PyYAML installed; ingest/apply succeeded |
| Open gaps | **62** (was 64): `missing_package` 1, `plan_debt` 31, `competitor_feature` 30 |
| Control-plane DB | **Unavailable** — MCP `ECONNREFUSED 127.0.0.1:54322`; disk cache missing |
| Unattended? | **No** — preflight failures, gap backlog, stopped goal runners, CI-red PR wave |

---

## API-coverage audit (gap orchestration lens)

| Surface | Expected API | Observed | Severity |
|---------|--------------|----------|----------|
| `swarm-gap-ingest.py` | Parse registry + verticals fallback | **Fixed** L227–234 Path fallback; ran OK @ 2026-06-04T00:47Z | was **high** |
| `swarm-gap-apply-actions.py` | PyYAML backlog patch | **OK** after `apt install python3-yaml` | was **high** |
| MCP `li-control-plane-db` | `query_control_plane_db` for runs/state | **Down** — no SQL fallback to disk cache in Job pod | **high** |
| Briefing `recommended_agents` | Heap dispatches ci_maintainer + security_auditor | Matches heap_plan (coord_platform) — **no drift** | low |
| `config/research-goals.yaml` | `swarm_coverage` handoff_to | `[gap_explorer, plan_verifier, issue_planner]` — intact | ok |
| Org research dimensions | security, performance, ux, api-coverage | This run = api-coverage; prior dimension runs logged in org-research-audit | ok |
| Scorecard inputs | `runs_dir` sample | **0 runs** — `/workspace/li-cursor-agents/data/runs` empty in pod | **medium** |

Evidence:

- `benchmarks/data/latest/ecosystem-quality-report.json` (regenerated 2026-06-04T00:46Z)
- `benchmarks/data/latest/swarm-gap-actions.json` (regenerated 2026-06-04T00:47Z)
- `lic/data/swarm-gap-registry/registry.yaml` (92 rows, 62 open)
- `lic/scripts/swarm-gap-ingest.py` (Path fallback fix)

---

## Gap reconciliation (open rows)

### `missing_package` (1 open)

| Registry id | Backlog todo | Handoff |
|-------------|--------------|---------|
| `gap-line-profiler-001` | `pkg-line-profiler` → pending in `ecosystem-package-backlog.md` | `issue_planner` |

Closed since orch-r3: `std.summary`, `std.plot` (registry status closed; apply idempotent).

### `plan_debt` — swarm_observer todos

| Todo | Status | Action |
|------|--------|--------|
| `orch-r3-missing-package-sweep` | **Complete this run** — only line_profiler seed remains open | Mark completed; handoff `issue_planner` |
| `orch-r4-ui-ux-signals` | Pending — studio-ux-16/17 in registry | Handoff `gui_ux_tester` + `plan_verifier` |

### `competitor_feature` — api-coverage routing

Route via research goals (no new systemd loops):

- Tier-1 red benches → `numerics_researcher` / `bench_improver` (`numerics_sota`, PH-7e)
- Vertical stubs → `simulation_techniques` / `md_sim_algorithms` research goals
- `gap-infra-verticals-toml-missing-benchmarks-main` → `gap_explorer` + `docs_maintainer`

---

## Scripts executed

```bash
apt-get install -y python3-yaml   # Job image gap — recommend baking into org-research image
python3 lic/scripts/swarm-gap-ingest.py      # registry 92 rows; wrote registry.yaml
python3 lic/scripts/swarm-gap-apply-actions.py  # open_gaps=62; wrote swarm-gap-actions.json
cd benchmarks && python3 scripts/ecosystem-quality-grade.py  # grade D, 69.3
```

---

## Swarm routing (handoffs)

| Agent | Reason | north_star_fit |
|-------|--------|----------------|
| `gap_explorer` | gap_pressure 60; 62 open registry rows | ecosystem |
| `plan_verifier` | plan_debt 31; plan_audit skipped | provable |
| `issue_planner` | `pkg-line-profiler-001` seed | easy |
| `ci_maintainer` | 1 repo missing CI (briefing P0) | secure |
| `security_auditor` | 19 Top25 CWEs missing from catalog | secure |
| `gui_ux_tester` | orch-r4 studio-ux-16/17 pending | easy |

---

## Control-plane fixes (file paths)

| Fix | Path |
|-----|------|
| Ingest Path fallback (merged locally) | `lic/scripts/swarm-gap-ingest.py` |
| Install PyYAML in org-research Job | `li-cursor-agents/deploy/k8s/engine/` or `deploy/org-worker-entrypoint.sh` |
| MCP disk-cache fallback when Postgres down | `li-cursor-agents/src/control-plane/` + MCP server config |
| Enable deliverable gate | `LI_CURSOR_AGENTS_ENABLED=1` in supervisor env |
| Full preflight (drop `--skip-slow`) | benchmarks preflight driver |

---

## Human-only blockers

- Merge wave: 63 open PRs, 9 CI-red (benchmarks#311 scorecard, physics-codegen PRs, li-httpd#30)
- GitHub API rate limit on `org_ci_audit` (HTTP 403)
- `/workspace/roadmap/agent-kit` missing — `org_agent_kit_audit` fails
- Branch protection on `main` — orchestration fixes via PR only
