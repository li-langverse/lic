# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Sprint:** impl-38 (2026-05)  
**Architecture:** [specs/world-architecture-competitive-rfc.md](specs/world-architecture-competitive-rfc.md)

---

## Executive summary

| Metric | Value |
|--------|--------|
| **Composable gates** | **121** (target) |
| **Milestone** | **100** composable (impl-32) |
| **World model** | **GameWorld** GW-0–4 + **SimField** SF-0–3 + **RealmHead** |
| **Author API** | [world-api-quickstart.md](world-api-quickstart.md) |
| **Spin-up** | **11** |

---

## Sprint impl-38 — ergonomics + GW-3 / GW-4 / SF-2 / SF-3

| Deliverable | State |
|-------------|--------|
| Short aliases (`new_game_world`, `new_field`, …) | ✅ |
| [world-api-quickstart.md](world-api-quickstart.md) | ✅ |
| GW-3 region streaming · GW-4 draw_frame + render | ✅ |
| SF-2 GPU · SF-3 checkpoint manifest | ✅ |

## Sprint impl-37 — GW-1 / GW-2 / SF-1

| Deliverable | State |
|-------------|--------|
| `game_soa_*` + 10k tick budget smoke | ✅ |
| `GameReplicationDelta` + full snapshot compare | ✅ |
| `sim_field_tier2_couple_stub` + physics.core profile | ✅ |
| Composables: GW-1, GW-2, SF-1, competitive rollup | ✅ |

## Sprint impl-36 — competitive world rethink

| Deliverable | State |
|-------------|--------|
| [world-architecture-competitive-rfc.md](specs/world-architecture-competitive-rfc.md) | ✅ |
| `GameEntity` / `GameWorld` / `game_replication_delta_stub` | ✅ |
| `SimFieldChunk` / `sim_field_step_stub` | ✅ |
| Composables: ECS, SimField, dual-model stack | ✅ |

## Sprint impl-35 — Li-native gateway + persist

| Deliverable | State |
|-------------|--------|
| `httpd_li_native_gateway_*` | ✅ |
| `world_li_native_persist_*` | ✅ |
| `import_ecosystem_gateway_realm_li_native` | ✅ |

---

## Honest competitiveness note

| Target | Status |
|--------|--------|
| Unreal-class rendering | **Not yet** — GW-2 replication stub; GW-4 render pending |
| HPC tier-2 physics | **SF-1 stub** — tier-2 couple + `physics.core` profile |
| MMO / agents / repro | **Strong wedge** — RealmHead + Li-native store/httpd |

---

## Quick commands

```bash
./scripts/merge-world-studio-preflight.sh
./li-tests/run_all.sh composable
```

---

*impl-38 · author API · GW-3–4 · SF-2–3*
