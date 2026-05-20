# Post-merge — World Studio on `main`

After merging `feat/world-studio-impl-1`:

## 1. Verify on `main`

```bash
./scripts/merge-world-studio-preflight.sh
./scripts/list-world-studio-spinups.sh
```

On **`main`** after merge:

```bash
./scripts/verify-world-studio-on-main.sh
```

## 2. New project

```bash
./scripts/lis-new-world-studio.sh play_mode my-game
lic check my-game/main.li
```

Author APIs: [world-api-quickstart.md](world-api-quickstart.md).

## 3. Ecosystem registration (human)

Add monorepo packages to [official-packages.md](../ecosystem/official-packages.md) (roadmap repo) — see [world-studio-packages.md](../ecosystem/world-studio-packages.md).

## 4. Deferred (safe on `main`)

| Item | Track |
|------|--------|
| `sim_step_physics` full API | `sim_step_physics_stub` until `physics.runtime` types unify in composables |
| Binary runtime smokes | Composables validate; `studio_main` stays exit-0 |
| `lis new world-studio` | Upstream lis repo; shim: `scripts/lis-new-world-studio.sh` |

## 5. Demo

```bash
./scripts/open-studio-demo.sh
# Play tab: ?demo=play
```
