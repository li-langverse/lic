# World Studio packages (monorepo `lic/packages`)

**Branch landed from:** `feat/world-studio-impl-1` (impl-40+)

| Import | Released repo (org) | `lic` mirror (integration) | Role |
|--------|---------------------|----------------------------|------|
| `studio` | **studio** | `packages/li-studio` | Shell, play mode, publish |
| `studio.ai` | **studio.ai** | `packages/li-studio-ai` | Agent diagnose / patch |
| `world` | **world** | `packages/li-world` | GameWorld ECS, RealmHead, streaming |
| `sim` | **sim** | `packages/li-sim` | Profiles, `sim_step`, physics stub |
| `sim.scientific` | **sim.scientific** | `packages/li-sim-scientific` | SimField, checkpoints, GPU hook |
| `render` | **render** | `packages/li-render` | Viewport, GPU surface |
| `mmo` | **mmo** | `packages/li-mmo` | Realms, shards, WS bind |
| `store.realtime` | **store.realtime** | `packages/li-store-realtime` | Li-native presence / replay |
| `net.httpd` | **net.httpd** | `packages/li-net-httpd` | Li-native gateway |
| `physics.custom` | **physics.custom** | `packages/li-physics-custom` | Arbitrary laws |
| `physics.runtime` | **physics.runtime** | `packages/li-physics-runtime` | PhysicsWorld step (composable) |

**Naming rule:** [package-import-naming.md](package-import-naming.md) — repo slug = import path.

Register in roadmap **official-packages** when publishing mirror repos.

**App (not imported):** [studio-naming.md](studio-naming.md) — **`studio-app`** editor vs **`studio`** / **`world`** packages.
