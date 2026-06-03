# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-03  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Research dimension:** `ux` (worker `823782d8`)  
**Work item:** Surface studio-ui-ux / `gui_ux_tester` signals as `ui_ux` gaps; link studio backlog; complete orch-r4

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **C** (70.3); `unattended_safe: false` |
| `orch-r4` | **Completed** — UX gap signals documented; registry/plan drift flagged |
| Studio UX pending | **2** snapshot todos (`studio-ux-16`, `studio-ux-17`); plan loop file marks done → refresh snapshot |
| CI blockers | `lic#742`, `studio#67` typography FX sprint — failing CI |
| Gap pipeline | Ingest syntax fixed (`swarm-gap-ingest.py:229`); apply blocked on missing PyYAML |
| Unattended? | **No** — UX implementation + CI fixes need leaf agents or human review |

---

## UX signals ingested

### Plan loop vs snapshot drift

| Todo id | Plan file status | Snapshot status | Registry |
|---------|------------------|-----------------|----------|
| `studio-ux-16-palette-search-latency` | done | **pending** | open |
| `studio-ux-17-gpu-fail-recovery` | done | **pending** | open |
| `studio-ux-21-wgpu-swapchain-gpu-runner` | done | (not in snapshot) | open; patched 2026-05-31 |
| `studio-ux-24-gpu-runner-deps` | done | (not in snapshot) | open; patched 2026-05-31 |
| `studio-ux-25-proactive-sweep-20260531` | **pending** | (not in snapshot) | not in registry |

**Action:** Run `goal-directed-agents-snapshot.py` on a host with live studio-ui-ux runner; close registry rows when snapshot confirms completion.

### Failed PRs (UX-adjacent)

| PR | Repo | CI |
|----|------|-----|
| [#742](https://github.com/li-langverse/lic/pull/742) | lic | fail — typography FX / text_layout smokes |
| [#67](https://github.com/li-langverse/studio/pull/67) | studio | fail — typography W0 tests |

Handoff: `code_implementer` with `north_star_fit: ux, PH-UX-*`; human review for animation scope.

### Issue tracker

- [lic#575](https://github.com/li-langverse/lic/issues/575) — master-plan-gap for studio-ux-16/17 pending.

---

## Gap taxonomy (`ui_ux`)

Per swarm mandate, `ui_ux` gaps are discovered by `gui_ux_tester` / studio-ui loop and linked to plan todos — not free-form product edits.

| Signal | Mapped gap_kind | Target backlog | Swarm route |
|--------|-----------------|----------------|-------------|
| Palette search latency | `plan_debt` → ui_ux lens | `2026-05-24-studio-ui-ux-plan-loop.md` | `ui_ux_quality` goal → `gui_ux_tester` |
| GPU fail recovery UX | `plan_debt` → ui_ux lens | same | `gui_ux_tester` audit → `code_implementer` |
| Agent chrome / native shell | completed in plan | — | reference for orch-r4 baseline |
| Typography FX sprint CI | (no registry row yet) | — | add row on next `gap_explorer` pass if CI stays red |

**Do not** spawn new lic systemd plan loops. Route via:

- `config/research-goals.yaml` → `ui_ux_quality` (`gui_ux_tester`, cadence 48h)
- Implement lane → existing `studio_ui_ux_builder` / `code_implementer`

---

## Scripts executed

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# overall_score=70.3 grade=C unattended_safe=False

cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# swarm-gap-ingest: PyYAML required (after syntax fix on line 229)

python3 scripts/swarm-gap-apply-actions.py
# swarm-gap-apply-actions: PyYAML required
```

**Fix applied this pass:** `lic/scripts/swarm-gap-ingest.py` line 229 — corrected `Path(...) / "verticals.toml"` fallback (was unterminated string).

---

## Handoffs (cite north_star_fit)

| To | Reason | north_star_fit |
|----|--------|----------------|
| `gui_ux_tester` | Audit palette latency + GPU fail recovery vs SOTA | ux, ecosystem |
| `code_implementer` | Fix typography CI on lic#742 / studio#67 | ux, provable (no unsafe shortcuts) |
| `plan_verifier` | Refresh snapshot; close stale registry UX rows | ecosystem, ai |
| `ci_maintainer` | 1 repo missing CI; GPU runner deps for studio-ux-24 | ecosystem |
| `gap_explorer` | 64 open gaps; competitor + plan_debt pressure | ecosystem, ai |

---

## Whitepaper stub (publish when `research-findings` mounted)

**Path:** `research-findings/whitepapers/2026-06/swarm_coverage/ux-gap-orchestration.md`

**Abstract:** UX gap orchestration under `swarm_coverage` links studio-ui plan todos, registry `plan_debt` rows, and briefing CI signals without new systemd loops. Key finding: snapshot/plan/registry three-way drift on studio-ux-16/17 blocks unattended UX closure until snapshot refresh and PyYAML-enabled gap apply run in CI.

---

## Related

- Swarm observer digest: `/app/data/runs/swarm_observer-1780527197746.md`
- Registry: `lic/data/swarm-gap-registry/registry.yaml`
- Gap actions: `benchmarks/data/latest/swarm-gap-actions.json`
- Prior notes: `2026-05-30-orch-r2-competitor-stubs.md`, `2026-05-31-orch-r3-missing-package-sweep.md`
