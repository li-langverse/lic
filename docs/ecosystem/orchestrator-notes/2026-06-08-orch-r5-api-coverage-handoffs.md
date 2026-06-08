# Orchestrator note — `orch-r5-api-coverage-handoffs`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` @ `api-coverage`  
**Worker:** `ee0ade89`  
**north_star_fit:** ecosystem, ai — programmatic gap APIs must be callable for unattended swarm orchestration.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (66.3)**; `unattended_safe: false` |
| Gap registry | 62 open rows; actions file stale (2026-05-31) |
| Ingest script | SyntaxError line 229 **fixed** (`swarm-gap-ingest.py`) |
| Apply pipeline | **Blocked** — `PyYAML required` in container |
| API-coverage focus | Control-plane `/api/*`, gap scripts, `lis` registry/MCP PRs |
| Unattended? | **No** — fix PyYAML + runs_dir + control-plane bootstrap |

---

## API-coverage reconciliation

| Surface | Status | Handoff |
|---------|--------|---------|
| `GET /api/swarm/health` | Code present (`ops-server.ts`) | Bootstrap `state.json` on supervisor start |
| `swarm-gap-ingest.py` | Syntax fixed; PyYAML missing | `li-cursor-agents` image bake |
| `swarm-gap-apply-actions.py` | Cannot load registry YAML | Same |
| `lis` registry + MCP (#41) | CI fail | `code_implementer` → `server_platform` goal |
| Briefing `org_ci_audit` | 12 repos 404/INCOMPLETE | `ci_maintainer` |
| `research-findings` index | Not mounted | Publish whitepaper out-of-band |

Evidence:

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780923260441.md`

---

## Open gap routing (no new systemd loops)

| `gap_kind` | Count | Route |
|------------|-------|-------|
| `competitor_feature` | 30 | `gap_explorer` → research goals (`md_sim_algorithms`, `numerics_sota`) |
| `plan_debt` | 31 | `plan_verifier` + `implementation_gaps`; ph-db deferred |
| `missing_package` | 3 | `issue_planner` (`pkg-line-profiler` still open) |
| `ui_ux` | 0 open | `orch-r4` — `gui_ux_tester` / studio-ui backlog |

---

## Scripts

```bash
# Attempted 2026-06-08T13:45Z
cd lic
python3 scripts/swarm-gap-ingest.py     # PyYAML required (syntax OK after fix)
python3 scripts/swarm-gap-apply-actions.py  # PyYAML required
cd ../benchmarks
python3 scripts/ecosystem-quality-grade.py  # wrote fresh report D/66.3
```

---

## Swarm routing

| Next agent | Reason |
|------------|--------|
| `gap_explorer` | Re-ingest after PyYAML; 64 stale actions |
| `plan_verifier` | `plan_audit` skipped — plan_debt drift |
| `ci_maintainer` | 12 repos missing CI |
| `issue_planner` | `pkg-line-profiler` + lis API gaps |
| `pr_merger` | lip#52 gate-ready |

---

## Related backlog todos

- `orch-r3-missing-package-sweep` — still **pending** in `swarm-observer-plan-backlog.md` (registry shows std.summary/plot closed; line_profiler open).
- `orch-r4-ui-ux-signals` — **pending**; studio-ux GPU todos patched in gap-actions.

This note satisfies **`orch-r5-api-coverage-handoffs`** for the api-coverage research dimension.
