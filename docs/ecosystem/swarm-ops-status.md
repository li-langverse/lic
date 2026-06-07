# Swarm ops status (WP-0 baseline)

Updated: 2026-05-26 (America/New_York)

## Linger

- `loginctl enable-linger s4il0r` — **ok** (`Linger=yes`)
- User systemd units survive logout/reboot when enabled.

## Agents dashboard / async swarm (WP-AGT-01)

| Check | Result |
|-------|--------|
| `li-agents-dashboard.service` | **active** |
| `li-agents-async-swarm.service` | **active** |
| `curl http://127.0.0.1:9477/api/runtime` | **ok** — `async_swarm_running: true`, store `supabase` |
| `NODE_BIN` (systemd) | `/home/s4il0r/.local/node/bin/node` (**v24.11.0**) |
| `LI_CURSOR_ENV_FILE` | `/home/s4il0r/Documents/Cursor/.env` |
| `DISABLE_AUTOSTART` | **absent** (autostart on) |
| `li-agents-health-report.timer` | **active** (20min) |

Install / refresh:

```bash
cd li-langverse/li-cursor-agents
LI_CURSOR_ENV_FILE=/home/s4il0r/Documents/Cursor/.env npm run db:ensure
LI_CURSOR_ENV_FILE=/home/s4il0r/Documents/Cursor/.env ./scripts/install-agents-swarm-systemd.sh
rm -f data/control-plane/DISABLE_AUTOSTART
systemctl --user restart li-agents-dashboard li-agents-async-swarm
```

## Research session repair (WP-AGT-02)

```bash
npm run build
/home/s4il0r/.local/node/bin/node dist/cli/repair-research-sessions.js --apply
./scripts/sweep-hung-agents.sh --apply
```

2026-05-26 apply: no zombie sessions; disk state — `numerics_researcher` in_progress `chem_sim_algorithms`, `goal_researcher` / `proof_gap_researcher` cycle_complete, `stdlib_researcher` in_progress.

## GitHub / env (WP-INF-01)

- `push_ready=yes` (GH_TOKEN set in workspace `.env`; value not logged)
- `scripts/swarm-env-preflight.sh` — fail-fast boolean check in systemd wrapper logs
- Health report section: `GH_TOKEN present | yes` in `logs/swarm-health-reports/latest.md`

## Lanes snapshot

`li-cursor-agents/data/lanes/state.json`:

- `research_lane_enabled`: true
- `last_research_tick_at`: **2026-05-19T19:57:15.058Z** (stale — watch after async-swarm uptime)
- `last_maintenance_tick_at`: 2026-05-26T18:56:11.091Z (fresh)

## Installed plan-loop units

| Unit | ID | Notes |
|------|-----|-------|
| `li-security-research-plan-loop.service` | security-research | enabled |
| `li-swarm-observer-plan-loop.service` | swarm-observer | enabled |
| `li-compiler-studio-plan-loop.service` | compiler-studio | enabled |
| `li-httpd-plan-loop.service` | httpd | enabled |
| `li-sim-algo-plan-loop.service` | sim-algo | enabled |
| `li-sim-chem-research-plan-loop.service` | sim-chem-research | enabled |
| `li-sim-md-research-plan-loop.service` | sim-md-research | enabled |
| `li-studio-ui-ux-plan-loop.service` | studio-ui-ux | enabled |

Goal-plan wrappers source `LI_CURSOR_ENV_FILE` and mirror `GH_TOKEN` → `GITHUB_TOKEN`.

## SDK slot locks

- Path: `li-cursor-agents/data/control-plane/sdk-slots/`
- Sweep 2026-05-26: **0** reclaimed (no dead-PID locks)

## Blockers / follow-ups

1. **Research lane tick stale** — `last_research_tick_at` predates recovery; confirm new ticks in dashboard / `state.json` over next async-swarm cycles.
2. Health report still notes no successful researcher run in 24h — expect improvement once research lane rotates with SDK slots free.
3. Unrelated dirty tree in `li-cursor-agents` (lidb stub, handoffs) — not part of this recovery commit.

## Env

- `LI_CURSOR_ENV_FILE=/home/s4il0r/Documents/Cursor/.env` for all agent systemd paths and install scripts.
