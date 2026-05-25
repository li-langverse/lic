---
name: goal-plan-loop-persistent
description: Installs and manages goal-directed plan loops (sim, httpd, compiler-studio, studio-ui-ux) as user systemd services that survive reboot. Use when the user wants autonomous agents to keep running, restart after reboot, install plan-loop systemd units, enable linger, or manage DISABLE_AUTOSTART for plan loops.
---

# Goal-directed plan loops (persistent)

Autonomous plan loops use `li-cursor-agents` + `code_implementer` (or a named agent). **User systemd + linger** keeps them running after logout and reboot.

## Quick start

```bash
cd lic
source ~/Documents/Cursor/.env   # CURSOR_API_KEY, GH_TOKEN

# One loop (isolated git worktree — does not change your main checkout)
./scripts/install-goal-plan-loop-systemd.sh sim-algo

# All registered loops (each uses its own worktree + branch)
./scripts/install-goal-plan-loop-systemd.sh --all

./scripts/goal-plan-loops-status.sh
```

## Registered loops

| ID | systemd unit | Branch (default) | Worktree |
|----|----------------|------------------|----------|
| `sim-algo` | `li-sim-algo-plan-loop` | `cursor/sim-algo-plan-loop` | `../lic-worktrees/sim-algo` |
| `httpd` | `li-httpd-plan-loop` | `cursor/httpd-plan-continue` | `../lic-worktrees/httpd` |
| `compiler-studio` | `li-compiler-studio-plan-loop` | `cursor/compiler-studio-plan-loop` | `../lic-worktrees/compiler-studio` |
| `studio-ui-ux` | `li-studio-ui-ux-plan-loop` | (see studio script) | main repo |
| `sim-md-research` | `li-sim-md-research-plan-loop` | `cursor/sim-md-research-loop` | `../lic-worktrees/sim-md-research` |
| `sim-chem-research` | `li-sim-chem-research-plan-loop` | `cursor/sim-chem-research-loop` | `../lic-worktrees/sim-chem-research` |

Research loops use `numerics_researcher` and `sim-algo-research-gates.sh` (validity hard gate). See `docs/ecosystem/sim-algo-research-grading.md`.

## Requirements

- `CURSOR_API_KEY` / `CURSOR_SDK_KEY` in `LI_CURSOR_ENV_FILE` (default `~/Documents/Cursor/.env`)
- `LI_CURSOR_AGENTS_ROOT` → `li-cursor-agents` with built `dist/cli/run-agent.js`
- `loginctl enable-linger $USER` (installer runs this) so user units survive reboot

## Stop / disable

```bash
touch data/sim-plan-loop/DISABLE_AUTOSTART
systemctl --user stop li-sim-algo-plan-loop

systemctl --user disable li-sim-algo-plan-loop   # no autostart on boot
rm data/sim-plan-loop/DISABLE_AUTOSTART          # re-enable
```

Logs: `data/<plan>-plan-loop/systemd.log` and `runner.log`.

## Adding a new loop

1. Add `scripts/<name>-plan-run-until-done.sh` (or `until-deadline.sh`).
2. Add thin `scripts/<name>-plan-loop-systemd.sh` exporting `GOAL_PLAN_*` and exec `lib/goal-plan-systemd-wrapper.sh`.
3. Register in `install-goal-plan-loop-systemd.sh` `plan_def()`.
4. Document gates, branch, and daily report script.

## Sim loop specifics

- Gates: `./scripts/sim-plan-gates.sh` (validity + perf + memory + docs)
- Daily 08:00: `./scripts/sim-plan-install-cron.sh`
- Handoff: `docs/ecosystem/sim-agent-handoff.md`

Do **not** run full `bench.py --tier 12` in agent goals — use `./scripts/bench-package.sh`.

## Branch contention

Each loop should set `GOAL_PLAN_WORKTREE` so parallel loops do not `git checkout` over each other. The main `lic` checkout stays on whatever branch the developer uses.
