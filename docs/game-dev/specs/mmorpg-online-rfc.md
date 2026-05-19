# RFC: MMORPG online stack (PH-MMO)

**Status:** Draft  
**Track:** PH-MMO  
**Plan:** [mmorpg-deployment-plan.md](../mmorpg-deployment-plan.md)

## Problem

MMOs need authoritative servers, realtime persistence, and repeatable deployment — usually bolted on as a separate stack from the game engine, with no proof on gameplay rules.

## Proposal

### Packages

| Import | Package | Role |
|--------|---------|------|
| `mmo` | `li-mmo` | Realms, shards, sessions, AOI, deploy profile ids |
| `store.realtime` | `li-store-realtime` | Presence, pub/sub, session store (**not** a new DB engine) |
| `sim` | `li-sim` | `sim_profile_mmo()` tick |
| `world` | `li-world` | Checkpoints, realm save |
| `net` / `net.httpd` | gateway | HTTP / future WS |

### Storage strategy

- **Do not** implement Postgres/Redis in Li for MMO-0.  
- **Do** expose `store_realtime_*` stubs → trusted FFI (MMO-4).  
- **Dev:** `store_backend_memory()` in-process hash stub.

### Deployment

- `deploy/mmo/realm.toml` + `compose.yml` (MMO-3).  
- Binaries: `mmo-shard`, `mmo-gateway` from `li-mmo/src/*_main.li` (thin demos).

## Phases

MMO-0…7 per plan §5.

## Proof policy

- Gameplay invariants on shard tick (`requires` / `ensures`).  
- Store layer: trusted axioms documented; no false durability claims on stubs.

## Dependencies

PH-GD-2 (`li-world`), PH-SIM-1, `li-net`, PH-PORT.
