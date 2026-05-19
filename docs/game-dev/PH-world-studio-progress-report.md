# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Sprint:** impl-21 (2026-05)  
**Tracker:** [PH-world-studio-program.md](PH-world-studio-program.md)  
**PR summary:** [PR-world-studio-impl-summary.md](PR-world-studio-impl-summary.md)

---

## Executive summary

| Metric | Value |
|--------|--------|
| **Packages** | 28 |
| **Composable gates** | **69 / 69 pass** ✅ |
| **Game dev smokes** | **12 parse_ok** |
| **Vertical demo builds** | **6 / 6 compile_ok** ✅ |
| **Demo GUI** | [deploy/studio-demo/](../../deploy/studio-demo/) + live `status.json` |
| **Sprints** | impl-1 → **impl-21** |
| **Blocked** | `sim_step_physics` |
| **Merge** | ⬜ open PR → `main` |

---

## Sprint impl-21

| Deliverable | Track | State |
|-------------|-------|--------|
| `demo_bioeng_main` + `demo_mmo_main` | verticals | ✅ |
| All 6 verticals in `import_demo_verticals` | composable | ✅ |
| `import_spinup_game` composable | spin-up | ✅ |
| `vertical_demos` suite — **lic build** on 6 mains | CI | ✅ |
| `status.json` + `gen-studio-demo-status.sh` | demo GUI | ✅ |

---

## Sprint impl-20 (shipped)

| Deliverable | Track | State |
|-------------|-------|--------|
| Render viewport bridge | PH-GD-5 | ✅ |
| rocket/racing/robot/drug demo mains | demos | ✅ |

---

## Vertical demos (all build)

| Vertical | Main | Build |
|----------|------|-------|
| Rocket | `li-physics-custom/.../demo_rocket_main.li` | ✅ |
| Racing | `li-sim-automotive/.../demo_racing_main.li` | ✅ |
| Robot | `li-sim-robotics/.../demo_robot_main.li` | ✅ |
| Drug | `li-sim-drug-design/.../demo_drug_main.li` | ✅ |
| Bioeng | `li-bioeng/.../demo_bioeng_main.li` | ✅ |
| MMO | `li-mmo/.../demo_mmo_main.li` | ✅ |

---

## Composable timeline

| Sprint | Gates |
|--------|-------|
| impl-20 | 68 |
| **impl-21** | **69** |

---

## Verify

```bash
./li-tests/run_all.sh composable
./li-tests/run_all.sh game_dev
./li-tests/run_all.sh vertical_demos
./scripts/gen-studio-demo-status.sh
python3 -m http.server 8765 --directory deploy/studio-demo
```

---

## Next (impl-22)

1. **Merge PR** `feat/world-studio-impl-1` → `main`  
2. Embed native render in studio binary (beyond HTML prototype)  
3. `lis new` spin-up CLI wiring  
4. `sim_step_physics` when cross-package types land  

---

*impl-21 · `feat/world-studio-impl-1`*
