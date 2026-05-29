# PH-ML GPU wave gate

Run at the **end** of each wave before merge or release tag. Do not skip verification.

## Wave -1 — Agent-kit bootstrap

- [ ] `./scripts/sync-agent-kit.sh` (manifest ≥ 1.3.4)
- [ ] `.cursor/rules/ph-ml-gpu-honesty.mdc` present
- [ ] `.cursor/rules/ph-ml-gpu-wp-scope.mdc` present
- [ ] `.cursor/skills/execute-ph-ml-gpu-wp/SKILL.md` present
- [ ] `.cursor/hooks/remind-ph-ml-wp-id.sh` wired in `hooks.json`

## Wave 0 — ML-0 foundation

**Exit gate:**

```bash
./scripts/build.sh
lic check packages/li-ml/li-tests/smoke/*.li
lic check packages/li-ml-rl/li-tests/smoke/*.li
```

**Definition of done (battle plan §10 ML-0):**

- [ ] `li-ml`, `li-ml-rl` in `packages/li.toml` members
- [ ] ≥6 `li-ml` smokes + 3 `li-ml-rl` smokes `verify_ok`
- [ ] CHANGELOG + release note with scope fence
- [ ] No perf claims in release artifacts
- [ ] Tracker rows for WP-ML-01, 02, 03, 06, 09, WP-RL-02, WP-DOC-ML-03 marked done

## Wave 1 — CPU ML truth (preview)

- Tier-3 correctness vs NumPy oracle
- Real MLP 784→256→10 (WP-ML-04)
- Manual backward + train step (WP-ML-07, 08)

**Blocked until Wave 0 green.**

## Wave 2 — GPU spine (preview)

- LKIR parser + SPIR-V emit (WP-HW-03…07)
- `@gpu` MIR tag (WP-GPU-04)
- First honest GPU timing JSON field

**Blocked on:** WP-HW-06 (SPIR-V emitter).

## Honesty audit

Before claiming wave complete, grep release notes and CHANGELOG for forbidden terms: `parity`, `speedup`, `SOTA`, `PyTorch faster`, `GPU-accelerated` (unless quoting blocked status).

Cross-link: [PH-ML-GPU-execution-tracker.md](../../../docs/game-dev/PH-ML-GPU-execution-tracker.md)
