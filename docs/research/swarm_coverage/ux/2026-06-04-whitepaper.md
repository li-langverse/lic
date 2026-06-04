# Swarm coverage — UX dimension (2026-06-04)

**Goal id:** `swarm_coverage`  
**Research dimension:** `ux`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`  
**north_star_fit:** Ecosystem orchestration for studio UI/UX gaps — proof-before-perf; PH-UX gates on palette and GPU recovery.

## Thesis

Swarm gap orchestration for **ui_ux** must bridge three layers: (1) **PH-UX bench gates** in `lic` packages, (2) **plan_debt** rows in `swarm-gap-registry`, and (3) **research-lane** dispatch via `gui_ux_tester` / `ui_ux_quality`. Retired per-vertical systemd loops should not be reintroduced; studio work routes through the agents control plane.

## UX signals audited

### Studio command palette (UX-04)

- Implementation shipped in `studio-ux-16` with measured open/filter latency under budget.
- Bench: `lic/packages/li-ui/bench/palette_latency.toml` (12ms open, 8ms filter vs 50/30ms budgets).
- Registry had a **false open** `plan_debt` row until orch-r4 closed it against plan-loop `status: done`.

### GPU fail recovery (UX-08)

- `studio-ux-17` delivered native fail strip + retry; iteration report shows UX-08 score 2.8.
- Bench: `lic/packages/li-studio/bench/gpu_fail_recovery.toml`.
- Same registry staleness pattern as UX-04.

### Viz / scientific UX (ecosystem)

- `gap-vertical-stub-scientific-viz` remains **open** (`competitor_feature`) — honesty stub, not studio shell.
- Briefing lists 100+ benchmark workloads as `unknown` (no tier-1 color) — blocks unattended UX narrative until catalog CI PRs land.

## Orchestration health (UX lens)

| Signal | Status | Evidence |
|--------|--------|----------|
| Gap ingest | **Fixed** this pass | `lic/scripts/swarm-gap-ingest.py` Path fallback |
| Gap apply (studio) | **Blocked** | Missing `lic-studio-ui` mount |
| Goal snapshot | **Stale** | `snapshot.json` dated 2026-05-30 |
| Ecosystem grade | **C** (73.6) | `benchmarks/data/latest/ecosystem-quality-report.json` |
| Unattended safe | **false** | 32 failed PRs, 62 open gaps |

## Recommendations

1. **Refresh snapshot** before next `swarm-gap-ingest` — prevents false studio `plan_pending` rows.
2. **Extend ingest** with `gap_kind: ui_ux` for PH-UX bench regressions (distinct from `plan_debt`).
3. **Dispatch `gui_ux_tester`** on `studio-ux-25` proactive sweep and viz stub audit.
4. **Do not** add `install-goal-plan-loop-systemd.sh` for studio-ui — use `implement-goals.yaml` / research lane per `docs/ecosystem/swarm-architecture.md`.

## Citations

- `lic/docs/ecosystem/orchestrator-notes/2026-06-04-orch-r4-ui-ux-signals.md`
- `lic/docs/ecosystem/swarm-observer-plan-backlog.md` (orch-r4)
- `benchmarks/data/latest/swarm-gap-actions.json`
- `li-cursor-agents/config/research-goals.yaml` (`ui_ux_quality`, `swarm_coverage`)
