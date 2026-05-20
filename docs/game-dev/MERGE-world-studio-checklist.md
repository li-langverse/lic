# Merge checklist — `feat/world-studio-impl-1` → `main`

**PR title:** feat: World Studio / Li Engine (145 gates, play_mode)

## Pre-merge verify

```bash
./scripts/merge-world-studio-preflight.sh
# or stepwise:
./scripts/check-world-studio-gates.sh
./scripts/check-portable-targets.sh
./scripts/verify-world-studio-binary.sh
```

## Stats (impl-45)

| Metric | Value |
|--------|--------|
| Composable gates | **145** (milestone **145** at impl-45) |
| Li-native store / httpd / world journal | composable ecosystem gates |
| Demo tabs | **13** (incl. **Play**) |
| Spin-up templates | **12** (`play_mode`) |
| Portable targets | 5 triples (`check-portable-targets.sh`) |
| game_dev parse_ok | 12 |
| vertical_demos build | 7 |
| Merge gate | `import_world_studio_merge_to_main` |
| Release candidate | `import_world_studio_release_candidate` |
| Main verify (post-merge) | `./scripts/verify-world-studio-on-main.sh` |
| Author API | [world-api-quickstart.md](world-api-quickstart.md) |

```bash
./scripts/create-world-studio-pr.sh   # preflight + gh pr create --draft
```

## After merge

1. Register new packages in `docs/ecosystem/official-packages.md` (human).
2. On `main`: `./scripts/verify-world-studio-on-main.sh`
3. Publish `li-studio`, `li-mmo`, … mirror repos per package workflow.
4. Enable Pages link to [demo-showcase.md](demo-showcase.md).

## Known deferral

- `sim_step_physics` → `physics.runtime` (`sim_physics_runtime_deferred`)
