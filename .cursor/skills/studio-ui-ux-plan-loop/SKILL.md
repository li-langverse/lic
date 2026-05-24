---
name: studio-ui-ux-plan-loop
description: Run the Studio UI/UX goal-directed agent loop with per-iteration screenshots, video, UX rubric, and perf/memory benches. Progress on GitHub issues/releases only.
---

# Studio UI/UX plan loop

## When to use

- Implementing **native** Li Studio (`li-ui`, `li-gui`, `li-render`, `li-studio`)
- User wants **UX assessment every iteration** with captures and benchmarks
- **Not** for httpd or compiler Wave A (use other plan loops)

## Setup

```bash
export CURSOR_API_KEY=...
export LI_CURSOR_AGENTS_ROOT=/path/to/li-cursor-agents
export GH_TOKEN=...   # progress issue + release uploads
cd lic
git checkout -B cursor/studio-ui-ux-plan-loop
```

## Run

```bash
./scripts/studio-ui-ux-plan-loop.py --once
./scripts/studio-ui-ux-plan-continuous.sh
```

## Agent

`studio_ui_ux_builder` — implements + scores UX-01…14 + runs capture/bench.

## Artifacts (not in git)

- `data/studio-ui-ux-plan-loop/latest-bench.json`
- GitHub issue (`data/studio-ui-ux-plan-loop/tracking-issue.txt`)
- Release tag `studio-ui-ux-progress` (PNG + MP4)

## Rubric

`docs/game-dev/competitive-intel/ui-ux-by-dimension.md`

## SOTA (agentic AI)

`li-cursor-agents/ux-harness/sota/manifest.yaml` → `agentic_ai` category
