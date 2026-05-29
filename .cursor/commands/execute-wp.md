# Execute PH-ML GPU work package

Run a single WP from the PH-ML + GPU battle plan.

## Usage

1. Load skill: `.cursor/skills/execute-ph-ml-gpu-wp/SKILL.md`
2. Pick WP ID from `docs/game-dev/PH-ML-GPU-execution-tracker.md`
3. Create branch `feat/wp-<id>-<slug>`
4. Implement minimal diff; verify; update tracker row
5. At wave boundary, run `.cursor/skills/ph-ml-gpu-wave-gate/SKILL.md`

## Quick verify (ML packages)

```bash
./scripts/build.sh
lic check packages/li-ml/li-tests/smoke/*.li
lic check packages/li-ml-rl/li-tests/smoke/*.li
```

## Honesty

No PyTorch/GPU perf claims until Tier-3 CSV rows exist. See `.cursor/rules/ph-ml-gpu-honesty.mdc`.
