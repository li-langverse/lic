# MMORPG local deployment (PH-MMO-3)

```bash
# From repo root (after lic build lands shard/gateway binaries):
docker compose -f deploy/mmo/compose.yml up -d redis postgres

# Build demos (when toolchain supports package mains):
# lic build packages/li-mmo/src/shard_main.li -o mmo-shard
# lic build packages/li-mmo/src/gateway_main.li -o mmo-gateway
```

Config: [realm.toml](realm.toml) — `shard_count`, `tick_hz`, `store.backend`.

Plan: [docs/game-dev/mmorpg-deployment-plan.md](../../docs/game-dev/mmorpg-deployment-plan.md)
