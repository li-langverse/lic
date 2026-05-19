# Simulation, UI, and game-dev readiness

**Track:** PH-5b (physics) + PH-IO (ingest/UI) + new `li-std-ui` / `li-std-scene`

## Shipped (this branch)

| Layer | Package / path | Role |
|-------|----------------|------|
| Math | `li-std-math` | Vec2/3, Quat, Mat4, AABB |
| Numerics | `li-std-numerics` | Euler, Verlet, three-body helpers |
| Physics core | `li-std-physics-core` | Tiers, profiles, `SimulationParams` |
| Physics domains | `li-std-physics-*` | Rigid, fluids, particles, EM, … |
| **Runtime** | `li-std-physics-runtime` | `physics_world_new`, `physics_step`, scene sync hooks |
| **Scene** | `li-std-scene` | `EntityId`, `Transform3`, `Scene` graph hooks |
| **UI** | `li-std-ui` | `Color`, `Rect`, `UiFrame`, `InputState` |
| Compiler std | `std/io`, `std/ui` | Prelude stubs for PH-IO-4 / UI tooling |
| Benches | `benchmarks/tier2_physics/` | 20 kernels (catalog on benchmarks `main`) |

## Integration loop (engine)

```text
ui_frame_begin → input poll → physics_sync_from_scene → physics_step → physics_sync_to_scene → draw
```

Fixed timestep: `physics_world_game_default()` → `physics_step(world, 1.0/60.0)`.

## Next (priority)

1. **PH-IO-4** — wire `std/io` + `std/csv` in compiler (CSV ingest without Python).
2. **Import graph** — package `import` so runtime calls `li-std-physics-rigid` directly (deps in `li.toml`; runtime inlines until `li-tests` resolver lands).
3. **Pure-Li tier-2** — expand `three_body_pure` and `horner_pure_li` (PH-7e).
4. **Render bridge** — `li-std-ui` → engine draw list; keep rendering out of physics (GAME_DEV.md).
5. **Publish mirrors** — `push-official-package-repo.sh` for new `li-std-ui`, `li-std-scene`.

## Verification

```bash
cd lic
lic check packages/li-std-ui/src/lib.li
lic check packages/li-std-scene/src/lib.li
lic check packages/li-std-physics-runtime/src/lib.li
lic check std/io/io.li std/ui/ui.li
```

Tier-2: `cd benchmarks && python3 lic/benchmarks/harness/bench.py` (with sibling `lic`).
