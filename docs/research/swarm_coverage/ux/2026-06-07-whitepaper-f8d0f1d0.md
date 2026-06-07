# Swarm gap orchestration — UX dimension audit

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `f8d0f1d0`  
**Agent:** `swarm_observer`  
**Generated:** 2026-06-07T20:14Z  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/` (staging only — repo not mounted)

---

## Abstract

This whitepaper audits the **operator and developer UX** of Li's swarm gap orchestration pipeline: registry ingest, backlog apply, control-plane health mirroring, and supervisor dashboard surfaces. The ecosystem quality scorecard grades **D** (62.9) with `unattended_safe: false`. Primary UX failures are **invisible automation** (gap apply blocked), **missing health mirrors** (dashboard cannot show swarm state), and **stale plan snapshots** (registry rows disagree with completed studio-ui work).

---

## Method

1. Refreshed `ecosystem-quality-report.json` via `benchmarks/scripts/ecosystem-quality-grade.py`.
2. Read `lic/data/swarm-gap-registry/registry.yaml` and `benchmarks/data/latest/swarm-gap-actions.json`.
3. Attempted gap ingest/apply scripts; classified blockers.
4. Mapped open `studio-ui-ux` plan todos to `ui_ux` taxonomy.
5. Reviewed supervisor dashboard (`apps/org-supervisor-dashboard`) and control-plane artifact paths.
6. Compared briefing heap vs scorecard recommended agents.

Evidence paths cited inline.

---

## Findings (UX lens)

### 1. Operator cannot confirm gap apply

When `swarm-gap-apply-actions.py` fails (PyYAML missing), backlog markdown files are not updated and the operator has no dashboard signal that patches were skipped. **UX impact:** loss of trust in unattended swarm; manual log diving required.

**Evidence:** `swarm-gap-apply-actions.py` exit; `benchmarks/data/latest/swarm-gap-actions.json` stale @ 2026-05-31.

### 2. Control-plane mirror gap

`/app/data/control-plane/latest-report.json` was absent pre-run. The org supervisor dashboard depends on CP artifacts for swarm health display. **UX impact:** empty or stale dashboard during degraded posture.

**Evidence:** `/app/data/control-plane/` directory listing; bootstrapped this pass.

### 3. Studio UI/UX plan debt (user-facing product UX)

Two open studio plan todos represent direct product UX work routed through gap registry:

| Todo | UX theme |
|------|----------|
| `studio-ux-16-palette-search-latency` | Search/palette interaction performance |
| `studio-ux-17-gpu-fail-recovery` | Graceful GPU failure and recovery flows |

**Handoff:** `gui_ux_tester` under goal `ui_ux_quality`.

### 4. Registry vs snapshot drift

Many `studio-ui-ux` registry rows remain `open` while snapshot evidence marks todos completed. **UX impact:** orchestrator and dashboard over-report pending UX debt.

**Evidence:** `registry.yaml` vs `goal-directed-agents/snapshot.json` (generated 2026-05-30).

### 5. Briefing / heap UX for operators

Briefing heap top tasks (`pr_merger`, `ci_maintainer`) differ from scorecard meta recommendations (`gap_explorer`, `plan_verifier`). **UX impact:** operator confusion about which lane is authoritative.

---

## Recommendations

| Priority | Action | Owner |
|----------|--------|-------|
| P0 | Bake PyYAML + fix ingest syntax | `li-cursor-agents` deploy + `lic` PR |
| P0 | Persist CP mirror each supervisor tick | `li-cursor-agents/src/control-plane/` |
| P1 | Dashboard swarm health + gap-apply panel | `org-supervisor-dashboard` |
| P1 | Auto-close registry plan_debt on snapshot match | `swarm-gap-ingest.py` |
| P2 | Dispatch `gui_ux_tester` for studio-ux-16/17 | research lane |
| P2 | Publish this whitepaper to `research-findings` | `publish-research-whitepaper.sh` |

---

## Validity

| Criterion | Grade | Notes |
|-----------|-------|-------|
| Reproducibility | B | Scorecard refresh reproducible; gap apply blocked |
| Evidence linkage | A | All claims cite on-disk JSON/YAML paths |
| Actionability | B | Handoffs defined; infra blockers remain |

---

## References

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/agent-briefing.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r4-ui-ux-signals.md`
- `/app/data/runs/swarm_observer-1780861730268.md`
- `docs/ecosystem/research-verticals.md` — `swarm_coverage` + `ui_ux_quality` goals
