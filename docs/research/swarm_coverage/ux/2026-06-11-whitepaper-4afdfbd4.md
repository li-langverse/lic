# Swarm gap orchestration — UX dimension audit

**Goal id:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `4afdfbd4`  
**Date:** 2026-06-11  
**north_star_fit:** ecosystem, ai — easy operator surfaces for swarm diagnostics  
**Publish repo:** research-findings (staging under `lic/docs/research/swarm_coverage/ux/`)

---

## Abstract

This pass audits the **UX dimension** of Li swarm gap orchestration: whether operators can trust health dashboards, gap registries, and GUI audit coverage. Agent execution is healthy (`swarm_execution: 100`), but **operator UX remains degraded** — control-plane state is not persisted, gap ingest is blocked (PyYAML), and a new **registry/loop-state drift** on studio UX todos inflates false gap pressure. The swarm can execute unattended; humans cannot confidently observe it without infra fixes.

---

## 1. Scorecard posture

| Dimension | Score | UX implication |
|-----------|-------|----------------|
| swarm_execution | 100.0 | Clean runs — good when visible in dashboard |
| gap_pressure | 60.0 | 62 open gaps; studio rows stale vs loop state |
| briefing_health | 69.0 | Preflight failures reduce briefing trust |
| goal_directed_health | 70.0 | Stale snapshot (2026-05-30) confuses runner pane |
| ecosystem_posture | 71.0 | CI dominates heap over UX agents |
| **Overall** | **76.1 (C)** | `unattended_safe: true` — execution yes, observability no |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (regenerated 2026-06-11T09:30Z)

---

## 2. Registry truthfulness (new UX finding)

**Observation:** `studio-ui-ux-plan-loop/state.json` marks `studio-ux-16` and `studio-ux-17` completed (22 iterations, gates OK). Gap registry still lists them as open `plan_debt` with apply action `skip missing backlog`.

**UX impact:** Operators see inflated plan debt; handoff prioritization skews away from real work (`orch-r4`, GUI sweeps).

**Remediation:** On next successful ingest, close matching registry rows from loop `completed_ids`. Mount `lic-studio-ui` only if backlog patching is still needed — completion state already exists in loop state.

---

## 3. Operator surface audit

### 3.1 Control plane transparency

`/app/data/control-plane/` contains only `sdk-slots/` — no `state.json`, `latest-report.json`, or `interventions.json`. Programmatic observer cannot surface retry budgets or auto-heal history after Job restart.

### 3.2 Gap pipeline UX

Ingest/apply blocked: `PyYAML required`. Last apply: `2026-06-11T00:05:46Z`. Operators perceive frozen gap backlog.

### 3.3 GUI preflight coverage

`ux-audit.json` (2026-05-30): 1 target (`lic-docs`, pass). Five GUI targets documented in `gui-ux-quality-handoff.md` are absent from routine briefing preflight.

**Route:** existing `ui_ux_quality` goal → `gui_ux_tester` (cadence 48h). No new agent registry ids.

---

## 4. Briefing vs scorecard drift

| Source | Top agents |
|--------|------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | `gap_explorer`, `ci_maintainer`, `plan_verifier`, `security_auditor` |

Missing from heap: `gap_explorer` (gap_pressure 60), `plan_verifier` (plan_debt 31, plan_audit skipped).

---

## 5. Recommendations (orchestration only)

1. Bake `python3-yaml` in org-research worker image.
2. Persist CP `state.json` + `latest-report.json` each supervisor tick.
3. Union scorecard agents into briefing heap (`benchmarks`).
4. Close stale studio gap rows from loop state on ingest (`lic`).
5. Dispatch `gui_ux_tester` for `orch-r4-ui-ux-signals` via `ui_ux_quality`.

---

## 6. Evidence index

| Path | Role |
|------|------|
| `benchmarks/data/latest/ecosystem-quality-report.json` | Grade + dimensions |
| `benchmarks/data/latest/swarm-gap-actions.json` | Apply pipeline status |
| `lic/data/swarm-gap-registry/registry.yaml` | Open gap taxonomy |
| `lic/data/studio-ui-ux-plan-loop/state.json` | Ground truth for studio todos |
| `benchmarks/data/latest/ux-audit.json` | Preflight UX coverage |
| `app/data/runs/swarm_observer-1781166982235.md` | This run digest |

---

_Publish target: `research-findings/whitepapers/2026-06/swarm_coverage/ux/2026-06-11-whitepaper-4afdfbd4.md` when repo is mounted._
