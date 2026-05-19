# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Sprint:** impl-25 (2026-05)  
**Tracker:** [PH-world-studio-program.md](PH-world-studio-program.md)  
**Merge:** [MERGE-world-studio-checklist.md](MERGE-world-studio-checklist.md)

---

## Executive summary

| Metric | Value |
|--------|--------|
| **Composable gates** | **80 / 80 pass** ✅ |
| **Game dev** | **12 parse_ok** |
| **Vertical builds** | **7** |
| **Spin-up templates** | **7 compile_ok** |
| **Studio binary** | `build/bin/world-studio` ✅ |
| **CI** | `./scripts/ci-world-studio.sh` + `check-world-studio-gates.sh` |
| **CLI** | `./scripts/lis new world-studio …` (incl. `game_unphysical`) |
| **Blocked** | `sim_step_physics` (deferred) |

---

## Sprint impl-25

| Deliverable | State |
|-------------|--------|
| `studio_spinup_registry_smoke()` (7 templates) | ✅ |
| `import_studio_spinup_registry` + tier-1 benchmark composable | ✅ |
| Demo GUI **Unphysical** tab (`deploy/studio-demo/`) | ✅ |
| Competitive registry entries for impl-25 gates | ✅ |

## Sprint impl-24

| Deliverable | State |
|-------------|--------|
| `game_unphysical` spin-up template + registry entry | ✅ |
| `sim_world_studio_stack_smoke()` in `li-sim` | ✅ |
| `import_spinup_unphysical` + `import_sim_world_studio_stack` composables | ✅ |
| `benchmarks/competitive/world-studio.toml` registry stub | ✅ |
| `scripts/check-world-studio-gates.sh` pre-merge rollup | ✅ |

---

## Quick commands

```bash
./scripts/lis new world-studio game_unphysical ./my-weird-game
./scripts/check-world-studio-gates.sh
./scripts/ci-world-studio.sh
./build/bin/world-studio   # after build-studio-binary.sh
./scripts/gen-studio-demo-status.sh
python3 -m http.server 8765 --directory deploy/studio-demo
```

---

## Composable timeline

| Sprint | Gates |
|--------|-------|
| impl-23 | 76 |
| impl-24 | 78 |
| **impl-25** | **80** |

---

## Next

1. **Merge PR** → `main` ([checklist](MERGE-world-studio-checklist.md))  
2. Native `world-studio` binary viewport (wire `li-render` beyond HTML demo)  
3. Upstream `lis` package: native `new world-studio` subcommand  
4. `sim_step_physics` when compiler allows cross-package types  

---

*impl-25 · `feat/world-studio-impl-1`*
