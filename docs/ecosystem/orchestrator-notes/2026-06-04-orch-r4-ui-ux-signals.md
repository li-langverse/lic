# Orchestrator note — `orch-r4-ui-ux-signals` (2026-06-04)

**Goal:** `swarm_coverage` · **Dimension:** `ux` · **Worker:** `77c8a24d`  
**north_star_fit:** ecosystem, ai — honest Studio/agent surfaces for swarm diagnostics (Vision-LLM partial)

## Evidence reviewed

| Artifact | Path | Finding |
|----------|------|---------|
| Studio plan loop state | `lic/data/studio-ui-ux-plan-loop/state.json` | `studio-ux-16` … `studio-ux-24` in `completed_ids`; native palette ~14ms, agent chrome ~12ms, wgpu swapchain CI wired |
| Goal-directed snapshot (stale) | `lic/data/goal-directed-agents/snapshot.json` | Still lists `studio-ux-16/17` as `plan_pending` — drives false-open registry rows |
| Swarm gap registry | `lic/data/swarm-gap-registry/registry.yaml` | `gap-plan-pending-studio-ui-ux-studio-ux-16/17` **open** despite loop completion |
| Gap apply | `benchmarks/data/latest/swarm-gap-actions.json` | Skips `lic-studio-ui/.../2026-05-24-studio-ui-ux-plan-loop.md` — plan path not mounted in org-research Job |
| UX handoff doc | `lic/docs/ecosystem/gui-ux-quality-handoff.md` | Routes `gui_ux_tester` / `ui_ux_quality`; documents `gap-ux-*` taxonomy (not yet in registry ingest) |
| Ecosystem grade | `benchmarks/data/latest/ecosystem-quality-report.json` | D / 66.3; `unattended_safe=false` |

## UX dimension conclusions (swarm_coverage)

1. **Studio wave-4 is done on disk** — registry/snapshot drift is the blocker, not missing product work on palette/GPU recovery.
2. **`ui_ux` gap_kind is absent** from registry (`by_kind` only: `missing_package`, `plan_debt`, `competitor_feature`). Ingest should add rows from `gui-ux-quality-handoff.md` (`gap-ux-audit-*`) on next `plan_verifier` + ingest pass.
3. **Swarm observer UX orchestration** — route open harness gaps to research goal `ui_ux_quality` (`gui_ux_tester`), not new systemd loops. See `docs/ecosystem/research-verticals.md`.
4. **`orch-r4` completion criteria for this pass:** orchestrator note + handoff table + recommend `plan_verifier` snapshot refresh; close stale `studio-ux-16/17` registry rows after snapshot proof.

## Handoffs (existing agent ids only)

| Target | Agent / goal | Action |
|--------|----------------|--------|
| Full GUI target sweep | `gui_ux_tester` via `ui_ux_quality` | Run all `ux-targets.json` journeys; refresh `benchmarks/data/latest-gui-ui-run/ui-audit.json` |
| Agents dashboard port/honesty | `gui_ux_tester`, `gui_ui_tester` | `gap-ux-audit-agents-dashboard` |
| Native studio capture | `studio_ui_ux_builder` | `world-studio-native` / issue #394 |
| Registry hygiene | `plan_verifier` | Re-run `goal-directed-agents-snapshot.py` on host; close `gap-plan-pending-studio-ui-ux-studio-ux-16/17` |
| Metrics refresh | `ci_maintainer` | Unblock `benchmarks` scorecard PRs (#318, #321) |

## Control-plane fixes (no product code in lic)

| Fix | Repo | Path |
|-----|------|------|
| Ingest `verticals.toml` fallback Path | `lic` | `scripts/swarm-gap-ingest.py` L229 (repaired 2026-06-04) |
| Bake `python3-yaml` in org-research image | `li-cursor-agents` | Job Dockerfile / chart |
| Mount `STUDIO_UI_UX_PLAN_PATH` or `lic-studio-ui` for gap apply | `li-cursor-agents` | org-research volume mounts |
| Persist `data/control-plane/latest-report.json` on Job exit | `li-cursor-agents` | supervisor finalize hook |

## Deferred

- Publish whitepaper → `research-findings/whitepapers/2026-06/swarm_coverage/ux/` (repo not mounted)
- Register `gap-ux-*` rows until ingest adds `ui_ux` kind
- Close `orch-r4` registry row after `plan_verifier` snapshot refresh (human or next observer pass)
