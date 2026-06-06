# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `ux` (worker `e1e335e4`)  
**Work item:** Surface studio-ui-ux / gui_ux_tester signals as `ui_ux` gaps; reconcile stale plan_debt rows

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (64.8); `unattended_safe: false` |
| `orch-r4` | **Completed** — 5 `ui_ux` registry rows added; studio-ux-16/17 plan_debt closed |
| UX harness | Proactive `gui_ux_tester` pass 2026-05-31: 4 pass / 1 skip (`agents-dashboard`) |
| Registry drift | Snapshot stale (2026-05-30) left studio-ux-16/17 open despite loop completion |
| Ingest blocker | `swarm-gap-ingest.py` Path syntax + missing `BENCHMARKS_COMPETITIVE` default — **fixed** |
| Unattended? | **No** — preflight UX docs-only; 38 failed PRs; gap ingest required PyYAML install |

---

## UX dimension audit (`ux` lens)

### Studio UI plan loop (evidence)

`lic/data/studio-ui-ux-plan-loop/state.json` shows **25/25** todos completed including:

- `studio-ux-16-palette-search-latency` — palette filter 9.5 ms (budget 30 ms)
- `studio-ux-17-gpu-fail-recovery` — GPU fail strip + retry overlay
- `studio-ux-21..24` — wgpu swapchain + GPU runner CI wave

Registry rows `gap-plan-pending-studio-ui-ux-studio-ux-16-*` and `-17-*` were **open** due to stale goal-directed snapshot. Closed with loop-state evidence.

### Proactive UX harness (evidence)

| Source | Finding |
|--------|---------|
| `benchmarks/data/latest-gui-ux-run/ux-audit.json` | 4 pass, 1 skip — `agents-dashboard` server down |
| `benchmarks/docs/ecosystem/ux-digests/2026-05-31-gui-ux.md` | UX-04 score 3 after studio-ux-16; UX-08 native GPU strip done |
| `benchmarks/docs/ecosystem/ux-digests/2026-05-30-gui-ui.md` | Playwright/axe not run; lic-tetris stub honesty ([#46](https://github.com/li-langverse/li-cursor-agents/issues/46)) |
| `benchmarks/data/latest/ux-audit.json` (briefing) | **docs-only** — no GUI targets in default preflight |

### New `ui_ux` registry rows

| id | Priority | Handoff |
|----|----------|---------|
| `gap-ux-preflight-docs-only` | 7 | `gui_ux_tester`, `ci_maintainer` |
| `gap-ux-agents-dashboard-unreachable` | 8 | `gui_ux_tester`, `studio_ui_ux_builder` |
| `gap-ux-lic-tetris-stub-honesty` | 7 | `gui_ui_tester`, `gui_ux_tester` |
| `gap-ux-playwright-journey-harness` | 7 | `gui_ux_tester`, `code_implementer` |
| `gap-ux-studio-wave3-native-deps` | 6 | `studio_ui_ux_builder`, `gui_ux_tester` |

Taxonomy: `ui_ux` → link `studio-ui-ux` plan todos + `ui_ux_quality` research goal; no new systemd loops.

---

## Scripts executed

```bash
apt-get install -y python3-yaml   # apply-actions dependency
cd lic
# fixed scripts/swarm-gap-ingest.py Path fallback (line 227–234)
BENCHMARKS_COMPETITIVE=/workspace/benchmarks/competitive python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

---

## Swarm routing (no new registry ids)

| Next agent | Reason |
|------------|--------|
| `gui_ux_tester` | `ui_ux_quality` goal — expand proactive harness; close `gap-ux-*` rows |
| `studio_ui_ux_builder` | Merge studio wave-3 branch; native deps on main |
| `ci_maintainer` | Wire GUI `ux_audit` into briefing preflight ([#32](https://github.com/li-langverse/li-cursor-agents/issues/32)) |
| `gap_explorer` | 64 open gaps; `verticals.toml` missing on benchmarks main |

Handoffs cite **north_star_fit:** easy · ai-first — Studio/agent GUI journeys + honest mock/native labeling.

---

## Human-only blockers

- Merge `lic` PR fixing ingest Path + orch-r4 UX signals (multiple open PRs with failing CI)
- `research-findings` repo not cloned — whitepaper publish deferred
- 3 org repos 404 (`li-api-kit`, `li-sec-agent`, `token-telemetry-service`) — cannot auto-onboard CI

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/studio-ui-ux-plan-loop/state.json`
- `/workspace/benchmarks/docs/ecosystem/ux-digests/2026-05-31-gui-ux.md`
