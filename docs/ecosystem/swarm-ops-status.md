# Swarm ops status (WP-0 baseline)

Updated: 2026-05-25 (America/New_York)

## Linger

- `loginctl enable-linger s4il0r` — **ok** (`Linger=yes`)
- User systemd units survive logout/reboot when enabled.

## Installed plan-loop units (this session)

| Unit | ID | State | Log / data |
|------|-----|-------|------------|
| `li-security-research-plan-loop.service` | security-research | enabled, **active (running)** | `lic-worktrees/security-research/data/security-research-loop/` |
| `li-swarm-observer-plan-loop.service` | swarm-observer | enabled, **active (running)** | `lic/data/swarm-observer-plan-loop/` |

Install command:

```bash
cd lic
LI_CURSOR_ENV_FILE=/home/s4il0r/Documents/Cursor/.env \
  ./scripts/install-goal-plan-loop-systemd.sh security-research swarm-observer
```

Note: first combined install printed only security-research; `swarm-observer` was installed in a second invocation (both now enabled).

## Other enabled plan loops (pre-existing)

- `li-compiler-studio-plan-loop.service`
- `li-httpd-plan-loop.service`
- `li-sim-algo-plan-loop.service`
- `li-sim-chem-research-plan-loop.service`
- `li-sim-md-research-plan-loop.service`
- `li-studio-ui-ux-plan-loop.service`

## Dashboard / async swarm

- `curl http://127.0.0.1:9477/api/runtime` — **connection refused** (dashboard not listening on 9477).
- `async_swarm_running` — **unknown** until dashboard/async-swarm systemd is up (WP-1).

## SDK slot locks

- Path: `li-cursor-agents/data/control-plane/sdk-slots/`
- `sdk-session.lock` — held by PID **315285** (`code_implementer`, compiler-studio); process **alive** → **not reclaimed**.

## Blockers / follow-ups

1. Start agents dashboard + async swarm (WP-1: `install-agents-swarm-systemd.sh`) to restore `:9477/api/runtime`.
2. WP-1 watchdog should monitor `li-*-plan-loop` health.
3. Multiple concurrent `run-agent` processes; SDK single-slot lock is expected contention until WP-2 policy lands.

## Env

- `LI_CURSOR_ENV_FILE=/home/s4il0r/Documents/Cursor/.env` used for installs.
