# Merge checklist — `feat/world-studio-impl-1` → `main`

**PR title:** feat: World Studio / Li Engine (impl-1–24)

## Pre-merge verify

```bash
./scripts/check-world-studio-gates.sh
# or full CI:
./scripts/ci.sh
```

## Stats (impl-24)

| Metric | Value |
|--------|--------|
| Composable gates | 78 |
| Spin-up templates | 7 |
| game_dev parse_ok | 12 |
| vertical_demos build | 7 |
| spinup_templates | 7 |
| Studio binary | `build/bin/world-studio` |

## After merge

1. Register new packages in `docs/ecosystem/official-packages.md` (human).
2. Publish `li-studio`, `li-mmo`, … mirror repos per package workflow.
3. Enable Pages link to [demo-showcase.md](demo-showcase.md).

## Known deferral

- `sim_step_physics` → `physics.runtime` (`sim_physics_runtime_deferred`)
