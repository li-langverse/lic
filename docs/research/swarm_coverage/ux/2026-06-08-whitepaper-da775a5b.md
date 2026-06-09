# Swarm gap orchestration — UX dimension audit

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `da775a5b`  
**Date:** 2026-06-08  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`  
**north_star_fit:** ecosystem, ai — operator UX for unattended swarm health

---

## Abstract

This audit evaluates whether the Li agent swarm provides **operator-grade UX** for gap orchestration: readable health signals, timely backlog patches, and low manual intervention during routine org updates. Grade **D** (65.3) with `unattended_safe: false` — recoverable via control-plane fixes, not leaf-agent reruns.

---

## UX scorecard (swarm operator lens)

| Dimension | Score | UX interpretation |
|-----------|-------|-------------------|
| Briefing health | 69.0 | Preflight failures (CI audit, agent-kit) degrade trust in dashboard signals |
| Ecosystem posture | 63.0 | 12 repos missing CI — operator must triage before trusting merge queue |
| Goal-directed health | 70.0 | 6/9 runners stopped; snapshot stale → false-open gap rows |
| Swarm execution | 65.0 | 0 runs sampled in canonical runs dir — empty history UX |
| Gap pressure | 60.0 | 64 open gaps; ingest blocked → backlog patches stall |

**Evidence:** `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (regenerated 2026-06-08).

---

## UX findings (gap orchestration)

### 1. Stale snapshot → false operator alarms

Studio UI plan todos `studio-ux-16` and `studio-ux-17` show **done** in `docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` but remain **open** in `lic/data/swarm-gap-registry/registry.yaml` because `goal-directed-agents/snapshot.json` is from 2026-05-30.

**Operator impact:** Dashboard gap count inflated; `gui_ux_tester` may be dispatched for completed work.

### 2. Gap ingest failure → silent backlog drift

`lic/scripts/swarm-gap-ingest.py` had a **syntax error** on `verticals.toml` Path fallback (line 229). Fixed locally; runtime also lacks **PyYAML**, so programmatic observer ticks cannot refresh registry.

**Operator impact:** `swarm-gap-actions.json` frozen at 2026-05-31; apply pipeline appears healthy but is stale.

### 3. Control-plane mirror absence

`data/control-plane/state.json` and `latest-report.json` missing in this pod — only `sdk-slots/sdk-session.lock` present.

**Operator impact:** Dashboard cannot show retry counts, interventions, or recent-run UX; meta-audit relies on filesystem grep.

### 4. Briefing vs recommended-agent alignment

Briefing (2026-06-08) recommends `ci_maintainer`, `security_auditor`, `pr_merger`. Quality scorecard adds `swarm_observer`, `gap_explorer`, `ecosystem_grader`, `plan_verifier`. No critical drift — P0 merge (`lip#52`) preserved.

---

## UX-oriented self-heal recommendations

1. **Infra UX:** Mount siblings + hydrate CP mirrors on org-research Jobs.
2. **Signal freshness:** Run `plan_verifier` snapshot refresh before gap ingest.
3. **Dependency UX:** Ship `python3-yaml` in agent runtime image.
4. **Regression UX:** Schedule `gui_ux_tester` on `palette_latency.toml` + `gpu_fail_recovery.toml` after snapshot sync.

---

## References

- `lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r4-ui-ux-signals.md`
- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/agent-briefing.json`
- `li-cursor-agents/docs/ecosystem/research-verticals.md` (`ui_ux_quality`, `swarm_coverage`)
