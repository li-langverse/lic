# World Studio — guide for coding agents

**Branch:** `feat/world-studio-impl-1` · **Gates:** 150 composable · **Policy:** Li-native first ([li-native-first.mdc](../../.cursor/rules/li-native-first.mdc))

## Start here (copy-paste)

```li
import studio
import world
import sim.scientific

var project = studio_project_new()
run_play_session(project, 1, 1280, 720, 0, 4)

var w = new_game_world(1)
var hero = spawn_entity(w, 1)
tick_game_world(w)

var f = new_field(0, 128, 2)
step_field(f, 0.001)
publish_repro(save_field_checkpoint(f).manifest_hash, 2)
```

## Imports

| Goal | Import |
|------|--------|
| Editor / play | `studio` |
| Game ECS | `world` |
| HPC field | `sim.scientific` |
| Viewport | `render` |
| MMO shard | `mmo`, `store.realtime`, `world` |
| Physics step | `sim` (`step_physics`) + `physics.runtime` |

## Scaffold

```bash
./scripts/list-world-studio-spinups.sh
./scripts/lis-new-world-studio.sh play_mode my-project
lic check my-project/main.li
```

## Verify

```bash
./scripts/merge-world-studio-preflight.sh
# After merge to main only:
./scripts/verify-world-studio-on-main.sh
```

## Do not

- Add Python/JS/Redis product logic — port to Li packages.
- Use `WorldSnapshot` for entity positions — use `new_game_world` / `spawn_entity`.
- Invent `_stub` names in user-facing code — use short aliases from [world-api-quickstart.md](world-api-quickstart.md).

## Merge

```bash
./scripts/create-world-studio-pr.sh
```

Human checklist: [MERGE-world-studio-checklist.md](MERGE-world-studio-checklist.md)
