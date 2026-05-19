# Merge checklist — `feat/world-studio-impl-1` → `main`

**PR title:** feat: World Studio / Li Engine (impl-1–23)

## Pre-merge verify

```bash
./scripts/ci-world-studio.sh
# or full CI:
./scripts/ci.sh
```

## Stats (impl-23)

| Metric | Value |
|--------|--------|
| Composable gates | 76 |
| game_dev parse_ok | 12 |
| vertical_demos build | 7 |
| spinup_templates | 6 |
| Studio binary | `build/bin/world-studio` |

## After merge

1. Register new packages in `docs/ecosystem/official-packages.md` (human).
2. Publish `li-studio`, `li-mmo`, … mirror repos per package workflow.
3. Enable Pages link to [demo-showcase.md](demo-showcase.md).

## Known deferral

- `sim_step_physics` → `physics.runtime` (`sim_physics_runtime_deferred`)
