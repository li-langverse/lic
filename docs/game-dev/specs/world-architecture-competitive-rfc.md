# RFC: Competitive world architecture — GameWorld vs SimField

**Status:** Draft (impl-36)  
**Track:** PH-GD-2 / PH-SCI  
**Policy:** [li-native-first.mdc](../../../.cursor/rules/li-native-first.mdc)  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

A single `WorldSnapshot` + journal counter is **not** competitive with:

- **Unreal-class games** — ECS, streaming, replication deltas, GPU scene graph  
- **HPC / scientific** — fields, solver state, checkpoint files, conservation proofs  

Composable gates on journals prove **Li-native policy**, not **engine competitiveness**.

## Proposal: two world models

```text
┌──────────────────────┐     ┌──────────────────────┐
│  GameWorld (PH-GD)   │     │  SimField (PH-SCI)     │
│  entities, components│     │  grids, tiers, samples │
│  replication deltas  │     │  checkpoint manifests  │
│  li-render hot path  │     │  sim.viz + tier-2 phys │
└──────────┬───────────┘     └──────────┬───────────┘
           │                          │
           └────── sim profiles ────────┘
```

| Model | Package | Persistence | Proof target |
|-------|---------|-------------|--------------|
| **RealmHead** | `li-world` | `WorldSnapshot` metadata only (tick, realm, shard) | MMO checkpoint invariants |
| **GameWorld** | `li-world` | Chunked binary + **delta replication** (future) | Replication + tick determinism |
| **SimField** | `li-sim-scientific` | HDF5/VTK manifest via `studio.publish` (future) | Conservation / stability contracts |

**Non-goal:** Beat Unreal Nanite/Lumen in impl-36. **Goal:** Correct abstractions + Li-native paths with measurable targets.

## GameWorld (AAA-oriented stub → real)

| Phase | Deliverable | Target |
|-------|-------------|--------|
| GW-0 | `GameEntity`, `GameWorld`, spawn | Composable smoke |
| GW-1 | SoA component tables | ≥10k entities/tick stub budget |
| GW-2 | `game_replication_delta_*` | Delta bytes ≪ full snapshot |
| GW-3 | Region streaming hooks | Memory budget per [PH-PORT](../portable-targets-rfc.md) |
| GW-4 | `li-render` residency | 60 fps viewport ([PH-UX](../studio-ux-design-system-rfc.md)) |

```li
# li-world (GW-0)
type GameEntity = object
  public entity_id: int
  public archetype_id: int

type GameWorld = object
  public tick: int
  public entity_count: int
  public realm_id: int
```

## SimField (HPC-oriented stub → real)

| Phase | Deliverable | Target |
|-------|-------------|--------|
| SF-0 | `SimFieldChunk` metadata | Composable smoke |
| SF-1 | Tier-2 physics coupling | `scientific_run_stub` + benches |
| SF-2 | GPU batch via LKIR | `li-gpu` + `li-chem` |
| SF-3 | Checkpoint manifest | PH-PUB repro bundle |

```li
# li-sim-scientific (SF-0)
type SimFieldChunk = object
  public field_id: int
  public cell_count: int
  public tier: int
  public timestep: int
```

## What stays from impl-34

- **`store_li_native_*`** — session/presence/replay **semantics** (not the game ECS)  
- **`WorldLiJournal`** — realm **event log** head, not entity store  
- **Composable gates** — keep; route new work through GW/SF APIs  

## Li beat conditions (unchanged)

| vs | Wedge |
|----|--------|
| Unreal | Diffable worlds, agents, `lic build` on rules, arbitrary physics |
| OpenFOAM/GROMACS | Unified sim + in-viewport tier-2 + repro export |
| Redis MMO | Proved shard logic + Li-native store semantics |

## Composable gates (impl-36)

- `import_game_world_ecs`  
- `import_sim_field_chunk`  
- `import_world_dual_model_stack`  

## References

- [li-engine-unified-sim-rfc.md](li-engine-unified-sim-rfc.md)  
- [li-native-store-port.md](../li-native-store-port.md)  
- [li-native-gateway-world-port.md](../li-native-gateway-world-port.md)  
