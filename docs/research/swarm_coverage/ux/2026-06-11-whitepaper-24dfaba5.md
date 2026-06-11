# Swarm gap orchestration — UX dimension audit

**Goal id:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `24dfaba5`  
**Date:** 2026-06-11  
**north_star_fit:** ecosystem, ai — easy operator surfaces for swarm diagnostics  
**Publish repo:** research-findings (staging under `lic/docs/research/swarm_coverage/ux/`)

---

## Abstract

This whitepaper audits the **UX dimension** of Li's swarm gap orchestration control plane: how operators observe swarm health, gap registry status, and GUI/Studio UX coverage. The swarm executes without terminal errors (`swarm_execution: 100`), but **operator UX is degraded** — control-plane persistence is absent, gap ingest is blocked (PyYAML), and preflight UX audits cover docs only. The swarm can run unattended for agent execution; it cannot run unattended for **human confidence** in orchestration state.

---

## 1. Scorecard posture

| Dimension | Score | UX implication |
|-----------|-------|----------------|
| swarm_execution | 100.0 | No run failures — good operator signal when visible |
| gap_pressure | 60.0 | 62 open gaps invisible without manual registry reads |
| briefing_health | 69.0 | Preflight failures reduce trust in briefing pane |
| goal_directed_health | 70.0 | 6/9 runners stopped — stale snapshot confuses dashboard |
| ecosystem_posture | 71.0 | CI gaps dominate briefing over UX agents |
| **Overall** | **76.1 (C)** | `unattended_safe: true` — execution yes, observability no |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`

---

## 2. Operator surface audit

### 2.1 Control plane transparency

**Finding:** `/app/data/control-plane/` contains only `sdk-slots/` — no `state.json`, `latest-report.json`, or `interventions.json`.

**Impact:** Programmatic observer retry budgets (`observer.retry_counts`), `stopped_agents`, and `swarm_degraded` flags are lost on Job restart. Operators cannot answer "why wasn't agent X retried?" without log archaeology.

**Recommendation:** Persist CP artifacts each supervisor tick via `li-cursor-agents/src/control-plane/build-report.ts`.

### 2.2 Gap registry UX

**Finding:** Gap ingest/apply scripts fail with `PyYAML required`. Last successful apply: `2026-06-11T00:05:46Z`.

**Impact:** 62 open gaps appear frozen. Studio UX todos (`studio-ux-16/17`) show `skip missing backlog` because `lic-studio-ui` plan is not mounted in this container.

**Taxonomy:**

| Kind | Count | UX relevance |
|------|-------|--------------|
| plan_debt | 31 | Includes `orch-r4-ui-ux-signals`, studio-ux-16/17 |
| competitor_feature | 30 | Low — sim vertical stubs |
| missing_package | 1 | `li-line-profiler` — developer UX tooling |
| ui_ux | 0 | Studio items routed as plan_debt |

Evidence: `/workspace/lic/data/swarm-gap-registry/registry.yaml`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`

### 2.3 GUI UX preflight coverage

**Finding:** `ux-audit.json` (2026-05-30) and `ui-audit.json` (2026-05-31) each audit **one target**: `lic-docs` (pass).

**Gap vs handoff:** [gui-ux-quality-handoff.md](../../../ecosystem/gui-ux-quality-handoff.md) documents five GUI targets. Last full proactive sweep (2026-05-30): 4 pass, 1 skip (`agents-dashboard`), 0 fail.

| Target | Last status | Blocker |
|--------|-------------|---------|
| agents-dashboard | skip | Dev server :3000 ([#38](https://github.com/li-langverse/li-cursor-agents/issues/38)) |
| world-studio-demo | pass | HTML mock — Partial |
| world-studio-native | pass | SDL with LIC_ROOT |
| lic-tetris | pass* | *Studio stub |
| gui-gen-fixture | pass | http_probe only |

**Recommendation:** Route five-target sweep via existing `ui_ux_quality` research goal → `gui_ux_tester` (cadence 48h). Do not invent new agent registry ids.

---

## 3. Briefing vs scorecard drift (goal orientation UX)

Operators expect briefing heap to reflect scorecard priorities. Current mismatch:

| Source | Agents |
|--------|--------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

**UX impact:** Dashboard shows P0 CI/security work but hides gap reconciliation and plan audit refresh — the two agents most relevant to closing `orch-r4` and plan_debt UX gaps.

**Fix path:** `benchmarks/scripts/enrich-briefing-scorecards.py` — union recommendations.

---

## 4. orch-r4-ui-ux-signals reconciliation

Registry row `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` remains **open**. Apply action: `deferred (no runner backlog mapping)`.

**Correct routing (Mode B):**

1. On next successful ingest, add five handoff-documented `gap-ux-*` rows (see gui-ux-quality-handoff.md).
2. Hand off to `gui_ux_tester` via `config/research-goals.yaml` goal `ui_ux_quality`.
3. Link `studio-ux-16/17` to `studio_ui_ux_builder` when plan mounted — not new systemd loops.

Evidence: `/workspace/lic/docs/ecosystem/gui-ux-quality-handoff.md`, `li-cursor-agents/config/research-goals.yaml`

---

## 5. Conclusions

1. **Swarm execution UX is healthy** — no error streaks, API key present.
2. **Operator orchestration UX is degraded** — missing CP persistence, blocked gap pipeline, docs-only UX audit.
3. **Unattended safe for agents, not for operators** — manual file reads required for honest posture.
4. **Self-heal path is orchestration fixes**, not re-running leaf agents: PyYAML in image, CP persist, briefing union, five-target GUI sweep via existing goals.

---

## References

- [research-verticals.md](../../../../li-cursor-agents/docs/ecosystem/research-verticals.md) — `ui_ux_quality`, `swarm_coverage` goals
- [swarm-architecture.md](../../../ecosystem/swarm-architecture.md) — retired systemd loops
- [gui-ux-quality-handoff.md](../../../ecosystem/gui-ux-quality-handoff.md) — five GUI targets
- Orchestrator note: `lic/docs/ecosystem/orchestrator-notes/2026-06-11-orch-ux-24dfaba5.md`
- Run report: `/app/data/runs/swarm_observer-1781152589399.md`
