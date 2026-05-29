# Release notes: 2026-05-29 — PH-ML + GPU battle plan

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-ML, PH-HW, G-gpu  
**Author:** agent

---

## Summary (one sentence)

Land the canonical 56-WP battle plan for `@gpu`, LKIR multi-vendor backends, and Li-only ML/DL/RL/AI parity path.

## Agent continuation (required)

1. Read: `docs/game-dev/PH-ML-GPU-battle-plan.md`, `specs/lig-rfc.md`, `packages/li-ml/`.
2. Execute: Wave 0 — WP-ML-01…03, WP-RL-02 (workspace + smokes).
3. Run: `./scripts/build.sh`, `lic check packages/li-ml/li-tests/smoke/*.li`.
4. Blocked on: WP-HW-06 for GPU perf claims; WP-ML-14 for dynamic `tensor`.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Battle plan | `docs/game-dev/PH-ML-GPU-battle-plan.md` — 56 WPs, ML-0…5, HW-0…4, G-gpu 7d, 5 waves, 8 agent batches | File path above |
| Cross-links | `PH-world-studio-program.md`, `specs/README.md` | Links to battle plan |

## Not changed (scope fence)

- No compiler `@gpu` lowering, LKIR emit, or package implementation in this PR (plan only).
- No benchmark timing claims.

## Breaking changes

N/A — documentation only.
