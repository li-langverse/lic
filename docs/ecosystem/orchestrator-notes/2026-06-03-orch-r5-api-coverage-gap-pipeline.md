# Orchestrator note — `orch-r5-api-coverage-gap-pipeline`

**Date:** 2026-06-03  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` @ dimension **`api-coverage`** (worker `49c7e7c9`)  
**Work item:** Audit gap-orchestration API surfaces (MCP, scripts, briefing); unblock ingest/apply pipeline

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **C** (70.8); `unattended_safe: false` |
| Gap prep | **Blocked** — ingest SyntaxError L229; apply missing PyYAML |
| DB MCP | **Down** — `127.0.0.1:54322` refused in research Job |
| Open gaps | **64** in `swarm-gap-actions.json`; **62** `status: open` in registry |
| `orch-r5` | **Documented** — api-coverage findings; ingest/apply remain human-fix |
| Unattended? | **No** — script + dependency fixes required before next gap sweep |

---

## `api-coverage` findings

| API surface | Status | Evidence |
|-------------|--------|----------|
| `li-control-plane-db` MCP | FAIL | ECONNREFUSED |
| `li-ecosystem-context` MCP | OK | `get_briefing_snapshot` 2026-06-03T22:30Z |
| `swarm-gap-ingest.py` | FAIL | SyntaxError line 229 (`verticals.toml` Path) |
| `swarm-gap-apply-actions.py` | FAIL | PyYAML not installed |
| Briefing heap vs recommendations | DRIFT | `security_auditor` not heap-enqueued |
| Run history | EMPTY | Scorecard `runs_sampled: 0` |

---

## Scripts attempted

```bash
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py          # SyntaxError L229
python3 scripts/swarm-gap-apply-actions.py   # PyYAML required
cd /workspace/benchmarks
python3 scripts/ecosystem-quality-grade.py   # OK → 70.8 C unattended_safe=false
```

**Do not** recommend `install-goal-plan-loop-systemd.sh` — route via `li-cursor-agents` research/implement goals per `docs/ecosystem/swarm-architecture.md`.

---

## Open orchestrator todos (registry)

| Todo | Status | Next handoff |
|------|--------|--------------|
| `orch-r3-missing-package-sweep` | open | `issue_planner` — `gap-line-profiler-001` only remaining open package gap |
| `orch-r4-ui-ux-signals` | open | `gui_ux_tester` / `ui_ux_quality` — studio-ux-16/17 (lic#575) |

---

## Recommended control-plane fixes (file paths)

1. **`lic/scripts/swarm-gap-ingest.py:229`** — fix Path concatenation (blocking all ingest).
2. **Lic agent/CI image** — install `PyYAML` for apply script.
3. **`li-cursor-agents/deploy/k8s/engine/networkpolicy-li-swarm-supabase.yaml`** — research Jobs need DB MCP.
4. **`benchmarks` preflight** — clone `roadmap`; GH rate-limit backoff for `org_ci_audit`.
5. **`li-cursor-agents/src/heap/`** — enqueue `security_auditor` when CWE Top25 catalog gaps > 0.

---

## Handoffs (cite north_star_fit)

| To agent | Reason | north_star_fit |
|----------|--------|----------------|
| `issue_planner` | `gap-line-profiler-001` backlog | ecosystem — PH profiling for proved perf work |
| `gui_ux_tester` | studio-ux-16/17 plan debt | ecosystem, ai — Studio UX before perf claims |
| `gap_explorer` | 64 open registry rows stale since 2026-05-31 | ecosystem — competitor/plan gap discovery |
| `ci_maintainer` | 1 repo missing CI (briefing P0) | ecosystem — secure CI gate |

---

## Agent deliverable checklist

- [x] api-coverage MCP/script audit documented
- [ ] ingest + apply confirmed (blocked)
- [x] Scorecard regenerated
- [x] Swarm observer digest: `/app/data/runs/swarm_observer-1780525371217.md`
- [x] Orchestrator note (this file)
