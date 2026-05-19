# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Report date:** 2026-05 (auto-updated each impl sprint)  
**Tracker:** [PH-world-studio-program.md](PH-world-studio-program.md)  
**Vision:** [world-studio-vision.md](world-studio-vision.md)

---

## Executive summary

| Metric | Value |
|--------|-------|
| **Workspace packages** (World Studio track) | 24+ official members in `packages/li.toml` |
| **Composable import gates** | **22** passing (`./li-tests/run_all.sh composable`) |
| **Game dev smokes** | **6** parse_ok |
| **RFC / plan docs** | 16+ under `docs/game-dev/` |
| **Blocked** | `sim_step_physics` → `physics.runtime` (cross-package types); full `lic build` on some smokes |
| **On `main`** | Vision + RFC index (#59); implementation branch not merged |

---

## Program progress by track

Legend: ✅ Done (stub+) · 🟡 In progress · ⬜ Not started · 🚫 Blocked

| Program | Phases | Done | Status | Notes |
|---------|--------|------|--------|-------|
| **PH-GD** | GD-0…7 | 0–2 | 🟡 | `li-studio`, `li-world`; viewport/outliner |
| **PH-SIM** | SIM-0…6 | 0–2 | 🟡 | `li-sim`, profiles 0–8, replay |
| **PH-PHYS-CUSTOM** | CUSTOM-0…3 | 0 | ✅ | `li-physics-custom`, law modes |
| **PH-ROBO** | ROBO-0…5 | 0 | ✅ | `li-sim-robotics` |
| **PH-AM** | AM-0…9 | 0 | ✅ | `li-sim-additive`, export stub |
| **PH-SCI** | SCI-0…7 | 0 | ✅ | `li-sim-scientific`, viz frame |
| **PH-DRUG** | DRUG-0…7 | 0 | ✅ | `li-sim-drug-design`, LITL |
| **PH-BIOENG** | BIOENG-0…7 | 0 | ✅ | Plan + `li-bioeng`, drug bridge |
| **PH-MMO** | MMO-0…7 | 0–3 | 🟡 | Plan, packages, deploy, matchmaking |
| **PH-QM** | QM-0…7 | 0–1 | 🟡 | `li-chem` DFT/TDDFT stubs |
| **PH-VOXEL** | VOXEL-0…5 | 0 | ✅ | `li-voxel` |
| **PH-ML** | ML-0…5 | 0 | ✅ | `li-ml` JobGraph stub |
| **PH-HW** | HW-0…4 | 0 | ✅ | `li-gpu` backend tags |
| **PH-PORT** | PORT-0…2 | 0 | ✅ | `targets/manifest.toml` |
| **PH-UX** | UX-0…5 | 0 | ⬜ | Design system RFC stub |
| **PH-PUB** | PUB-0…5 | 0 | 🟡 | `studio_publish_*` stubs |
| **PH-AGENT** | AGENT-0…6 | 0 | 🟡 | [agent-mcp-sketch.md](agent-mcp-sketch.md) only |
| **PH-COMPLY** | COMPLY-0…4 | 0 | 🟡 | `compliance.toml` on chem, additive |

---

## PH-MMO detail (latest sprint)

| Phase | Deliverable | State |
|-------|-------------|-------|
| MMO-0 | Plan, RFC, `li-mmo`, `store.realtime` | ✅ |
| MMO-1 | `sim_profile_mmo`, stack composable | ✅ |
| MMO-2 | Matchmaking queue stubs | ✅ |
| MMO-3 | `deploy/mmo/`, shard/gateway `*_main.li` | ✅ |
| MMO-4 | Redis/Postgres trusted FFI | ⬜ |
| MMO-5 | WebSocket gateway | ⬜ |
| MMO-6 | Cross-shard + world checkpoint | 🟡 (`world_snapshot_for_realm`) |
| MMO-7 | Anti-cheat + audit | ⬜ |

---

## PH-BIOENG detail

| Phase | State |
|-------|-------|
| BIOENG-0 plan + `li-bioeng` + bridge | ✅ |
| BIOENG-1 full DBTL mutation test | 🟡 (borrowck) |
| BIOENG-2…7 | ⬜ |

---

## Packages landed (import gates)

| Import | Package |
|--------|---------|
| `sim` | li-sim |
| `studio` | li-studio |
| `world` | li-world |
| `chem` | li-chem |
| `voxel` | li-voxel |
| `bioeng` | li-bioeng |
| `mmo` | li-mmo |
| `store.realtime` | li-store-realtime |
| `physics.custom` | li-physics-custom |
| `sim.*` (additive, scientific, robotics, automotive, drug_design) | li-sim-* |
| `ml`, `gpu` | li-ml, li-gpu |

---

## Verification commands

```bash
./li-tests/run_all.sh composable   # 22 passed (target)
./li-tests/run_all.sh game_dev     # 6 parse_ok
./build/compiler/lic/lic check packages/li-mmo/src/lib.li
```

---

## Next recommended work

1. Merge `feat/world-studio-impl-1` → `main` (draft PR).  
2. MMO-4: trusted Redis extern + `store.realtime` wiring.  
3. BIOENG-1: DBTL pipeline composable with `lab_loop_*`.  
4. PH-GD-3: `li-studio-ai` scaffold.  
5. Unblock `sim_step_physics` when compiler exports cross-package types.

---

*Regenerate this report when closing an impl sprint (impl-N).*
