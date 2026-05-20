# World Studio packages (monorepo `lic/packages`)

**Branch landed from:** `feat/world-studio-impl-1` (impl-40+)

| Import | Package | Role |
|--------|---------|------|
| `studio` | li-studio | Shell, play mode, publish |
| `world` | li-world | GameWorld ECS, RealmHead, streaming |
| `sim` | li-sim | Profiles, `sim_step`, physics stub |
| `sim.scientific` | li-sim-scientific | SimField, checkpoints, GPU hook |
| `render` | li-render | Viewport, GPU surface |
| `mmo` | li-mmo | Realms, shards, WS bind |
| `store.realtime` | li-store-realtime | Li-native presence / replay |
| `net.httpd` | li-net-httpd | Li-native gateway |
| `physics.custom` | li-physics-custom | Arbitrary laws |
| `physics.runtime` | li-physics-runtime | PhysicsWorld step (composable) |
| `studio.ai` | li-studio-ai | Agent diagnose / patch |

Register in roadmap **official-packages** when publishing mirror repos.
