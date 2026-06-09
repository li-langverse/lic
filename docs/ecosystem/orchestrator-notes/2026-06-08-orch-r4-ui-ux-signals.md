# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `ux` · worker `d00ba62b`  
**Work item:** Link `ui_ux` / `plan_debt` studio-ui gaps to swarm goals and handoffs

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.3); `unattended_safe: false` |
| `orch-r4` | **In progress** — UX signals mapped; ingest syntax remediated; apply blocked on PyYAML |
| Open `ui_ux` / studio gaps | `studio-ux-16-palette-search-latency`, `studio-ux-17-gpu-fail-recovery` (registry + plan loop) |
| Operator UX | No `latest-report.json` / `state.json`; dashboard cannot show gap-apply status |
| Unattended? | **No** — preflight failures, gap apply tooling, CI audit rate limits |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `/workspace/lic/data/swarm-gap-registry/registry.yaml`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`.

---

## `ui_ux` gap reconciliation (Mode B)

| Registry / plan id | `gap_kind` | Status | Target | Handoff |
|--------------------|------------|--------|--------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `plan_debt` | open | `2026-05-24-studio-ui-ux-plan-loop.md` | `gui_ux_tester` via `ui_ux_quality` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `plan_debt` | open | same plan loop | `gui_ux_tester` via `ui_ux_quality` |
| `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` | `plan_debt` | open | this note | `swarm_observer` (complete after handoffs enqueued) |

**Do not** spawn new lic systemd plan loops. Route via:

- Research goal `ui_ux_quality` → agent `gui_ux_tester` (`config/research-goals.yaml`)
- Implement goal `studio_ui_ux` → agent `gui_ux_tester` (`config/implement-goals.yaml`)
- Studio plan loop todos remain source of truth for product UX work (`lic/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md`)

---

## UX lens findings (operator + agent chrome)

1. **Empty health artifacts** — `data/control-plane/latest-report.json` and `state.json` absent; programmatic observer cannot surface `swarm_degraded` to dashboard.
2. **Gap apply invisible** — `swarm-gap-actions.json` last applied 2026-05-31; no UI panel for patch status (`patched` vs `deferred`).
3. **Briefing vs execution drift** — briefing recommends `pr_merger`, `ci_maintainer`, `security_auditor`; research lane dominated by `swarm_coverage` meta-audits.
4. **Studio UX debt** — UX-16 (palette search latency) and UX-17 (GPU fail recovery) open 9+ days; iteration reports exist but plan todos still `pending` in snapshot.
5. **Preflight UX** — 8 scripts skipped (`--skip-slow`); operators lack full plan/security audit signal without slow preflight.

---

## Scripts (this cycle)

```bash
# ingest — syntax fixed 2026-06-08 (line 229 Path fallback)
python3 /workspace/lic/scripts/swarm-gap-ingest.py --dry-run
# apply — blocked: ModuleNotFoundError: yaml (no pip/apt in container)
python3 /workspace/lic/scripts/swarm-gap-apply-actions.py
```

Regenerated scorecard:

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# overall_score=66.3 grade=D unattended_safe=False
```

---

## Swarm routing (no new registry ids)

| Next agent | Reason | `north_star_fit` |
|------------|--------|------------------|
| `gui_ux_tester` | Close studio-ux-16/17; `ui_ux_quality` cadence | easy · ecosystem |
| `gap_explorer` | `gap-infra-verticals-toml-missing-benchmarks-main` blocks vertical ingest | ecosystem |
| `plan_verifier` | Refresh goal-directed snapshot (stale 2026-05-30); close `orch-r3`/`orch-r4` rows | provable |
| `ci_maintainer` | 12 repos missing CI (when `org_ci_audit` not rate-limited) | secure |
| `pr_merger` | lip#52 merge-approved + gate ready | coord_pull_requests |

---

## Human-only blockers

- Merge **lip#52** only after human confirms deploy-pages bump (auto-merge candidate).
- Failed CI PRs: lic#1176, lis#40–42 — require human triage, not auto-merge.
- Bake `python3-yaml` (or vendor PyYAML) in org-research Job image.
- Publish whitepaper to `research-findings/whitepapers/2026-06/swarm_coverage/ux/` (repo not mounted in this pod).

---

## Related

- Whitepaper staging: `lic/docs/research/swarm_coverage/ux/2026-06-08-whitepaper-d00ba62b.md`
- Run digest: `li-cursor-agents/data/runs/swarm_observer-1780881847173.md`
- Prior orch notes: `2026-05-31-orch-r3-missing-package-sweep.md`
