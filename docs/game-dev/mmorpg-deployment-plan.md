# MMORPGs on Li Engine — plan & deployment (PH-MMO)

**Status:** Planning → implementation (MMO-0)  
**Vision:** [world-studio-vision.md](world-studio-vision.md)  
**RFC:** [mmorpg-online-rfc.md](specs/mmorpg-online-rfc.md)  
**Related:** `li-world`, `li-scene`, `li-sim`, `li-net`, `net.httpd`, `store.realtime`

---

## 1. Strategic goal

Ship **large-scale online worlds** on the same Li Engine as single-player and sim profiles — diffable `world.li`, proved game logic, agent-native ops — without forking to Unity + Photon or custom C++ shards only.

| Competitor | Gap | Li beat condition |
|------------|-----|-------------------|
| WoW / FFXIV private stacks | Opaque server, no proof | `lic check` on gameplay + shard logic |
| Unity + Netcode / Photon | Sim ≠ MMO ops | One engine: `sim_profile_game` + **`sim_profile_mmo`** |
| Spatial / Hathora | Host-only, no Li semantics | Self-hosted **deployment profiles** + open packages |
| Custom Erlang/Go shards | Logic drift from client | Shared `mmo` protocol types in repo |

---

## 2. Do we need a database **in Li**?

**Short answer: no full DB implementation in Li for v1.**  
**Long answer: yes a Li-facing realtime store API** — not a new storage engine.

| Layer | Approach |
|-------|----------|
| **Authoritative state** | Shard game servers run `lic build` gameplay; RAM + tick snapshots |
| **Realtime fan-out** | **Redis** (pub/sub, presence) or **Postgres LISTEN/NOTIFY** via **trusted FFI** (same pattern as `li-net` TCP) |
| **Durable world** | **Postgres** / **Cockroach** for accounts, inventory, guilds — migrations as versioned Li schema stubs |
| **Li package** | **`store.realtime`** (`li-store-realtime`) — typed keys, rooms, session tokens; backends = `redis` \| `postgres` \| `memory` (dev) |
| **Future (MMO-5+)** | Optional native Li storage only if proof + perf demand it; until then reuse battle-tested stores |

```text
Clients ──► Gateway (net.httpd / WS) ──► Shard (mmo.tick) ──► store.realtime ──► Redis / Postgres
                                              │
                                              └── li-world snapshots (checkpoints)
```

**Why not pure Li DB day one:** replication, WAL, and global consistency are a multi-year program; MMOs need shipping paths. Li owns **protocol, proof, and orchestration**; storage is pluggable and **trusted** where FFI is required (PH-COMPLY documents assumptions).

---

## 3. Server roles & deployment

### 3.1 Process roles

| Role | Binary / package | Responsibility |
|------|------------------|----------------|
| **Gateway** | `net.httpd` + `mmo.gateway` | TLS, auth tokens, route to shard |
| **Shard** | `mmo.shard` | Authoritative simulation tick, AOI |
| **Matchmaking** | `mmo.match` | Realm selection, queues (stub MMO-2) |
| **Persistence worker** | `store.realtime` + async flush | Batched writes, idempotent |
| **Studio / ops** | World Studio + MCP | Deploy manifests, rollouts |

### 3.2 Deployment targets (how we deploy)

| Tier | Target | Use |
|------|--------|-----|
| **Dev** | `docker compose` profile `mmo-dev` | 1 gateway + 1 shard + Redis + Postgres |
| **Staging** | K8s namespace per realm | Horizontal shard pods |
| **Prod** | K8s + [targets/manifest.toml](../../targets/manifest.toml) triples | `x86_64-linux`, `aarch64-linux`; GPU optional for ML NPCs |

**Artifact pipeline:**

```bash
lic build packages/li-mmo/src/shard_main.li -o mmo-shard --release
lic build packages/li-mmo/src/gateway_main.li -o mmo-gateway --release
# Images: deploy/mmo/Dockerfile (planned MMO-3)
```

**Config:** `deploy/mmo/realm.toml` — shard count, tick rate, store backend URL (env), `engine.profile = "mmo"`.

### 3.3 Do we need Li-coded servers?

**Yes — game logic and protocol in Li.**  
**No — for generic HTTP/Redis/Postgres clients** (trusted extern until `li-net` grows).

Shard loop (conceptual):

```li
import mmo
import sim
import store.realtime

def shard_tick(realm: RealmState) -> unit
  requires realm.tick >= 0
=
  sim_step(realm.sim)
  mmo_broadcast_aoi_stub(realm, realm.tick)
  store_realtime_flush_stub(realm.store_handle)
```

---

## 4. Architecture on existing packages

```text
┌──────────────────────────────────────────────────────────────┐
│  World Studio — realm editor, deploy wizard, player analytics │
├──────────────────────────────────────────────────────────────┤
│  li-mmo (import mmo) — realms, sessions, AOI, deploy profiles │
│  li-store-realtime — sessions, presence, pub/sub facade       │
├──────────────────────────────────────────────────────────────┤
│  li-world / li-scene / li-sim (profile_mmo) / physics.*     │
│  li-net (TCP) · net.httpd (gateway) · li-player (client)      │
└──────────────────────────────────────────────────────────────┘
```

---

## 5. Program phases (PH-MMO)

| Phase | ID | Deliverable |
|-------|-----|-------------|
| 0 | MMO-0 | Plan, RFC, `li-mmo` + `li-store-realtime` stubs | ✅ |
| 1 | MMO-1 | Realm tick + `sim_profile_mmo` composable gate | ✅ |
| 2 | MMO-2 | Matchmaking + gateway route table stub | ✅ |
| 3 | MMO-3 | `deploy/mmo/` compose + realm.toml + shard/gateway mains | ✅ |
| 4 | MMO-4 | Trusted Redis/Postgres FFI behind `store.realtime` | ✅ stub |
| 5 | MMO-5 | WebSocket gateway on `net.httpd` |
| 6 | MMO-6 | Cross-shard migration + `world` checkpoint |
| 7 | MMO-7 | Anti-cheat hooks + compliance audit |

---

## 6. Realtime model

| Concern | v1 choice |
|---------|-----------|
| Sync | **Authoritative shard** @ 20–60 Hz; client prediction later |
| Interest | AOI grid stub (`mmo_aoi_cell_count`) |
| Chat / presence | `store.realtime` pub/sub channels |
| Persistence | Async write-behind; crash recovery from last `world` snapshot |
| Conflict | Server wins; `lic` proved invariants on inventory stubs |

---

## 7. Studio & agents

- **Deploy wizard:** pick `mmo-dev` \| `mmo-prod`, realm name, shard count.  
- **MCP:** `engine_mmo_deploy_stub`, `engine_realm_status`.  
- **Spin-up:** [spin-up-templates.md](spin-up-templates.md) row `mmorpg`.

---

## 8. Open questions

- [ ] UDP vs TCP for game data — `li-net` UDP extern (MMO-5)?  
- [ ] Global state — CRDT in `li-world` vs shard-local only?  
- [ ] Player-hosted realms — out of scope for MMO-0.

---

## 9. Links

- [mmorpg-online-rfc.md](specs/mmorpg-online-rfc.md)  
- [portable-targets-rfc.md](specs/portable-targets-rfc.md)  
- [competitive-landscape.md](competitive-landscape.md)
