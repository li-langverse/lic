# Plan-loop branches on official package mirrors

**Purpose:** Agent plan loops run in the **lic monorepo** (`packages/<name>/`). Review and publish slices land on **org mirror repos** (`studio`, `ui`, `li-httpd`, …) on branches with the **same name** as the lic branch.

## Why not commit directly to `studio` / `ui`?

| Reason | Detail |
|--------|--------|
| **Canonical tree** | Composables, `li-tests/`, benches, and `import gui` / `import ui` need `lic` workspace |
| **Mirrors** | `github.com/li-langverse/studio` is `packages/li-studio/` exported to repo root |
| **Loops** | `scripts/*-plan-loop.py` and `data/*-plan-loop/` live on `lic` only |

After lic PRs merge, run `./scripts/push-official-package-repo.sh <folder>` or `./scripts/push-all-plan-loop-mirrors.sh` to refresh mirrors.

## Branch map (2026-05-25)

| lic branch | Mirror repo | Package folder | Mirror PR |
|------------|-------------|----------------|-----------|
| `cursor/studio-ui-ux-plan-loop` | [studio](https://github.com/li-langverse/studio) | `li-studio` | [#2](https://github.com/li-langverse/studio/pull/2) |
| same | [ui](https://github.com/li-langverse/ui) | `li-ui` | [#2](https://github.com/li-langverse/ui/pull/2) |
| same | [li-gui](https://github.com/li-langverse/li-gui) | `li-gui` | (see repo) |
| same | [render](https://github.com/li-langverse/render) | `li-render` | [#2](https://github.com/li-langverse/render/pull/2) |
| `cursor/sim-algo-plan-loop` | [sim](https://github.com/li-langverse/sim) | `li-sim` | [#2](https://github.com/li-langverse/sim/pull/2) |
| same | [sim.scientific](https://github.com/li-langverse/sim.scientific) | `li-sim-scientific` | [#2](https://github.com/li-langverse/sim.scientific/pull/2) |
| `cursor/httpd-plan-continue` | [li-httpd](https://github.com/li-langverse/li-httpd) | `li-net-httpd` | [#10](https://github.com/li-langverse/li-httpd/pull/10) |
| `cursor/compiler-studio-plan-loop` | studio, ui, li-gui, render, [world](https://github.com/li-langverse/world) | respective `packages/*` | [#3](https://github.com/li-langverse/studio/pull/3) etc. |

**Stays on lic only:** `packages/li-math-numerics/` (no `li-math-numerics` mirror repo), compiler/runtime/benchmarks harness paths.

## Commands

```bash
./scripts/push-plan-loop-mirror-branch.sh \
  --lic-branch cursor/studio-ui-ux-plan-loop \
  --package li-studio --mirror-repo studio \
  --mirror-branch cursor/studio-ui-ux-plan-loop --open-pr

./scripts/push-all-plan-loop-mirrors.sh
```

This is a **tree split** (package snapshot at branch tip), not a literal `git cherry-pick` across repos.
