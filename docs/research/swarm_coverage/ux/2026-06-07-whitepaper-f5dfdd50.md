# Swarm gap orchestration — UX dimension whitepaper

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `f5dfdd50`  
**Run:** `swarm_observer-1780808107222`  
**Generated:** 2026-06-07T05:20:00Z  
**north_star_fit:** ecosystem, ai — operator UX and accessible benchmark surfaces (pillar: easy)

---

## Abstract

This pass audits swarm health through a **UX lens** for gap orchestration. The Li agent swarm is **degraded** (ecosystem grade **D**, 60.9; `unattended_safe: false`). The dominant UX failure mode is a **cluster of failing benchmarks PRs** fixing GPU chip picker ARIA tabs (#147), blocking dashboard accessibility improvements. Secondary pressure comes from **two open studio-ui-ux plan todos** (`studio-ux-16`, `studio-ux-17`) that gap apply cannot patch without the `lic-studio-ui` worktree. Gap ingest remains blocked by a **SyntaxError** in `swarm-gap-ingest.py:229` and missing **PyYAML** in the org-research worker image.

---

## Method

1. Regenerated `ecosystem-quality-report.json` via `python3 scripts/ecosystem-quality-grade.py`.
2. Compared briefing `recommended_agents` vs scorecard recommendations and heap plan.
3. Sampled registry open rows with `studio-ui-ux` and `orch-r4` handoff targets.
4. Correlated `agent-briefing.json` failed PR list with UX/a11y titles.
5. Attempted `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` (blocked).

---

## Findings

### F1 — Benchmarks GPU chip picker PR stack (critical UX)

Eight open PRs (#400–409) share the same accessibility intent (ARIA tabs, keyboard roving for GPU chip picker). All report `ci: fail`. This prevents the swarm from delivering WCAG-compliant benchmark UI without human stack consolidation.

**Evidence:** `/workspace/benchmarks/data/latest/agent-briefing.json` → `ecosystem_audit.failed_prs`

### F2 — Studio UI plan debt (medium UX)

| Todo | Title fragment | Registry status |
|------|----------------|-----------------|
| `studio-ux-16-palette-search-latency` | palette search latency | open |
| `studio-ux-17-gpu-fail-recovery` | GPU fail recovery UX | open |

**Evidence:** `/workspace/lic/data/swarm-gap-registry/registry.yaml`

### F3 — Gap pipeline blocked (high orchestration)

- `swarm-gap-ingest.py:229` — unterminated string literal (remediated locally).
- `swarm-gap-apply-actions.py` — `PyYAML required` (no pip/apt in container).

**Impact:** `orch-r4-ui-ux-signals` cannot close; studio backlogs not refreshed.

### F4 — Control plane blind spot (medium)

`runs_sampled=0` because grade script defaults `LI_CURSOR_AGENTS_ROOT` to `/workspace/li-cursor-agents` while runs live under `/app/data/runs`. Observer retry counts empty — no supervisor tick this session.

**Evidence:** `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` → `inputs.runs_dir`

---

## Recommendations

1. **Human:** Consolidate benchmarks GPU picker PR stack — pick one branch, close duplicates (#147).
2. **Merge:** lic ingest fix (Path fallback for `verticals.toml`).
3. **Infra:** Bake `python3-yaml` in org-research worker (`li-cursor-agents` deploy).
4. **Dispatch:** `gui_ux_tester` on `ui_ux_quality` cadence for studio-ux-16/17 + dashboard axe pass.
5. **Config:** Set `LI_CURSOR_AGENTS_ROOT=/app` in grade script / worker env.

---

## Validity

| Grade | Rationale |
|-------|-----------|
| **B** | Evidence from live briefing + registry + scorecard; gap apply not executed live |
| Staging | Publish to `research-findings/whitepapers/2026-06/swarm_coverage/ux/` when repo mounted |

---

## Related

- Orchestrator note: `docs/ecosystem/orchestrator-notes/2026-06-07-orch-r4-ui-ux-signals-f5dfdd50.md`
- Run digest: `/app/data/runs/swarm_observer-1780808107222.md`
