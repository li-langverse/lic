# Orchestrator note — `orch-r4-ui-ux-signals` + `api-coverage`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage@api-coverage` (north_star_fit: ecosystem, ai)  
**Work item:** Surface studio-ui-ux / `gui_ux_tester` signals as `ui_ux` gaps; audit orchestration API coverage

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.8); `unattended_safe: false` |
| `orch-r4` | **In progress** — studio-ui-ux plan debt identified; `ui_ux` gap_kind absent from registry |
| API-coverage | Control-plane HTTP APIs present; gap **ingest script API** broken (syntax fixed; PyYAML missing) |
| `swarm_observer` dashboard | **Not listed** in `RESEARCH_DASHBOARD_AGENT_IDS` — meta runs omitted from `/api/research/runs` |
| Unattended? | **No** — gap pipeline cannot refresh; CI/platform preflights failing |

---

## Studio-ui-ux signals (plan_debt → `ui_ux` promotion)

Open `studio-ui-ux` plan todos in registry (snapshot stale @ 2026-05-30):

| Registry id | Plan todo | Status | Suggested `gap_kind` |
|-------------|-----------|--------|----------------------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `studio-ux-16-palette-search-latency` | open | `ui_ux` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `studio-ux-17-gpu-fail-recovery` | open | `ui_ux` |
| `gap-plan-pending-studio-ui-ux-studio-ux-21-wgpu-swapchain-gpu-runner` | `studio-ux-21-wgpu-swapchain-gpu-runner` | open (patched) | `ui_ux` |
| `gap-plan-pending-studio-ui-ux-studio-ux-24-gpu-runner-deps` | `studio-ux-24-gpu-runner-deps` | open (patched) | `ui_ux` |

**Apply patches (2026-05-31):** `studio-ux-21`, `studio-ux-24` → `2026-05-24-studio-ui-ux-plan-loop.md`.

**Handoff routing (no new systemd loops):**

| Agent | Reason |
|-------|--------|
| `gui_ux_tester` | Research goal `ui_ux_quality`; capture palette latency + GPU fail recovery signals |
| `code_implementer` | After UX audit — implement studio backlog items on `cursor/studio-ui-ux-plan-loop` |
| `swarm_observer` | Close `orch-r4` when ingest emits `ui_ux` rows |

---

## API-coverage audit (swarm orchestration)

| API / script | Consumer | Coverage gap |
|--------------|----------|--------------|
| `GET /api/goals` | Dashboard | `swarm_coverage` present ✓ |
| `GET /api/research/runs` | Researchers tab | `swarm_observer` **missing** from agent filter |
| `GET /api/supervisor/activity` | Ops board | OK when supervisor running |
| `swarm-gap-ingest.py` | Observer tick (`gap-registry-ingest.ts`) | Syntax error fixed; **PyYAML** dep blocks execution |
| `swarm-gap-apply-actions.py` | Briefing / observer | Last run 2026-05-31 |
| MCP `li-ecosystem-context` | Meta agents | `get_briefing_snapshot`, handoff tools ✓ |
| Briefing JSON | All agents | `recommended_agents` narrower than quality scorecard |

**Recommended `li-cursor-agents` changes:**

1. Add `swarm_observer` to `RESEARCH_DASHBOARD_AGENT_IDS` (`src/control-plane/research-runs-api.ts`).
2. Add `python3-yaml` to swarm/deploy image.
3. Extend `swarm-gap-ingest.py` to set `gap_kind: ui_ux` for `runner_id: studio-ui-ux` plan_pending rows.

---

## Blockers this run

```
# ingest (after syntax fix):
swarm-gap-ingest: PyYAML required (pip install pyyaml)

# control plane (fresh container):
data/control-plane/latest-report.json — missing
data/control-plane/state.json — missing
```

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml` (studio-ui-ux rows)
- `benchmarks/data/latest/swarm-gap-actions.json`
- `lic/docs/ecosystem/swarm-observer-plan-backlog.md` (`orch-r4` pending)
- `li-cursor-agents/data/runs/swarm_observer-1780936758833.md`
- `li-cursor-agents/src/control-plane/research-runs-api.ts`
