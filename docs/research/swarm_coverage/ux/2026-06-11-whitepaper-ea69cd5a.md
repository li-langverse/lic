# Swarm gap orchestration — UX dimension audit

**Goal id:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `ea69cd5a`  
**Date:** 2026-06-11  
**north_star_fit:** ecosystem, ai — easy operator surfaces for swarm diagnostics  
**Publish repo:** research-findings (staging under `lic/docs/research/swarm_coverage/ux/`)

---

## Abstract

This whitepaper audits the **UX dimension** of Li's swarm gap orchestration control plane on 2026-06-11. Agent execution is healthy (`swarm_execution: 100`), but **operator UX remains degraded**: control-plane state is not persisted, gap ingest is blocked (PyYAML), preflight UX audits cover docs only, and briefing heap under-dispatches relative to the quality scorecard. The swarm can run unattended for leaf agents; it cannot run unattended for **human confidence** in gap orchestration and Studio UX routing.

---

## 1. Scorecard posture

| Dimension | Score | UX implication |
|-----------|-------|----------------|
| swarm_execution | 100.0 | No run failures — good signal when visible |
| gap_pressure | 60.0 | 62 open gaps require manual registry reads |
| briefing_health | 69.0 | 2 preflight failures; 8 skipped |
| goal_directed_health | 70.0 | 6/9 runners stopped; snapshot stale (2026-05-30) |
| ecosystem_posture | 71.0 | CI gaps dominate briefing over UX agents |
| **Overall** | **76.1 (C)** | `unattended_safe: true` — execution yes, observability no |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (refreshed 2026-06-11T13:31Z)

---

## 2. Operator surface audit

### 2.1 Control plane transparency

**Finding:** `/app/data/control-plane/` contains only `sdk-slots/` — no `state.json`, `latest-report.json`, or interventions log.

**Impact:** Programmatic observer retry budgets (`observer.retry_counts`), `stopped_agents`, and `swarm_degraded` are lost on Job restart.

**Recommendation:** Persist CP artifacts each supervisor tick (`li-cursor-agents/src/control-plane/build-report.ts`).

### 2.2 Gap registry UX

**Finding:** `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` fail with `PyYAML required`. Last successful apply: `2026-06-11T00:05:46Z`.

**Impact:** Operators see a frozen 62-gap backlog. Studio UX todos (`studio-ux-16/17`) show `skip missing backlog` because `lic-studio-ui` plan path is not mounted.

| Kind | Count | UX relevance |
|------|-------|--------------|
| plan_debt | 31 | `orch-r4-ui-ux-signals`, studio-ux-16/17 |
| competitor_feature | 30 | Low — sim vertical stubs |
| missing_package | 1 | `li-line-profiler` — developer UX |
| ui_ux | 0 | Studio items routed as plan_debt |

Evidence: `/workspace/lic/data/swarm-gap-registry/registry.yaml`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`

### 2.3 GUI UX preflight coverage

**Finding:** `ux-audit.json` (2026-05-30) audits **one target**: `lic-docs` (pass). Five GUI targets in `gui-ux-quality-handoff.md` are absent from routine briefing preflight.

| Target | Routine briefing | Last proactive sweep |
|--------|------------------|----------------------|
| `lic-docs` | yes (pass) | pass |
| `agents-dashboard` | no | skip (dev server) |
| `world-studio-demo` | no | pass (HTML mock) |
| `world-studio-native` | no | pass (SDL capture) |
| `lic-tetris` | no | pass* (*stub) |
| `gui-gen-fixture` | no | pass (`http_probe` only) |

Evidence: `/workspace/benchmarks/data/latest/ux-audit.json`, `/workspace/lic/docs/ecosystem/gui-ux-quality-handoff.md`

### 2.4 Briefing heap vs scorecard

| Source | Recommended agents |
|--------|-------------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

**UX impact:** Operators see CI/security priority but not gap reconciliation or plan audit — the two agents most relevant to closing `orch-r4` and registry drift.

---

## 3. UX gap reconciliation (`orch-r4`)

`orch-r4-ui-ux-signals` remains **open** in the registry with apply deferred. This pass reconciles without product code:

1. Route to **`ui_ux_quality`** research goal → **`gui_ux_tester`** (existing agent id).
2. On next successful ingest, add five handoff-documented rows: `gap-ux-audit-native-studio`, `gap-ux-audit-agents-dashboard`, `gap-ux-audit-world-studio-demo`, `gap-ux-studio-wave2-plan`, `gap-ux-cinematic-studio-handoff`.
3. Link `studio-ux-16/17` to `studio_ui_ux_builder` when plan path is available — not a new systemd loop.

---

## 4. Conclusions

| Question | Answer |
|----------|--------|
| Can swarm run unattended? | **Partially** — leaf agents yes; gap orchestration UX no |
| Biggest UX blocker? | Missing CP persistence + frozen gap pipeline |
| Studio UX path? | `plan_debt` via research lane, not lic systemd loops |
| Next meta action? | PyYAML in image; CP artifact persistence; expand UX preflight |

---

## References

- `/app/data/runs/swarm_observer-1781181387019.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-11-orch-ux-ea69cd5a.md`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/lic/docs/ecosystem/gui-ux-quality-handoff.md`
