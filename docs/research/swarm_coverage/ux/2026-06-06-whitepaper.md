# Swarm gap orchestration — UX dimension audit

**Goal id:** `swarm_coverage`  
**Dimension:** `ux`  
**Agent:** `swarm_observer`  
**Run id:** `1780760393779`  
**Generated:** 2026-06-06T16:45Z  
**north_star_fit:** ecosystem, ai — proof-before-perf; UX signals must not bypass provability gates

---

## Abstract

This whitepaper audits the **UX lens** of swarm gap orchestration: how UI/UX plan debt, benchmarks preflight registration, and gap-apply backlog routing interact with the async swarm control plane. Grade **D (62.6)** with `unattended_safe: false` — UX-specific blockers prevent unattended gap closure for studio-ui and benchmarks dashboard surfaces.

---

## Method

1. Refreshed `ecosystem-quality-report.json` via `ecosystem-quality-grade.py`.
2. Read `registry.yaml` + `swarm-gap-actions.json` for open `ui_ux` / `studio-ui-ux` rows.
3. Attempted programmatic prep: `swarm-gap-ingest.py` → `swarm-gap-apply-actions.py`.
4. Cross-checked briefing failed PRs for ux-audit titles (#377–#384).
5. Compared research goals `swarm_coverage` and `ui_ux_quality` in `config/research-goals.yaml`.

---

## Findings

### 1. Gap apply UX path broken

`swarm-gap-apply-actions.py` skips patches for:

- `studio-ux-16-palette-search-latency`
- `studio-ux-17-gpu-fail-recovery`

**Cause:** Hardcoded backlog `/workspace/lic-studio-ui/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md` not present in container.

**Impact:** UX plan todos stay `open` in registry despite apply tick running.

### 2. Benchmarks ux-audit PR stack red

Eight open benchmarks PRs fail CI — mix of:

- `feat(ui-audit): register benchmarks dashboard in ux-targets preflight`
- `chore(metrics): refresh ecosystem grade 2026-06-06 (swarm observer …)`

**Impact:** Org preflight cannot register benchmarks dashboard in ux-targets; `gui_ux_tester` lacks stable audit target on main.

### 3. Ingest pipeline fragility (repaired this run)

Prior failures blocked all gap orchestration:

| Failure | Class |
|---------|-------|
| SyntaxError in `ingest_verticals_stubs` | Script defect |
| `KeyError: BENCHMARKS_COMPETITIVE` | Env default gap |
| `PyYAML required` | Container dep gap |

### 4. Research goal alignment

| Goal | Agent | UX relevance |
|------|-------|--------------|
| `swarm_coverage` | `swarm_observer` | Meta orchestration — this audit |
| `ui_ux_quality` | `gui_ux_tester` | Primary UX worker — should receive handoff for studio-ux + benchmarks dashboard |

Handoff chain: `swarm_observer` → `gui_ux_tester` (`ui_ux_quality`) → `code_implementer` / `docs_maintainer`.

---

## Recommendations

1. **Env alias:** `LIC_STUDIO_UI_ROOT` for gap-apply backlog resolution.
2. **Unblock benchmarks main:** Triage CI on ux-audit PR stack before next `gui_ux_tester` cadence.
3. **Pin deps:** `python3-yaml` in agent image; merge ingest fix to `lic` main.
4. **Preflight:** Re-enable `plan_audit` when not `--skip-slow` to refresh studio-ui snapshot vs registry.

---

## Validity

| Criterion | Grade |
|-----------|-------|
| Evidence freshness | B — briefing 2026-06-06T16:33Z; scorecard regenerated same hour |
| Reproducibility | B — scripts documented; container deps were missing pre-fix |
| Actionability | A — concrete handoffs + file paths |

**Status:** active  
**Publish repo:** `research-findings` (staging path under `lic/docs/research/swarm_coverage/ux/`)

---

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r4-ui-ux-signals.md`
- `/app/data/runs/swarm_observer-1780760393779.md`
