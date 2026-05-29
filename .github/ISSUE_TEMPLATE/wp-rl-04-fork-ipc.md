---
name: WP-RL-04 fork IPC env pool
about: Unblock multi-process async RL env workers (fork IPC path)
title: "WP-RL-04: async env pool fork IPC"
labels: ["ph-ml", "blocked", "li-ml-rl"]
---

## Status

- **Done:** in-process `async_env_pool_tick_serial_batch` — `packages/li-ml-rl/li-tests/smoke/async_env_pool_serial.li`
- **Blocked:** OS process workers + length-prefixed IPC frames

## Design

`docs/game-dev/specs/ml-rl-async-env-pool.md`
