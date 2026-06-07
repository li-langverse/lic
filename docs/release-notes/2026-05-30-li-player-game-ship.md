# Release notes — 2026-05-30 li-player game ship (WP-GD-06)

**Date:** 2026-05-30  
**Branch:** `cursor/world-studio-master-plan-loop`  
**PH / REQ:** PH-GD-6, WP-GD-06  
**North star:** provable native Li game ship path — headless play + publish bundle from World Studio game profile.

## Summary

New `li-player` package ships a game demo via `studio_publish_bundle` after headless sim+physics ticks — no HTML runtime, no viewport required.

## Deliverables

| Item | Path |
|------|------|
| Package | `packages/li-player/` |
| Headless play | `player_headless_play`, `player_headless_play_tick` |
| Ship bundle | `player_publish_from_game`, `player_ship_game_demo` |
| Smoke | `packages/li-player/li-tests/smoke/player_publish.li` |
| Gate | `scripts/world-studio-plan-lic-smokes.sh` |

## Proof

```bash
lic check packages/li-player/li-tests/smoke/player_publish.li
./scripts/world-studio-plan-gates.sh
```

## Not in scope

- Full `li-player` binary with SDL viewport (future WP-GD-06 deepen)
- Async RL env pools (WP-RL-02)
