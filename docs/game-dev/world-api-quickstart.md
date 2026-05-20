# World & field API — quickstart for authors and agents

**Goal:** Copy-paste friendly names. Prefer **short aliases** in game/sim code; use `game_world_*` / `sim_field_*` when you need the full name in docs or proofs.

**Import:** `import world` · `import sim.scientific` · `import render` (viewport)

---

## Game world (AAA path)

```li
import world

def main() -> int
=
  var w: GameWorld = new_game_world(1)
  var hero: GameEntity = spawn_entity(w, 1)
  tick_game_world(w)
  var delta_bytes: int = send_entity_delta(w, hero.entity_id, 7)
  return delta_bytes
```

| You want | Call |
|----------|------|
| Create world | `new_game_world(realm_id)` |
| Spawn | `spawn_entity(world, archetype_id)` |
| Tick sim | `tick_game_world(world)` or `game_world_draw_frame(world, width, height)` before render |
| Network delta | `send_entity_delta(world, entity_id, component_mask)` |
| Stream a region | `game_region_load` / `game_streaming_load_region` |

---

## Scientific field (HPC path)

```li
import sim.scientific

def main() -> int
=
  var f: SimFieldChunk = new_field(0, 128, 2)
  step_field(f, 0.001)
  var score: int = run_field_on_gpu(f, 64)
  var cp: SimFieldCheckpoint = save_field_checkpoint(f)
  var again: SimFieldCheckpoint = load_field_checkpoint(cp.manifest_hash)
  return again.tick
```

| You want | Call |
|----------|------|
| Create field | `new_field(field_id, cell_count, tier)` |
| Step solver | `step_field(chunk, dt)` |
| GPU batch | `run_field_on_gpu(chunk, batch_size)` |
| Repro bundle | `save_field_checkpoint` / `load_field_checkpoint` |

---

## Viewport (with game tick)

```li
import world
import render

def frame(world: GameWorld) -> int
=
  var tag: int = game_world_draw_frame(world, 1280, 720)
  return tag + render_gpu_viewport_tick_stub(1280, 720, 1)
```

---

## Studio play mode

**Easiest path — one call:**

```li
import studio

var project = studio_project_new()
run_play_session(project, realm_id, width, height, field_id, sim_steps)
```

**Manual steps** (when you need control):

```li
start_playing(project)
tick_viewport(project)
studio_game_frame_tag(realm_id, width, height)
studio_sim_frame_tag(field_id, steps)
```

| You want | Call |
|----------|------|
| Full play loop | `run_play_session(project, realm, w, h, field_id, steps)` |
| Start / stop | `start_playing(project)` · `stop_playing(project)` |
| Viewport tick | `tick_viewport(project)` |
| Publish repro | `publish_repro(manifest_hash, file_count)` |
| Field → publish | `publish_field_checkpoint(manifest_hash, file_count)` |

---

## Realm + game together

```li
import world

var w = new_game_world(1)
spawn_entity(w, 1)
sync_realm_head(w, tick, shard_id)
```

---

## Realm metadata only (MMO head — not ECS)

Use `world_snapshot_for_realm` / `world_li_native_journal_*` when you only need shard tick and checksum — **not** entity positions.

See [world-architecture-competitive-rfc.md](specs/world-architecture-competitive-rfc.md).

---

## New project (spin-up)

```bash
./scripts/lis-new-world-studio.sh play_mode my-game
lic check my-game/main.li
```

Templates: `deploy/world-studio-spinup/spinup.toml` (includes **play_mode**).

```bash
./scripts/list-world-studio-spinups.sh
```

## Physics step (deferred full API)

```li
import sim

# Placeholder until sim_step_physics(world, physics_world) compiles across packages:
step_physics(tick, tier, dt_millis)
# same as sim_step_physics_stub(...)
```
