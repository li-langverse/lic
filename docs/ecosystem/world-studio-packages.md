# World Studio packages (monorepo `lic/packages`)

**Branch landed from:** `feat/world-studio-impl-1` (impl-40+)

| Import | Released repo (org) | `lic` mirror (integration) | Role |
|--------|---------------------|----------------------------|------|
| `studio` | **studio** | `packages/studio` | Shell, play mode, publish |
| `studio.ai` | **studio.ai** | `packages/studio.ai` | Agent diagnose / patch |
| `world` | **world** | `packages/world` | GameWorld ECS, RealmHead, streaming |
| `sim` | **sim** | `packages/sim` | Profiles, `sim_step`, physics stub |
| `sim.scientific` | **sim.scientific** | `packages/sim.scientific` | SimField, checkpoints, GPU hook |
| `render` | **render** | `packages/render` | Viewport, GPU surface |
| `mmo` | **mmo** | `packages/mmo` | Realms, shards, WS bind |
| `store.realtime` | **store.realtime** | `packages/store.realtime` | Li-native presence / replay |
| `net.httpd` | **net.httpd** | `packages/net.httpd` | Li-native gateway |
| `physics.custom` | **physics.custom** | `packages/physics.custom` | Arbitrary laws |
| `physics.runtime` | **physics.runtime** | `packages/physics.runtime` | PhysicsWorld step (composable) |

**Naming rule:** [package-import-naming.md](package-import-naming.md) — repo slug = import path.

Register in roadmap **official-packages** when publishing mirror repos.

**App (not imported):** [studio-naming.md](studio-naming.md) — **`studio-app`** editor vs **`studio`** / **`world`** packages.
