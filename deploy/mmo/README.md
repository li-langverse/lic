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

## Li composable smoke

Gate `import_mmo_deploy_dev` checks `mmo_deploy_dev_*` against [realm.toml](realm.toml) (`shard_count=2`, `tick_hz=30`, gateway `8080`, WS `8081`).

```bash
./scripts/deploy-mmo-dev.sh
./li-tests/run_all.sh composable
```
