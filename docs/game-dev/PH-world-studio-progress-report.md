# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Sprint:** impl-8 (2026-05)  
**Tracker:** [PH-world-studio-program.md](PH-world-studio-program.md)  
**Vision:** [world-studio-vision.md](world-studio-vision.md)

---

## Executive summary

| Metric | Value |
|--------|--------|
| **Workspace packages** (World Studio) | **26** members in `packages/li.toml` |
| **Composable import gates** | **27 / 27 pass** ✅ |
| **Game dev smokes** | **6** parse_ok |
| **Plan / RFC docs** | 18+ under `docs/game-dev/` |
| **Deploy profiles** | `deploy/mmo/` (compose + realm.toml) |
| **Competitive registries** | `bioengineering.toml`, `mmorpg.toml` |
| **Blocked** | `sim_step_physics` → `physics.runtime`; some full `lic build` smokes |
| **On `main`** | Vision #59 only; **impl branch not merged** |

---

## Sprint impl-8 (this report)

| Deliverable | Track | State |
|-------------|-------|--------|
| `store_trusted_redis_ping` extern + `store_realtime_open_redis` | MMO-4 | ✅ |
| `li-studio-ai` (`studio.ai`) apply_patch stub | PH-GD-3 | ✅ |
| `li-player` client connect stub | PH-GD-7 / MMO | ✅ |
| `mmo_anticheat_validate_tick_stub` | MMO-7 partial | ✅ |
| `bioeng_dbtl_pipeline_smoke` | BIOENG-1 | ✅ |
| `import_mmo_player_stack` composable | MMO | ✅ |
| `benchmarks/competitive/mmorpg.toml` | MMO | ✅ |
| [studio-ai-rfc.md](specs/studio-ai-rfc.md) | PH-GD-3 | ✅ |

---

## Program progress by track

Legend: ✅ Done (stub+) · 🟡 In progress · ⬜ Not started · 🚫 Blocked

| Program | Phases | Status | % est. | Notes |
|---------|--------|--------|--------|-------|
| **PH-GD** | GD-0…7 | 🟡 | 35% | studio, world, **studio.ai**, **player** |
| **PH-SIM** | SIM-0…6 | 🟡 | 40% | 9 profiles, replay, law modes |
| **PH-MMO** | MMO-0…7 | 🟡 | 55% | 0–4 partial, 6–7 partial |
| **PH-BIOENG** | BIOENG-0…7 | 🟡 | 15% | 0–1 done |
| **PH-DRUG** | DRUG-0…7 | ✅ stub | 15% | LITL |
| **PH-PHYS-CUSTOM** | CUSTOM-0…3 | ✅ | 25% | arbitrary laws |
| **PH-ROBO / AM / SCI** | stubs | ✅ | 10% each | sim.* packs |
| **PH-QM** | QM-0…7 | 🟡 | 15% | li-chem |
| **PH-VOXEL / ML / HW** | stubs | ✅ | 10% | voxel, ml, gpu |
| **PH-PORT** | PORT-0…2 | ✅ | 33% | targets manifest |
| **PH-UX** | UX-0…5 | ⬜ | 0% | RFC stub |
| **PH-PUB** | PUB-0…5 | 🟡 | 10% | studio_publish_* |
| **PH-AGENT** | AGENT-0…6 | 🟡 | 10% | MCP sketch |
| **PH-COMPLY** | COMPLY-0…4 | 🟡 | 15% | chem, additive |

---

## PH-MMO phase table

| Phase | Deliverable | State |
|-------|-------------|--------|
| MMO-0 | Plan, `li-mmo`, `store.realtime` | ✅ |
| MMO-1 | Stack composable (sim+world+store) | ✅ |
| MMO-2 | Matchmaking | ✅ |
| MMO-3 | deploy/, shard/gateway mains | ✅ |
| MMO-4 | Trusted Redis extern + `open_redis` | ✅ stub |
| MMO-5 | WebSocket gateway | ⬜ |
| MMO-6 | `world_snapshot_for_realm` | 🟡 |
| MMO-7 | `mmo_anticheat_validate_tick_stub` | 🟡 |

---

## PH-BIOENG phase table

| Phase | State |
|-------|--------|
| BIOENG-0 plan + package + drug bridge | ✅ |
| BIOENG-1 `bioeng_dbtl_pipeline_smoke` | ✅ |
| BIOENG-2…7 constructs, assays, scorecard | ⬜ |

---

## All composable gates (27)

`sim`, `studio`, `world`, `chem`, `voxel`, `bioeng`, `bioeng_pipeline`, `mmo`, `mmo_stack`, `mmo_sim`, `mmo_player_stack`, `store.realtime`, `store_redis`, `player`, `studio.ai`, `physics.custom`, `physics.relativity`, `sim.additive`, `sim.scientific`, `sim.robotics`, `sim.automotive`, `sim.drug_design`, `ml`, `gpu`, `httpd`, `sim_custom_law`, + drug bridge.

---

## Verification

```bash
./li-tests/run_all.sh composable   # expect 27 passed
./li-tests/run_all.sh game_dev     # expect 6 passed
```

---

## Next sprint (impl-9)

1. Merge branch → `main` (draft PR).  
2. MMO-5: WebSocket stub on `net.httpd`.  
3. GD-3: `lic diagnose` JSON → `studio_ai_apply_patch`.  
4. BIOENG-2: construct registry types.  
5. Compiler: cross-package `PhysicsWorld` for `sim_step_physics`.

---

*Last updated: impl-8 · commit on `feat/world-studio-impl-1`*
