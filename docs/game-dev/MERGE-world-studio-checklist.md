# Merge checklist — `feat/world-studio-impl-1` → `main`

**PR title:** feat: World Studio / Li Engine (impl-1–31)

## Pre-merge verify

```bash
./scripts/merge-world-studio-preflight.sh
# or stepwise:
./scripts/check-world-studio-gates.sh
./scripts/check-portable-targets.sh
./scripts/verify-world-studio-binary.sh
```

## Stats (impl-31)

| Metric | Value |
|--------|--------|
| Composable gates | 98 |
| Demo tabs | 11 (incl. Additive) |
| Spin-up templates | 10 |
| Portable targets | 5 triples (`check-portable-targets.sh`) |
| game_dev parse_ok | 12 |
| vertical_demos build | 7 |
| spinup_templates | 10 |
| Release rollup | `import_world_studio_release_rollup` |

## After merge

1. Register new packages in `docs/ecosystem/official-packages.md` (human).
2. Publish `li-studio`, `li-mmo`, … mirror repos per package workflow.
3. Enable Pages link to [demo-showcase.md](demo-showcase.md).

## Known deferral

- `sim_step_physics` → `physics.runtime` (`sim_physics_runtime_deferred`)
